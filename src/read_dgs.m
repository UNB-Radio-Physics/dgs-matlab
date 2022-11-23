function data = read_dgs(filename,RxAzimuthConfig)
% RxConf is optional, used to determine azimuth angle

data = [];

if ~exist(filename,'file')
    error('Ionogram file %s does not exist.',filename)
end

[Path,File,Ext] = fileparts(filename);


if ~ismember(upper(Ext),{'.SBF','.RSF','.MMM','.GRM'})
    error('Unrecognized file extension: %s',Ext);
end

if ~exist('RxAzimuthConfig','var')||isempty(RxAzimuthConfig)
    RxAzimuthConfig=1;
%     warning('No receiver azimuth configuration provided, assuming default configuration\n')
end


fid = fopen(filename,'r');
ibuf = int8(fread(fid,'int8'));
fclose(fid);

NBlock = size(ibuf,1)/4096;
j=0;
n=0;
lastFreq = inf;

for i = 1:NBlock

    ind = (1:4096)+(4096.*(i-1));

    IRT = IRTYPE(ibuf(ind));

    if IRT == 3 || IRT == 2
        [Time,Freq,Range,Amp,Polar,Noise,Doppler] = unpack_bsf(ibuf(ind));
        Phase = nan(size(Time));
        Azimuth = nan(size(Time));
        Zenith = nan(size(Time));
    elseif IRT == 7 || IRT == 6
        [Time,Freq,Range,Amp,Polar,Noise,Doppler,Phase,Azimuth] = unpack_rsf(ibuf(ind),RxAzimuthConfig);
        Zenith = nan(size(Time));
    elseif IRT == 9 || IRT == 8
        
        [Time,Freq,Range,Amp,Polar,Noise,Doppler,Phase,Azimuth,Zenith] = unpack_mmm(ibuf(ind));
    else
        error('type not implemented')
    end

    if i == 1
        d = zeros(NBlock.*numel(Time),10);
    end

    if min(Freq(:)) < lastFreq
        n = n+1;
        data(n).time=Time(1)';
    end
    lastFreq = min(Freq(:));

    d(j+(1:numel(Time)),1) = Freq(:);
    d(j+(1:numel(Time)),2) = Range(:);
    d(j+(1:numel(Time)),3) = Polar(:);
    d(j+(1:numel(Time)),4) = Noise(:);
    d(j+(1:numel(Time)),5) = Doppler(:);
    d(j+(1:numel(Time)),6) = Azimuth(:);
    d(j+(1:numel(Time)),7) = Zenith(:);
    d(j+(1:numel(Time)),8) = Amp(:);
    d(j+(1:numel(Time)),9) = Phase(:);
    d(j+(1:numel(Time)),10) = n;
    j=j+numel(Time);
    
end

d(all(d==0,2),:) = [];


[fr,~,ifr] = unique(d(:,1));
[he,~,ihe] = unique(d(:,2));
[pl,~,ipl] = unique(d(:,3));
[tm,~,itm] = unique(d(:,10));

Amplitude=single(accumarray([ifr(:),ihe(:),ipl(:),itm(:)],d(:,8)));
Noise=single(accumarray([ifr(:),ihe(:),ipl(:),itm(:)],d(:,4)));
Doppler=single(accumarray([ifr(:),ihe(:),ipl(:),itm(:)],d(:,5)));
Azimuth=single(accumarray([ifr(:),ihe(:),ipl(:),itm(:)],d(:,6)));
Zenith=single(accumarray([ifr(:),ihe(:),ipl(:),itm(:)],d(:,7)));
Phase=single(accumarray([ifr(:),ihe(:),ipl(:),itm(:)],d(:,9)));

clear('d');

for n = 1:numel(data)

    data(n).Frequencies = single(fr);
    data(n).Heights = single(he);

    ix = find(pl>=89);
    io = find(pl<=-89);

    data(n).O_Amplitude = squeeze(Amplitude(:,:,io,n));
    data(n).X_Amplitude = squeeze(Amplitude(:,:,ix,n));

    data(n).O_Noise = squeeze(Noise(:,:,io,n));
    data(n).X_Noise = squeeze(Noise(:,:,ix,n));

    data(n).O_Doppler = squeeze(Doppler(:,:,io,n));
    data(n).X_Doppler = squeeze(Doppler(:,:,ix,n));

    data(n).O_Azimuth = squeeze(Azimuth(:,:,io,n));
    data(n).X_Azimuth = squeeze(Azimuth(:,:,ix,n));

    data(n).O_Zenith = squeeze(Zenith(:,:,io,n));
    data(n).X_Zenith = squeeze(Zenith(:,:,ix,n));

    data(n).O_Phase = squeeze(Phase(:,:,io,n));
    data(n).X_Phase = squeeze(Phase(:,:,ix,n));

end



end