function FREQ = FRQ_D256(PREFACE)
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
%              into the MMM format Prelude.  Actual frequency used is
%              lost.  A value of 0 is chosen.


I = PREFACE(56);
%      II is the actual value of I used for this frequency
II = PREFACE(52);

if II == 15
    II = 0*II;
end

%      Frequency digits in in preface locations 20-25
%      PREFACE(20) = 10.0    MHz
%      PREFACE(21) =  1.0    MHz
%      PREFACE(22) =  0.1    MHz (100 kHz)
%      PREFACE(23) =  0.01   MHz ( 10 kHz)
%      PREFACE(24) =  0.001  MHz (  1 kHz)
%      PREFACE(25) =  0.0001 MHz (100 Hz)

FREQ = 0.0;
if any(PREFACE(20:24)<0)
0;
end
for J = 1:-1:-4
    FREQ = FREQ + (10.0.^J) .* double(PREFACE(21-J));
end

% It appears that this isn't used in SAO Explorer
% DELF = 0.00250;
% 
% if I == 0
%     
% elseif I == 1
%     DELF = DELF + 0.020;
% elseif I == 2
%     DELF = DELF + 0.010*double(II);
% elseif I == 3
%     DELF = DELF + 0.020*double(II);
% end

DELF = 0;
FREQ = FREQ + DELF;









