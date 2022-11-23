function [PREFACE,TIME,FREQ,MPA,EAMPS,EPHASE,IC,RGT,MAXRBIN,FNOISE] = UNPACK_MMM(IBUF)
%       LOGICAL FUNCTION UNPACK_MMM(IBUF,
%      +            TIME,PREFACE,FREQ,FNOISE,EAMPS,EPHASE,IC,RGT,MAXRBIN)
% C
% C     This subroutine takes a 4K block of MMM ionogram data and is built
% C       on a similar routine for decoding 16 channel data.  There are some
% C       features here unneeded for 16C data.
% C
% C     Digisonde 256 data provides the following output.
% C        PREFACE - The decoded preface for this ionogram
% C        TIME - Time of the observation: YYYY DDD HH:MM:SS
% C        FREQ - The precise sounding frequency, in MHz.
% C               *NOTE* This will be slightly wrong for PGH modes, but it
% C               is still the frequency in the preface.
% C        MPA - The Most Probable Amplitude, or Noise, from Preface.
% C        EAMPS(256,16) - Received amplitudes vs range gate and channel # ,
% C                        in dB and corrected for all D256 processor settings
% C                        but not for any antenna gains, cable losses, etc.
% C        EPHASE(256,16)- Received phase vs range and channel #, in degrees
% C        IC(256) -  The MMM channel number for the
% C        RGT(256) - Range Gate Table assigns a range in km to each range gate.
% C        MAXRBIN -  Maximum range bin number (128 or 256)
% C
% C     Interpetation of the channel number in terms of polarization, Doppler,
% C     and Rx antenna beam position (arrival angle) is left to another routine.
% C
% C     Revisions:
% C     16Mar03 TWB - Initial version from the 16C base code.
% C        --Since there are multiple frequencies in each block,
% C          this code returns .FALSE. when a new block of data
% C          needs to be read.
% C
% C     16Jan05 TWB - Fixed MPA=0 bug for most MMM data
% C     12Jan08 TWB - Changed PRELUDE() to PRELUDE_MMM()
% C
% C
% C====+==================================================================+==
% C

%      IFRQ is the index of which frequency in the block is being decoded
persistent IFRQ
if isempty(IFRQ)
    IFRQ = int16(0);
end

MASKL=int16(15);
MASKH=int16(240);

%      Zero the arrays
EAMPS = zeros(256,16);
EPHASE = zeros(256,16);
IC = zeros(256,1);
RGT = zeros(256,1);
FNOISE = 0;
MAXRBIN = 0;
MPA = nan;
FREQ = nan;
TIME = NaT;
PREFACE = int8(zeros(57,1));



%     Check for MMM data type.  Exit if not
ITMP = IRTYPE(IBUF);
if ((ITMP ~= 9) && (ITMP ~= 8))
    warning('DGS:WrongRecordType','Wrong record type')
    return
end

PREFACE = PREF_MMM(IBUF);
%      There are various block types for MMM data.  This code
%      is hardwired to the BlockType=1 data, because 99% of the
%      recorded Digisonde 256 data are in this format.
%      These can be computed from the first prelude. (See PRELUDE())
MAXCHAN = int16(1);
MAXFRQ = int16(30);

IFRQ = IFRQ + 1;
if (IFRQ > MAXFRQ)
    % end of block
    IFRQ = 0;
    return
end

%      Set the range gate values
[MAXRBIN, RGT] = RG_D256(PREFACE);

%      Get the prelude data for the IFRQ entry in IBUF.
%      This actually modifies the PREFACE() array, except for MPA
[PREFACE, IPOL, FREQ, IGS, MPA] = PRELUDE_MMM(IFRQ,PREFACE,IBUF);


% fprintf('%i ', PREFACE);fprintf('\n')


if (MPA == -1)
    % The 0x0E in prelude indicating 'end of data'
    IFRQ = 0;
    return
end


YYYY=10*int16(PREFACE(1))+int16(PREFACE(2));
if (YYYY < 82)
    YYYY=YYYY+2000;
else
    YYYY=YYYY+1900;
end

TIME = datetime(sprintf('%04i %i%i%i %i%i %i%i %i%i', ...
    YYYY,PREFACE(3:11)),'InputFormat','uuuu DDD HH mm ss');


% C     Get the frequency value
FREQ = FRQ_D256(PREFACE);

%      The amplitude scale on the ionograms, from
%      4 upper bits give 4 or 6 dB per count depending on Z<8
DBSCALE = 4.0/16.0;

if (PREFACE(46) < 8)
    DBSCALE = 1.5*DBSCALE;
end

AUTOGAIN = 6.0*double(PREFACE(53));

%      The MPA is 0-31, or twice that of the 0-15 amplitudes.
%      but the amplitudes, as the upper 4 bits of each byte,
%      come out as 16x their 0-15 range, much like the 16C data.

%      BUG:  Many MMM data have an MPA of zero.
%            This is generally not possible
if (MPA == 0)
    FNOISE = 0.0;
else
    FNOISE = double(8*MPA)*DBSCALE + AUTOGAIN;
end

%      This is the preface length (57), plus the 3 lead characters
%      plus the 6 prelude characters
IPL = int16(IBUF(2) + 6);

%      Extract the amplitudes and phases from the array.
%      They are unsigned 8 bit integers so we have to treat them carefully
%      NOTE:  This won't work for 256 range data

for IR=1:MAXRBIN
    for I=1:MAXCHAN
        IAX = IPL + (MAXRBIN+6)*(IFRQ-1) + MAXRBIN*(I-1) + IR;
        IC(IR) = IAND(MASKL,IBUF(IAX)) + 1;
        ITMP = IAND(MASKH,IBUF(IAX));
        EAMPS(IR,IC(IR)) = DBSCALE*double(ITMP) + AUTOGAIN;
        EPHASE(IR,IC(IR)) = 0.0;
    end
end
