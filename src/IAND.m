function Output = IAND(A,B)
% wrapper for bitand which automagically uses the largest integer size

if ~(isa(A,'integer') && isa(B,'integer'))
    error('Both A and B must be int')
end

cA = class(A);
cB = class(B);

if strcmpi(cA, 'int8')
    sizeA = 8;
elseif strcmpi(cA, 'int16')
    sizeA = 16;
else
    sizeA = str2double(regexp(cA,'(?<=int).*','match','once'));
end

if strcmpi(cB, 'int8')
    sizeB = 8;
elseif strcmpi(cB, 'int16')
    sizeB = 16;
else
    sizeB = str2double(regexp(cB,'(?<=int).*','match','once'));
end


if sizeA == sizeB
    Output = bitand(A,B);
    return
elseif sizeA > sizeB
    if sizeA == 16
        B = int16(B);
    else
        B = eval([cA,'(B)']);
    end
elseif sizeB > sizeA
    if sizeB == 16
        A = int16(A);
    else
        A = eval([cB,'(A)']);
    end
end

Output = bitand(A,B);