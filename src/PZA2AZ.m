function Output = PZA2AZ(PZA)
%      Compute the Azimuth Angle from the PZA byte.
% 
%      Azimuth is in the low 4 bits of the 0PVZAAAA bits in PZA

      Output = 0.0;
      IA = IAND(PZA,int16(15));

%      Check for special cases.
      if (IA == 0)
         Output = 0.0;
      elseif (IA < 13) 
         Output = 30.0 * double(IA-1);
      else
         error('DGS:Azimuth','Error in PZA value %f', PZA)
      end

      return