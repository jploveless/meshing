function pnew = trim_intersecting_meshes(p)



prop_int_els = ones(size(p.nEl));
trimcount = 0;
while sum(prop_int_els) ~= 0
   trimcount = trimcount + 1
   ends = cumsum(p.nEl);
   begs = [1; ends(1:end-1) + 1];
   
   % Get intersecting elements
   el_ints = intersecting_meshes(p);
   % Find proportion of mesh elements that intersect
   prop_int_els = zeros(size(p.nEl));
   for i = 1:length(begs)
      prop_int_els(i) = sum(el_ints(begs(i):ends(i)) > 0)./p.nEl(i);
   end
   
   % Find index of most intersecting mesh
   [max_prop, toss_mesh] = max(prop_int_els);
   if max_prop > 0
       % Redefine mesh structure eliminating the most intersecting mesh
       keep_els = setdiff(1:length(p.v), begs(toss_mesh):ends(toss_mesh));
       p = patchsubset(p, keep_els);
   end 
end
pnew = p;
