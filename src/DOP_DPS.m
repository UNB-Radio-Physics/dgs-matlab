
function dop = DOP_DPS(NDOP,PREFACE)
% C
% C
% C     Compute the Doppler shift of Doppler Number NDOP for the DPS ionogram
% C     with PREFACE.  Note the CIT value in the Preface is not useful for 
% C     this purpose.  It is said to be OK in drift modes, but not ionograms.
% C
% C     10Aug04  TWB
% C
% C====+==================================================================+==
% % C
%       INTEGER NDOP
%       INTEGER*1 PREFACE(57)
% C
%       REAL CIT,PRF
%       INTEGER NFFT,NPOL,NCOMP,NSSTEP,IX,IN,IS
% C

      DOPTAB = single([-7., -5., -3., -1., +1., +3., +5., +7.]);

% C     Number of small steps
      IS = UNP_BCD2(PREFACE(27));
      NSSTEP = int16(1);
      if(IS > int16(1)); NSSTEP = IS; end
% C
% C     Phase Code.  Only works for complementary and short pulse
      NCOMP = int16(1);
      IX = UNP_BCD2(PREFACE(28));
      if (IX == 1); NCOMP = int16(2); end
% C
% C     Polarization
      NPOL = int16(2);
      IA = UNP_BCD2(PREFACE(29));
      if(IA > int16(7)); NPOL=int16(1); end
% C
% C     FFT Size
      IN = UNP_BCD2(PREFACE(30));
      NFFT = 2.^(IN);
% C
% C     Pulse Repetition Frequency
      PRF = single(UNP_BCD4(PREFACE(31),PREFACE(32)));
      PRF = max(1.0,PRF);
      
      CIT = single(NFFT*NPOL*NCOMP)./PRF;

      dop = DOPTAB(NDOP+1)./(2.0*CIT);

      