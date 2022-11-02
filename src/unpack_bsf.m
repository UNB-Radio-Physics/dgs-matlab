function [Time,Freq,Range,Amp,Polar,Noise,Doppler] = unpack_bsf(ibuf)

DFTABLE = single([-20.0, -10.0, 0.0, +10.0, +20.0]);
GAINTABLE = int16([0,6,12,18,24,30,36,42]);
HNTABLE = int16([0, 6, 12]);
POLTAB = single([0.0, 0.0, 90.0, -90.0]);
NGS = int16([134,262,504,1008]);
MFR = int16([30, 15, 8, 4]);

DEG8=single(360.0/256.0);
MASK=int16(255);
MASKH=int16(248);
MASKL=int16(7);

preface = int8(zeros(57,1));

ml = int8(-1);

for i = 1:(ibuf(2)-3)
    preface(i) = bitand(ibuf(i+3),ml);
end

year = UNP_BCD2(preface(1));
doy = UNP_BCD4(preface(2),preface(3));
hour = UNP_BCD2(preface(6));
minute = UNP_BCD2(preface(7));
second = UNP_BCD2(preface(8));

if year<int16(82)
    year=year+2000;
else
    year=year+1900;
end

Time = datetime(sprintf('%04i %03i %02i %02i %02i',year,doy,hour,minute,second),'InputFormat','uuuu DDD HH mm ss');



NPrefaceChar = ibuf(2);
iBlockType=b_lower(ibuf(NPrefaceChar+1));
NRangeGates=NGS(iBlockType);
NumFreq = MFR(iBlockType);

iOffset= int16(NRangeGates)*int16(0:(NumFreq-1)) + int16(NPrefaceChar);
prelude = int8(zeros(6,NumFreq));

for i = 1:6
    prelude(i,:) = ibuf(i+iOffset);
end


Time = Time+ seconds(10*b_upper(prelude(5,:))+b_lower(prelude(5,:)));


iPolarization = b_upper(prelude(1,:));
Polar = POLTAB(iPolarization+1);

IFY(1,:) = b_upper(prelude(2,:));
IFY(2,:) = b_lower(prelude(2,:));
IFY(3,:) = b_upper(prelude(3,:));
IFY(4,:) = b_lower(prelude(3,:));
I = b_upper(prelude(4,:));
II=0.*I;
II((I>0) & (I<5)) = I((I>0) & (I<5));

MPA = UNP_BCD2(prelude(6,:));

J=1:-1:-2;
Freq = sum(10.^(J').*single(IFY),1) + 0.001*DFTABLE(II+1);


IGS = b_lower(prelude(4,:));
IG = UNP_BCD2(preface(40));
HINOISE = UNP_BCD2(preface(46));

if (IG <8)
    GAIN = GAINTABLE(IG+1);
else
    GAIN = GAINTABLE((IGS/2)+1);
end


AUTOGAIN = GAIN + HNTABLE(HINOISE+1);
GAIN = AUTOGAIN + HINOISE;
DBSCALE = single(3.0);

Noise=single(MPA)*DBSCALE + single(GAIN);

NOMRG = UNP_BCD4(preface(36),preface(37));
if (NOMRG == 128)
    NRG = 128;
elseif (NOMRG == 256)
    NRG = 249;
elseif (NOMRG == 512)
    NRG = 501;
end

StartRange = single(UNP_BCD4(preface(33),preface(34)));
RangeInc = single(UNP_BCD2(preface(35)));
if (RangeInc == 2.0); RangeInc = 2.5; end
% 
Range = StartRange+RangeInc.*(0:(NRG-1));
Range = repmat(Range(:),1,NumFreq);
Noise = repmat(Noise,NRG,1);
Time = repmat(Time,NRG,1);
Polar = repmat(Polar,NRG,1);
Freq = repmat(Freq,NRG,1);

IR = int16(1:NRG)';
IAX = iOffset+6+(1*(IR-1)+1);

Amp = DBSCALE*single(bitand(MASKH,int16(ibuf(IAX)))/int16(8)) + single(GAIN);
Doppler = DOP_DPS(bitand(MASKL,int16(ibuf(IAX))),preface);
return




end





