function [NRG, RGT] = RG_D256(PREFACE)
%      Given the PREFACE, returns the number of range gates
%      and their values

HTBL = [2.5, 5.0, 10.0, 2.5, 0.0, 0., 0., 0.,...
    2.5, 5.0, 10.0, 2.5, 5.0, 0., 0., 0.]; % zero indexed

ETBL  = [10.0, 60.0, 160.0, 380.0, 760.0];

RGT = zeros(256,1);
%      The range gates are determined by preface parameters H and E
%      as defined in the Digisonde 256 "Green Book"
IH = PREFACE(54);
IE = PREFACE(55);

if (IH < 0) || (IH > 15) || (IE < 1) || (IE > 5)
    warning('DGS:UndefinedRageGates',...
        'Undefined range gates H= %i E=%i',IH,IE)
    NRG = 0;
    return
end

if (IH >= 8)
    NRG = 256;
else
    NRG = 128;
end

%      The standard linear range gate modes
for I = 1:NRG
    RGT(I) = ETBL(IE) + double(I-1)*HTBL(IH+1);
end

%      Now the bi-linear modes. IBL is the # of gates at the lower ranges
IBL = 0;
if (IH == 3)
    IBL = 40;
elseif ((IH == 11) || (IH == 12))
    IBL = 128;
end

%      For all these modes the RG spacing is double for the upper gates
if (IBL == 0)
    return
end

for I = 1:IBL
    RGT(I) = ETBL(IE) + double(I-1)*HTBL(IH+1);
end

for I = IBL+1:NRG
    RGT(I) = ETBL(IE) + 2.0*double(I-1)*HTBL(IH+1);
end
