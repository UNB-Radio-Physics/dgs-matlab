function Output = PZA2POL(PZA)
%      Calculate the polarization based on the PZA byte
%      The numerical values of polarization are set to +-90.0 to be
%      consistent with the 'chirality' factor of the Dynasonde
%         (J.W. Wright, private communication)
% 
%      Polarizaion is in the 64's bit of the 0PVZAAAA bits in PZA

      if (IAND(PZA,int64(64)) == 0)
%         O Polarization
         Output = -90.0;
      else
%        X polarization
         Output = +90.0;
      end