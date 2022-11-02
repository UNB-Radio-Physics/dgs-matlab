
function BCD = UNP_BCD2(IBYTE)
% C
% C     Unpacks a 2-digit packed BCD character out of IBYTE
% C
% C     28Jul04   T. Bullett  AFRL
% C
% C
% C====+==================================================================+==
% C
if ~isa(IBYTE,'int8'); error('Type mismatch'); end
% C
   M4L=int16(15);
   
   M4H=int16(240);
    ST = int16(16);

      BCD=int16(10)*bitand(int16(IBYTE),M4H)/ST + bitand(int16(IBYTE),M4L);
%       RETURN
%       END
% C
% C====+==================================================================+==
% C