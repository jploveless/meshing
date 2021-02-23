function [l, top] = meshleng(p)
% meshleng  Calculates lengths of surface portion of a meshed fault
%   L = meshleng(C, V) calculates the length of the surface trace of 
% 

% Mesh indices
ends = cumsum(p.nEl(:));
begs = [1; ends(1:end-1)+1];

% Length vector placeholder
l = zeros(length(p.nEl), 1);

% Define individual mesh from structure
for i = 1:length(p.nEl)
   pp = patchsubset(p, begs(i):ends(i)); 
   
   % Get ordered edges
   oe = OrderedEdges(pp.c, pp.v);
   top = sum(reshape(pp.c(oe, 3) == 0, size(oe))) == 2;
   l(i) = sum(sqrt(diff(pp.c(oe(:, top), 1)).^2 + diff(pp.c(oe(:, top), 2)).^2));
end
% Rearrange in 
top = oe(:, top);
if top(1, 1) == top(2, end)
   top = [top(:, 2:end), top(:, 1)];
end