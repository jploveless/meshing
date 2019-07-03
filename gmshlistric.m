function p = gmshlistric(edgex, edgey, edgez, top, bot, ls1, ls2, fs1, fs2, sz)
% gmshplane  Makes a triangulated listric fault in Gmsh. 
%    p = gmshsurface(edgex, edgey, edgez, top, bot, ls1, ls2, fs1, fs2, sz)
%    creates a triangulated mesh structure using Gmsh for the surface defined
%    by the edge coordiantes input variables. edgex, edgey, edgez are 
%    vectors giving all edge coordinates. top, bot, ls1, ls2, fs1, and fs2 are 
%    vectors giving the indices of the edge coordinate arrays to define
%    the top, bottom, listric sides, and flat sides of the surface. The element
%    size is given by sz. 
%   

np = length(edgex); % Number of points
alledge = [top(:); ls1(:); fs1(:); bot(:); fs2(:); ls2(:)]; % All edges
edgeend = cumsum([length(top), length(ls1), length(fs1), length(bot), length(fs2), length(ls2)]); % Edge indices
edgebeg = [1 edgeend(1:end-1)+1]; 

% Write coordinates to Gmsh .geo file
%fn = sprintf('junk%g', rem(now, 1));
fn = 'junk';
fid = fopen([fn '.geo'], 'w');
fprintf(fid, 'charl = %g;\n', sz); % Write element size
% Write points: top then bottom
fprintf(fid, 'Point(%g) = {%g, %g, %g, charl};\n', [1:np; edgex(:)'; edgey(:)'; edgez(:)']);
% Write lines: top, listric side 1, flat side 1, bottom, flat side 2, listric side 2
for i = 1:6,
   edge = alledge(edgebeg(i):edgeend(i));
   fprintf(fid, 'BSpline(%g) = {%g', i, edge(1));
   fprintf(fid, ', %g', edge(2:end));
   fprintf(fid, '};\n');
end
% Extra line that divides plane from curved surface
fprintf(fid, 'Line(7) = {%g, %g};\n', fs1(1), fs2(2));

% Circulate lines and create plane
fprintf(fid, 'Line Loop(1) = {1, 2, 7, 6};\nSurface(1) = {1};\n');
fprintf(fid, 'Line Loop(2) = {3, 4, 5, -7};\nSurface(2) = {2};\n');
fclose(fid);

% Mesh using Gmsh
p = gmsh([fn '.geo']);

% Remove temp files
%system(sprintf('rm %s*', fn));
