function Output = IAND(A,B)
% wrapper for bitand which automagically uses the largest integer size

if ~(isa(A,'integer') && isa(B,'integer'))
error('Both A and B must be int')
end

cA = class(A);
cB = class(B);

sizeA = str2double(regexp(cA,'(?<=int).*','match','once'));
sizeB = str2double(regexp(cB,'(?<=int).*','match','once'));

if sizeA > sizeB
    B = eval([cA,'(B)']);
elseif sizeB > sizeA
    A = eval([cB,'(A)']);
end
    
Output = bitand(A,B);