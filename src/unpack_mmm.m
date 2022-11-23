function [Time,Freq,Range,Amp,Polar,Noise,Doppler,Phase,Azimuth,Zenith] = unpack_mmm(ibuf)

clear('UNPACK_MMM')
clear('PRELUDE_MMM')
MAPCH = int16(-1);
NCHAN = 1;

j = 0;
while true
    [PREFACE,TIME,FREQ,MPA,EAMPS,EPHASE,IC,RGT,MAXRBIN,FNOISE] ...
        = UNPACK_MMM(ibuf);

    if j == 0
        Time = repmat(NaT,31*MAXRBIN,1);
        Freq = nan(31*MAXRBIN,1);
        Range = nan(31*MAXRBIN,1);
        Amp = nan(31*MAXRBIN,1);
        Polar = nan(31*MAXRBIN,1);
        Noise = nan(31*MAXRBIN,1);
        Doppler = nan(31*MAXRBIN,1);
        Phase = nan(31*MAXRBIN,1);
        Azimuth = nan(31*MAXRBIN,1);
        Zenith = nan(31*MAXRBIN,1);
    end

    if isnan(FREQ)
        break
    end
    [FRQ,APOL,HDOP,AZ,ZN,NBEAM,NDOPP] = CHANNEL_MAP(PREFACE);
    
    if (FNOISE == 0.0)
        FNOISE=AMPV(EAMPS,IC,NCHAN,MAPCH,MAXRBIN);
    end

    I = 1:MAXRBIN;
    J = repmat(1,size(I));
    ICS = IC(I);
    K = sub2ind(size(EAMPS),I(:),ICS);
    Time(j*MAXRBIN + I) = reshape(TIME(J),[],1);
    Freq(j*MAXRBIN + I) = reshape(FRQ(J),[],1);
    Range(j*MAXRBIN + I) = reshape(RGT(I),[],1);
    Polar(j*MAXRBIN + I) = reshape(APOL(ICS),[],1);
    Noise(j*MAXRBIN + I) = reshape(FNOISE(J),[],1);
    Doppler(j*MAXRBIN + I) =  reshape(HDOP(ICS),[],1);
    Azimuth(j*MAXRBIN + I) = reshape(AZ(ICS),[],1);
    Zenith(j*MAXRBIN + I) = reshape(ZN(ICS),[],1);
    Amp(j*MAXRBIN + I) = reshape(EAMPS(K),[],1);
    Phase(j*MAXRBIN + I) = reshape(EPHASE(K),[],1);

    j = j+1;
end

k = isnan(Freq);
Time(k) = [];
Freq(k) = [];
Range(k) = [];
Polar(k) = [];
Noise(k) = [];
Doppler(k) = [];
Azimuth(k) = [];
Zenith(k) = [];
Amp(k) = [];
Phase(k) = [];
