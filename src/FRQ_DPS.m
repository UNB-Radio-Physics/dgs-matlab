function Output = FRQ_DPS(IFY, I)
%      Function retuns the actual radio frequency used for sounding,
%      including the adjustments for frequency search, if enabled.
%      NOTE: This does NOT exactly work for closely spaced frequency mode
%      (aka Precision Group Height mode) 
% 
%      ISSUE:  The documentation is inconsistent with itself and with
%              experience.  Actual values observed are 0,1,2 and F
%      11Apr02  TWB
%              I* = F is an indicator that the frequency is restricted
%              This was a Processor hack to get info on restricted frequencies
%             into the MMM format Prelude.  Actual frequency used is
%              lost.  A value of 0 is chosen.
% 
%      28Jul04 TWB Adapted for the DPS MMM format data which does not have
%                  this info in the preface.
% 

     DFTABLE = [-20.0, -10.0, 0.0, +10.0, +20.0];

%      II is the actual value of I used for this frequency
      II=0.*I;
      if ((I> 0) && (I < 5)) 
          II = I;
      end


      FREQ=0.0;

      for J=1:-1:-2
         FREQ=FREQ + double(10.0^J*IFY(2-J));
      end

      DELF = 0.001*DFTABLE(II+1);

      Output = FREQ + DELF;







