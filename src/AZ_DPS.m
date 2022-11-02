function AZ = AZ_DPS(NAZ,IRXCONF)

% C
% C====+==================================================================+==
% C
%       REAL FUNCTION AZ_DPS(NAZ,IRXCONF)
% C
% C
% C     Compute the Doppler shift of Doppler Number NDOP for the DPS ionogram
% C     with PREFACE
% C
% C 07Jun10 TWB - Updated from a dummy routine to have some meaning
% C
% C
% C====+==================================================================+==
% C
%       INTEGER NAZ
%       INTEGER IRXCONF

AZ = single(zeros(size(NAZ)));
%       IF ((NAZ<int16(1))||(NAZ<GT.6)) RETURN
% C
% C     Standard Configuration
if (IRXCONF==int16(3))
    AZ = 90 + 60.0*(NAZ-1);
    % C     Mirror
elseif (IRXCONF==int16(4))
    AZ = 270 - 60*(NAZ-1);
    % C     Rotated (D256)
elseif (IRXCONF==int16(1))
    AZ = 60 + 60.0*(NAZ-1);
else
    % C     Unknown or undefined
    AZ = 90 + 60.0*(NAZ-1);
end
AZ=single(AZ);
%       IF (AZ_DPS.GT. 360.0) THEN AZ_DPS=AZ_DPS-360.0
%       IF (AZ_DPS.LT. 000.0) THEN AZ_DPS=AZ_DPS+360.0
AZ(AZ>single(360))=AZ(AZ>single(360))-single(360);
AZ(AZ<single(0))=AZ(AZ<single(0))+single(360);

%       RETURN
%       END
% C
% C====+==================================================================+==
% C