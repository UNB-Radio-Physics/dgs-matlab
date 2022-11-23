function Output = PZA2ZN(PZA)
%      Compute the Zenith Angle from the PZA byte.
%
%     Zenith is in the 16's and 32's bit of the 0PVZAAAA bits in PZA
Output = 0.0;

if (IAND(PZA,int16(32)) ~=0 )
    %         This is overhead
    Output = 0.0;
elseif(IAND(PZA,int16(16)) == 0)
    %         Small zenith angles
    Output = 11.0;
else
    %         Large zenith angles
    Output = 22.0;
end