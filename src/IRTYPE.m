function irtype = IRTYPE(ibuf)
% 	This function takes the Digisonde 256/DPS data block in IBUF and
% 	determines the actual data type (Ionogram, Ionogram continuation,
% 	Drift, Artist, Raw Ionogram) and returns it as the function value.
% 	If the data block is not one of these types (ie unknown) the
% 	function returns a zero value for the recordtype.
% 
%        NOTE: Due to a bug in the recording of 16 channel data in Artist3
%          circa 2001, where the record type is not encoded into the 4 lowest
%          bits of the first byte of every 8K block, this routine must be
%          specific to 16 channel data and also VERY FRAGILE!
% 
%        Empirically, this function returns a recordtype of 1 for what is
%        supposed to be Recordtype 0x0C.
%        Unknown what happens for Recordtype 0x0D
% 
%        Revision History
%        07Aug04 TWB - Added SBF and RSF block types.
%        12Jan08 TWB - Added FF as a valid value for the 3rd byte
% 
M4L = int16(15);
M1L = int16(1);
ICC = int16(204);
IFE = int16(-2);
IFF = int16(-1);

% C	Make the first cut at the record type.
IRT = bitand(int16(ibuf(1)),M4L);

OK = false;

if IRT == 9 || IRT == 8
    % 	   Verify that this is MMM data.
    % 	   The third character in the block should be zero.
    OK = ibuf(3) == 0;
elseif IRT == 10 || IRT == 12 || IRT == 13
    %       For raw data types, extract the record type from the least
    %	   significant bits of the first 4 words, and compare that with
    % 	   the record type. This is less absolute than the Ionogram method.
    KRT = int8(0);
    for i = 0:3
        KRT = KRT + bitor(KRT,bitshift(bitand(ibuf(i+1),int8(M1L)),i));
    end
    OK = KRT == IRT;
elseif IRT == 3 || IRT == 2
    %	   Verify that this is SBF data.
    %	   The third character in the block should be FE or FF.
    OK = (ibuf(3) == IFE) || (ibuf(3) == IFF);
elseif IRT == 7 || IRT == 6
    %	   Verify that this is RSF data.
    %	   The third character in the block should be FE or FF.
    OK = (ibuf(3) == IFE) || (ibuf(3) == IFF);
elseif IRT == 15
    %	   For ARTIST, the 4th and 5th bytes should be Hex CC
    OK = (ibuf(4) == ICC) && (ibuf(5) == ICC);
end

if OK
    irtype = IRT;
else
    error('Record data does not match expected type')
end





