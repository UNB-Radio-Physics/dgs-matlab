function data = read_sbf(filename)

data = [];

if ~exist(filename,'file')
    error('Ionogram file %s does not exist.',filename)
end

[Path,File,Ext] = fileparts(filename);


if ~strcmpi(Ext,'.SBF')
    error('Unrecognized file extension: %s',Ext);
end

fid = fopen(filename,'r');
ibuf = int8(fread(fid,'int8'));
fclose(fid);

NBlock = size(ibuf,1)/4096;
j=0;
for i = 1:NBlock
    
    ind = (1:4096)+(4096.*(i-1));
    [Time,Freq,Range,Amp,Polar,Noise,Doppler] = unpack_bsf(ibuf(ind));
    if i == 1
        data.time=Time(1)';
        d = zeros(NBlock.*numel(Time),9);
    end
    d(j+(1:numel(Time)),1) = Freq(:);
    d(j+(1:numel(Time)),2) = Range(:);
    d(j+(1:numel(Time)),3) = Polar(:);
    d(j+(1:numel(Time)),4) = Noise(:);
    d(j+(1:numel(Time)),5) = Doppler(:);
    d(j+(1:numel(Time)),8) = Amp(:);
    j=j+numel(Time);
end

[fr,~,ifr] = unique(d(:,1));
[he,~,ihe] = unique(d(:,2));
[pl,~,ipl] = unique(d(:,3));

Amplitude=single(accumarray([ifr(:),ihe(:),ipl(:)],d(:,8)));
Noise=single(accumarray([ifr(:),ihe(:),ipl(:)],d(:,4)));
Doppler=single(accumarray([ifr(:),ihe(:),ipl(:)],d(:,5)));
Azimuth=single(accumarray([ifr(:),ihe(:),ipl(:)],d(:,6)));
Zenith=single(accumarray([ifr(:),ihe(:),ipl(:)],d(:,7)));
Phase=single(accumarray([ifr(:),ihe(:),ipl(:)],d(:,9)));

clear('d');

data.Frequencies = single(fr);
data.Heights = single(he);

ix = find(pl>=89);
io = find(pl<=-89);

data.O_Amplitude = squeeze(Amplitude(:,:,io));
data.X_Amplitude = squeeze(Amplitude(:,:,ix));

data.O_Noise = squeeze(Noise(:,:,io));
data.X_Noise = squeeze(Noise(:,:,ix));

data.O_Doppler = squeeze(Doppler(:,:,io));
data.X_Doppler = squeeze(Doppler(:,:,ix));

data.O_Azimuth = squeeze(Azimuth(:,:,io));
data.X_Azimuth = squeeze(Azimuth(:,:,ix));

data.O_Zenith = squeeze(Zenith(:,:,io));
data.X_Zenith = squeeze(Zenith(:,:,ix));

data.O_Phase = squeeze(Phase(:,:,io));
data.X_Phase = squeeze(Phase(:,:,ix));





end