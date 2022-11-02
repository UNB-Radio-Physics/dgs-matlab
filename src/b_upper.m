function b = b_upper(ibyte)

   
   M4H=int16(240);
    ST = int16(16);

b = bitand(int16(int8(ibyte)),M4H)/ST;

end