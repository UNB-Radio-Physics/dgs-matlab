function [Time,Freq,Range,Amp,Polar,Noise,Doppler,Phase,Azimuth,Zenith] = unpack_mmm(ibuf)

clear('UNPACK_MMM')
clear('PRELUDE_MMM')
MAPCH = int16(-1);
NCHAN = 1;

Time = datetime([],[],[]);
Freq = [];
Range = [];
Amp = [];
Polar = [];
Noise = [];
Doppler = [];
Phase = [];
Azimuth = [];
Zenith = [];

while true
    [PREFACE,TIME,FREQ,MPA,EAMPS,EPHASE,IC,RGT,MAXRBIN,FNOISE] ...
        = UNPACK_MMM(ibuf);
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
    Time = vertcat(Time,reshape(TIME(J),[],1));
    Freq = vertcat(Freq,reshape(FRQ(J),[],1));
    Range = vertcat(Range,reshape(RGT(I),[],1));
    Polar = vertcat(Polar,reshape(APOL(ICS),[],1));
    Noise = vertcat(Noise,reshape(FNOISE(J),[],1));
    Doppler = vertcat(Doppler, reshape(HDOP(ICS),[],1));
    Azimuth = vertcat(Azimuth,reshape(AZ(ICS),[],1));
    Zenith = vertcat(Zenith,reshape(ZN(ICS),[],1));
    Amp = vertcat(Amp,reshape(EAMPS(K),[],1));
    Phase = vertcat(Phase,reshape(EPHASE(K),[],1));

end