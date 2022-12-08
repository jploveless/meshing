function [c, nc] = extractcoords(file, depth)
% extractcoords   Extracts and organizes coordinates from an ArcGIS text file.
%   p = extractcoords(FILE, DEPTH) extract coordinates for the top of faults,
%   and the bottom (with uniform z coordinate specified by input arugment DEPTH), 
%   based on a FILE containing surface trace coordinates exported from ArcGIS.
%   Individual objects are assumed to be identified in one of two ArcGIS file
%   formats: 
%   Each object begins with an FID line and ends with an END line
%   Each row contains the x and y coordinates and the FID
%
%   The coordinates are returned to the 3-column array c, containing x, y, and z
%   coordinates for the top and bottom. The number of coordinates corresponding 
%   to each distinct object. 
%
%   Use the function rotatefaultcoords to assign dips to each fault (by changing the
%   bottom coordinates) and function gmshfaults to create triangulated meshes of all
%   faults.
%

% ArcGIS file style 1: Feature coordinates start with FID and end with "END"
a = opentxt(file);
ends = strfind(a(:, 1)', 'E') - 1;
if ~isempty(ends)
   astyle = 1;
   if diff(ends(end), ends(end-1)) == 1
      ends = ends(1:end-1);
   end
   begs = [2 ends(1:end-1) + 3];
else
   delims = strfind(a(:, 1)', '>');
   if isempty(delims)
      % ArcGIS file style 2: Each line contains feature x, y, FID
      astyle = 2;
      if a(1) == 'X'
         fl = 2;
      else
         fl = 1;
      end
      a = str2num(a(fl:end, :));
      d3 = diff(a(:, 3));
      ends = [find(d3>0); size(a, 1)];
      begs = [1; ends(1:end-1)+1];
   else
      % GMT style delimiters
      astyle = 1;
      begs = delims + 1;
      ends = [delims(2:end) - 1, size(a, 1)];
   end
end

% Number of coordinates in each object
nc = 2*(ends+1-begs);
% Blank coordinate array
c = zeros(sum(nc), 3);

% Initial coordinate indices
idxt = [1-nc(1), -nc(1)/2];
idxb = [1-nc(1)/2, 0];

% Loop through objects
for i = 1:numel(begs)
   % Update indices
   idxt = idxb(2) + [1, nc(i)/2];
   idxb = idxb(2) + [nc(i)/2+1, nc(i)];
   if astyle == 1
      tc = str2num(a(begs(i):ends(i), :));
      tc = tc(:, 1:2);
   else
      tc = a(begs(i):ends(i), 1:2);
   end
%   tc = unique(tc, 'rows', 'stable');
   % Place coordinates 
   c(idxt(1):idxb(2), 1:2) = [tc; flipud(tc)];
   c(idxb(1):idxb(2), 3) = -abs(depth);
end

% Make sure we're returning nc as a column vector
nc = nc(:);