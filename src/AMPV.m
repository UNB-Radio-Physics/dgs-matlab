function Output = AMPV(EAMPS,IC,NCHAN,MAPCH,MAXRBIN)
%      Calculate the Amplitude Most Pobable Value as a proxy for the
%      noise floor of the Range-Doppler data in EAMPS
%      Data are expected in the range of 0 to 120 dB and binned in
%      3/8dB bins for 16C data and 3dB bins for MMM data .
%      The resolution, range and number of bins is hard-coded.  Sorry.
%
%      EAMPS -- Echo Amplitudes Array
%      IC    -- The single selected channel # for MMM data, for each range
%      NCHAN -- Number of Channels (1 or 16)
%      MAXRBIN -- Number of range bins
%      MAPCH  -- A binary map of channels to include in the analysis (16C only)
%                the 16 bits of the integer map to the 16 channels of the data.
%
%      18Mar03 TWB Modified for MMM and 16C data
%      29May03 TWB Added single&multi channel


XMIN = 0.0;
XMAX = 120.0;
NX = int16(zeros(351,1)); % zero-indexed

if(NCHAN == 1)
    DX = 3.0;
elseif (NCHAN == 16)
    DX = 3.0/8.0;
else
    DX = 1.0;
    warning('AMPV -> Bad # of channels %i',NCHAN)
end

%      Determine the bin #'s for the limits
NS = int16(XMIN/DX);
NE = int16(XMAX/DX);

NTOTAL=0;

%     Place the counts in the arrays
for J = 1:NCHAN
    if (IAND(MAPCH, int16(2^J)) ~= 0)
        for I = 1:MAXRBIN
            K=J;
            if (NCHAN == 1)
                K=IC(I);
            end
            IX = int16(EAMPS(I,K)/DX);
            IX = max(min(IX,NE),NS);
            NX(IX+1) = NX(IX+1) + 1;
            NTOTAL = NTOTAL + 1;
        end
    end
end

IX = 0;
J = 0;
Output = 0.0;
for I = NS:NE
    if (NX(I+1) > J)
        J = NX(I+1);
        IX = I;
    end
end
Output = XMIN + double(IX)*DX;
















