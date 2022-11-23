function Output = PRF_D256(IR)
%     Determine the Pulse Repetition Frequency (PRF) of a D256
%     from the R preface parameter

      IR3 = IAND(IR,int16(3));

      if (IR3 == 0)
         Output = 50.0;
      elseif (IR3 == 1)
         warning('DGS:IllegalPRF',"Illegal PRF R= %i",IR)
         Output = 100;
      elseif (IR3 == 2)
         Output = 100.0;
      else
         Output = 200.0;
      end
