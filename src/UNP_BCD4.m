function BCD = UNP_BCD4(IBYTE1,IBYTE2)
% C
% C     Unpacks a 4-digit packed BCD character out of IBYTE1 and IBYTE2
% C
% C     28Jul04   T. Bullett  AFRL
% C
% C
% C====+==================================================================+==
% C
if ~isa(IBYTE1,'int8'); error('Type mismatch'); end
if ~isa(IBYTE2,'int8'); error('Type mismatch'); end

      BCD=int16(1000)*b_upper(IBYTE1) + int16(100)*b_lower(IBYTE1) + ...
          int16(10).*b_upper(IBYTE2) + int16(1)*b_lower(IBYTE2);