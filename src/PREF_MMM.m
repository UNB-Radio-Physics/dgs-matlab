function IPREF = PREF_MMM(IBUF)
%     Extract the preface for MMM format data.


ML = int8(15);
IPREF = int8(zeros(57,1));

IRT=IRTYPE(IBUF);

if ((IRT ~= 9) && (IRT ~= 8))
    error('pref_mmm --> Bad record type %i',IRT)

end

IPEND = int16(IBUF(2)) - 3;
for IP = 1:IPEND
    IPREF(IP) = 0;
    IE = IP+3;
    IPREF(IP) = IAND(IBUF(IE),ML);
end
