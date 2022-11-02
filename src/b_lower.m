function b = b_lower(ibyte)

M4L=int16(15);

b = bitand(int16(int8(ibyte)),M4L);

end