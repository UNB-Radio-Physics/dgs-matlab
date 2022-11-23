function [FRQ,APOL,HDOP,AZ,ZN,NBEAM,NDOPP] = CHANNEL_MAP(PREFACE)
%       SUBROUTINE CHANNEL_MAP(PREFACE, FRQ,APOL,HDOP,AZ,EL,NBEAM,NDOPP)
% C
% C     T. Bullett, AFRL, 18 January 2002
% C
% C     This subroutine performs the rather complex task of supplying the
% C     'meta-data' for the 16 channels of the 16 channel Digisonde 256
% C     data.  The meta-data, or data about data, provide information on the
% C     context of these different channels.  For the Digisonde 256, the
% C     'channel number' can specify Polarization, Doppler and Arrival Angle.
% C     It is the precise values of these that this routine computes, based
% C     instrument settings.
% C     There are lots of caviats here, mostly falling in categoryies:
% C       A) That particular setting was not coded or debugged
% C       B) Your Digisonde may have different values in its PROMs or
% C          was installed differently.
% C     The numerical values of polarization are set to +-90.0 to be
% C     consistent with the 'chirality' factor of the Dynasonde
% C       -90.0  is Ordinary  ; +90.0 is eXtraordinary
% C        (J.W. Wright, private communication)
% C
% C     Output tables are indexed by the channel number(1-16) and contain:
% C       FRQ  - Sounding Frequency (MHz)
% C       APOL - Rx Antenna Polarization Mode O (-90.0 )or X (+90.0)
% C       HDOP - Doppler shift, Hz
% C       AZ   - Rx antenna beam azimuth, degrees
% C       EL   - Rx antenna beam elevation, degrees
% C       PZA  - The PZA or 'Meaning' byte defined by UMLCAR (cf Galkin 2001)
% C
% C     Internal Variables
% C       IBM(4) - Beam Mask to determine which channels are different beams
% C       IST(16) - Status Table as a function of channel #
% C       IS2RD(4,16) - Status to Relative Doppler Shift
% C       IRDOP(16) - Relative Doppler Shift, in 'bins'
% C       IB  - Beam #
% C       IDD - Doppler Number
% C
% C     11Apr02 TWB
% C        Added an array for the sounding frequency of each channel.
% C        This is needed to support Precision Group Height (PGH) modes.
% C         *** CURRENTLY UNIMPLEMENTED DUE TO LACK OF TEST DATA **
% C     24Jul08 TWB
% C        Code review.  Some comments added.
% C
% C     Working with the 4 bit status number, the IDX upper bits
% C     are for Doppler, 4-IDX lower bits are IB 'beams'.
% C     The relative Doppler index is the upper IDX
% C     bits of the Status.  The high bit of these is the sign
% C     of the Doppler shift (1=negative).
% C     This is embodied in the IS2RD table.
% C     Example:  For a T=1 ionogram (O/X and 8 Dopplers), the
% C               4 status bits are SDDB where
% C               S  = Doppler sign
% C               DD = Doppler Magnitude (kind of)
% C               B  = Beam number (O or X)
% C
% C     * * * W A R N I N G * * * THIS DOES NOT WORK FOR 256 HEIGHTS
% C     I HAVE NOT BEEN ABLE TO FIGURE OUT HOW 256 HEIGHT DATA ARE
% C     PLACED INTO THE 16 CHANNELS.  I THINK IT IS EVEN/ODD
% C
% C
% C====+==================================================================+==
% C

IBM = int16([7,3,1,0]);

% ----- Channel to Status Table
%
IC2S = int16([ ...
    [8, 9,10,11,12,13,14,15,0, 1, 2, 3, 4, 5, 6, 7]; ... % T=3 (8 beams, 2 Dopplers)
    [8, 9,10,11,12,13,14,15,4, 5, 6, 7, 0, 1, 2, 3]; ... % T=2 (4 beams, 4 Dopplers)
    [8, 9,10,11,12,13,14,15,6, 7, 4, 5, 2, 3, 0, 1]; ... % T=1 (2 beams, 8 Dopplers)
    [8, 9,10,11,12,13,14,15,7, 6, 5, 4, 3, 2, 1, 0]]); % T=0 (1 beam, 16 Dopplers)

%     Status to Relative Doppler number.  The first index is
%     opposite in sense to the previous table.
% dim 2 is 0-indexed!
IS2RD = int16([ ...
    [-1, -1, -1, -1, -1, -1, -1, -1, 1,  1,  1,  1,  1,  1,  1,  1]; ... T=3 (8 beams, 2 Dopplers)
    [-2, -2, -2, -2, -1, -1, -1, -1, 1,  1,  1,  1,  2,  2,  2,  2 ]; ... % T=2 (4 beams, 4 Dopplers)
    [-4, -4, -3, -3, -2, -2, -1, -1, 1,  1,  2,  2,  3,  3,  4,  4]; ... % T=1 (2 beams, 8 Dopplers)
    [8, -7, -6, -5, -4, -3, -2, -1, 1,  2,  3,  4,  5,  6,  7,  8]]); %  T=0 (1 beam, 16 Dopplers)

%      Get the number and spacing for the doppler lines.
[NDOPP, DFR] = DOP_D256(PREFACE);
NBEAM = 16/NDOPP;

%      IDX gives us the Channel-to-Status Table and the
%      Status-to-Relative-Doppler Table row number to use
%      What I do here is make IDX the log base 2 of NDOPP
IDX = log2(double(NDOPP));

HDOP = zeros(16,1);
APOL = zeros(16,1);
AZ = zeros(16,1);
ZN = zeros(16,1);
FRQ = zeros(16,1);

for ICH=1:16
    %         The 'status' value for each channel
    IST = IC2S(IDX,ICH);
    %         Beam # for this channel
%     IB = IAND(IBM(IDX),IST);
    %         Relative Doppler for this 'status'
    IDD = IS2RD(IDX, IST+1); % zero-indexed
%     IRDOP(ICH) = IDD;
    HDOP(ICH) = DFR*double(IDD);

    %         Doppler table is complete.

    %         Now look up the non-Doppler metadata by the Beam#
    %         using the 'PZA Byte' concept (c.f. Galkin)
    PZA = S2PZA(PREFACE, IST);
    APOL(ICH) = PZA2POL(PZA);
    AZ(ICH) = PZA2AZ(PZA);
    ZN(ICH) = PZA2ZN(PZA);

end


%      Set the Frequencies.
III = PREFACE(56);
if (III < 4)
    %         Normal sounding mode
    FREQNOM = FRQ_D256(PREFACE);
    for I = 1:16
        FRQ(I) = FREQNOM;
    end
else
    %         PGH mode.  ****UNIMPLEMENTED****
    %         This is just a copy of the normal mode.
    warning('DGS:Unimplemented','PGH mode is not supported yet')
    FREQNOM = FRQ_D256(PREFACE);
    for I = 1:16
        FRQ(I) = FREQNOM;
    end
end
