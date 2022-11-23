function Output = S2PZA(PREFACE,ISTAT)
%      Convert Status to PZA byte using the ZT tables, Corrected for L

%      Ignore the high bit on Z
Z = IAND(PREFACE(46),int16(7));

%      Ignore the 4 bit on T
T = PREFACE(47);
TE = IAND(T,int16(3)) + IAND(T,int16(8))/2;

%      The 'effective' status, ignoring the high bit and shifted to
%      the range 1-8
ISE = IAND(ISTAT,int16(7))+1;

Output = IZT(Z,TE,ISE);

%      Correct for L
L = int16(PREFACE(45));

if ((L == 0) || (L > 12))
    %        These are odd single-antnena or non-beamforming modes
else
    %         The impact of L is to increment the AAAA portion of the
    %        0PVZAAAA byte in S2PZA, with 13 wrapping back to 1, etc.
    LR = IAND(Output,int16(15));
    LR = LR + (L-1);
    if (LR > 12)
        LR = LR - 12;
    end
    Output = IAND(Output,int16(240)) + LR;

end