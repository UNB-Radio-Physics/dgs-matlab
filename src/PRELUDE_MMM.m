function [PREFACE, IPOL, FREQ, IGS, MPA] = PRELUDE_MMM(IFRQ,PREFACE,IBUF)
%
%      Decodes the PRELUDE data for entry IFRQ in MMM data block IBUF.
%      These data are inserted into the active PREFACE() array, which is
%      where they came from in the first place.  This makes the Preface
%      valid for MMM data just like 16C data.
%
%      MPA is an extra value and this is returned as the function value.
%      A value of -1 is returned if a request is made beyond the end of data.
%
%      Prelude is 6 bytes of High and Low nibbles:
%      1H :  1=D256 ; 2=X Polarization (DPS), 3=O polarization (DPS)
%      1L :  Data Group size (1=134; 2=262 ; 3=504 ; 4=1004)
%      IFS: The I* frequency search setting
%      IGS: The G* AutoGain setting
%      ISEC: Seconds of the minute
%      MPA: Most Probable Amplitude (0-31)
%
%      16Mar03  TWB
%      28Jul04  TWB -Added polarization (IPOL) which is the high nibble.
%                    This is required for RSF & SBF format where the block
%                    could be O or X polarization.
%                   -Added FREQ return variable of the Prelude Freq setting
%                    because DPS does not have this in the PREFACE.
%                   -Added AutoGain setting IGS
%      09Aug04  TWB -Spawned prelude_mmm, prelude_sbf and prelude_rsf
%                    because of increasingly complex variables between
%                    the preludes of these formats

persistent MININC
persistent LSEC
if isempty(LSEC)
    LSEC = int16(-1);
end
if isempty(MININC)
    MININC = int16(0);
end

NGS = int16([134,262,504,1008]);
MFR = int16([30, 15, 8, 4]);
M4L = int16(15);
M4H = int16(240);


IPOL = nan;
FREQ = nan;
IGS = nan;
MPA = -1;

IDT = IRTYPE(IBUF);

NPC = int16(IBUF(2));

IBL=IAND(int16(IBUF(NPC+1)),M4L);

if IBL < 1 || IBL > 4
    error(sprintf('Prelude-> Bad Block Type = %i',IBL))
end


%      NFR is the Number of Frequencies per Record.  IRG are the number
%     of range gates in this a-scan.  Assumes this cannot
%     change in the midst of a data block.
IRG = NGS(IBL);
NFR = MFR(IBL);

if IFRQ > NFR
    LSEC = -1;
    return
end


%      Determine which section of the data block we need
IOFF = IRG*(IFRQ-1) + NPC;


%      Check to see that there are legit data in this section
%     The 0x0E value in this position is 'end of data'
if (IBUF(IOFF+1) == 14)
    LSEC=-1;
    return
end

%      Polarization
IPOL = IAND(IBUF(NPC+1),M4H)/16;

%      Place the Prelude values in the correct Preface locations
%      for the old D256 format prefaces.
%      Frequency

PREFACE(20) = IAND(IBUF(IOFF+2),M4H)/16;
PREFACE(21) = IAND(IBUF(IOFF+2),M4L);
PREFACE(22) = IAND(IBUF(IOFF+3),M4H)/16;
PREFACE(23) = IAND(IBUF(IOFF+3),M4L);

%      The 1 kHz and 100 Hz positions are lost in MMM format.
PREFACE(24) = 0;
PREFACE(25) = 0;

%      Frequency Search i
PREFACE(52) = IAND(IBUF(IOFF+4),M4H)/16;

FREQ = FRQ_D256(PREFACE);
% FREQ = FRQ_DPS(PREFACE(20:23),PREFACE(52));


%      AutoGain G*
IGS = IAND(IBUF(IOFF+4),M4L);

PREFACE(53) = IGS;

%      The time is more of a problem, because we can roll over seconds.
%      Also, since we re-decode the preface after each frequency, we have
%      to save the time deltas over the whole block.
if IFRQ == 1
    MININC = 0;
end
%         *******BUG********
%      This will NOT roll over minutes into hours, etc. so a measurement that
%      spans an hour in the middle of the data block will have bad time.
%      by having more than 60 minutes in the hour.
%      Some decoders can handle this.

ISEC = UNP_BCD2(IBUF(IOFF+5));
if (ISEC < LSEC)
    MININC = MININC + 1;
end
PREFACE(9) = PREFACE(9) + MININC;
if PREFACE(9) > 9
    PREFACE(8) = PREFACE(8) + 1;
    PREFACE(9) = PREFACE(9) - 10;
end

PREFACE(10) = IAND(IBUF(IOFF+5),M4H)/16;
PREFACE(11) = IAND(IBUF(IOFF+5),M4L);
LSEC = ISEC;

%      The MPA
MPA = IBUF(IOFF+6);


