function [np2, isects] = meshisect(p, p2)
% meshisect  Finds intersecting meshes and deletes smaller one(s)
%   np2 = meshisect(p1, p2) finds meshes within p2 that intersect meshes
%   in p1 and returns a cleaned version of p2 without intersecting meshes
%   to np2. 
%

% Mesh indices
ends = cumsum(p.nEl(:));
begs = [1; ends(1:end-1)+1];

ends2 = cumsum(p2.nEl(:));
begs2 = [1; ends2(1:end-1)+1];

% Record of elements to keep; will update with false
keep = true(sum(p2.nEl), 1); 

% Loops through each fault of the first set
for i = 1:length(p.nEl)
   % Define focus fault
   pp = patchsubset(p, begs(i):ends(i));
   % Find edge coordinates
   oe = OrderedEdges(pp.c, pp.v);
   % Find second set coordinates within this focus fault
   in = inpolygon(p2.c(:, 1), p2.c(:, 2), pp.c(oe(1, :), 1), pp.c(oe(1, :), 2));
   % Determine which second entity internal coordinates belong to
   inv = find(sum(ismember(p2.v, find(in)), 2) > 0); % Elements with an internal coord
   for j = 1:length(inv)
      m2idx = find(begs2 <= inv(j) & ends2 >= inv(j)); % Which entity does the element belong to
      keep(begs2(m2idx):ends2(m2idx)) = false; % Delete the whole entity
   end
end

% Take subset of p2
np2 = patchsubset(p2, keep);   