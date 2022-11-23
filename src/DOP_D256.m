function [NDOPP, DFR] = DOP_D256(PREFACE)
%      Determines the number and spacing (Doppler Frequency Resolutuion) of
%      the Ionogram Doppler bins.
%      Some principles:
%       - The maximum number of unique Doppler lines is 16 [-8..8]
%       - There is never a zero Doppler in a D256.
%       - The Doppler spectrum is always symmetric about zero

%       INTEGER*1 PREFACE(57)
%       INTEGER NDOPP,NDT(0:3,4),I,J,IT,IH,IX,IT2,IN,IR,IW
%       INTEGER IDC,NB,NPB,ISM
%       REAL CIT,DFR
%       LOGICAL H8, X123, X04567, X8, IT4
%       REAL PRF_D256

%      Preface Parameters
IT = PREFACE(47);
IT2 = IAND(IT,int8(3));
IH = PREFACE(54);
IX = PREFACE(44);
IN = PREFACE(48);
IR = PREFACE(49);
IW = PREFACE(50);
IT4 = (IAND(IT,int8(4)) ~= 0);

NDOPP = 0;

% C     This is the enumeration of Table 5.7, p96 in the 'Green Book"
NDT = int16(zeros(4,4));
for I = 0:3
    for J=1:4
        NDT(I+1,J) = int16(16/2^(I+J));
    end
end

%      Some logicals to help decide which column of NDT() to use
H8 = (IH >= 8);
X8 = (IX >= 8);
X123 = (IX == 1) || (IX == 2) || (IX == 3);
X04567 = (IX == 0)  || ((IX >=4)  && (IX <=7));

if ((~H8)  && X04567)
    %         H<8;X=0,4,5,6,7
    IDC = 1;
elseif((~X8  && X123)   ||  (X8  && X04567))
    %         H<8;X=1,2,3 -or- H>=8;X=0,4,5,6,7
    IDC = 2;
elseif(~(H8  || X8)  || (H8  && X123))
    %         X<8;X>=8 or H>=8;X=1,2,3
    IDC = 3;
elseif(H8  && X8)
    %         H>=8; X>=8
    IDC = 4;
else
    IDC = 1;
    warning('DGS:DopplerTable','Doppler Table Error..')
end

NDOPP = 2*NDT(IT2+1,IDC);

%      NB is the 'Number of Beams' or simultaneous interlaced signals
if (NDOPP == 0)
    NB = 0;
else
    NB = 16/NDOPP;
end

%      NPB is the Number of Pulses per Beam
NPB = 2^(int16(IN)+1);

%      ISM is the Number of Sample adjuster for the W parameter
%                      **** untested ****
if (IAND(IW,int16(2)) == 0)
    ISM = 1;
else
    ISM = 2;
end

%      Determine the Coherent Integration Time (CIT,sec)
CIT=double(NB)*double(NPB)*double(ISM)/PRF_D256(IR);
%      Now the Doppler Frequency Resolution, which is also the spacing.
DFR = 1.0;

if (CIT ~= 0.0)
    DFR = 0.50/CIT;
end

if (IT4)
    DFR = 2.0*DFR;
end


