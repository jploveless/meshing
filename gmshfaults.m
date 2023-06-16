function allstring = gmshfaults(topdir, botdir, sz, smoothtrace)
% gmshfaults  Meshes faults in 3D using Gmsh.
%   gmshfaults(TOPDIR, BOTDIR, ELSIZE) meshes all faults whose top coordinates
%   are contained in text files within the folder TOPDIR and bottom coordinates
%   are contained in text files within the folder BOTDIR, using the 
%   element size specified using ELSIZE.  Geometry (.geo) and mesh (.msh)
%   files are saved to the bottom coordinate directory.
%
%   gmshfaults(TOPDIR, BOTDIR, ELSIZE, SMOOTHTRACE) 
%
%   ALL = gmshfaults(...) returns a string to the command line that can be
%   used to read all faults in using ReadPatches.m, i.e.
%   >> p = ReadPatches(ALL);
% 
%

if ~exist('smoothtrace', 'var')
   smoothtrace = true;
end
if ~islogical(smoothtrace)
   smoothtrace = logical(smoothtrace);
end

% List all bottom coordinate files
files = dir([botdir filesep '*.txt']);
% Sort files numerically
files = sortnumfilenames(files);

for i = 1:size(files, 1)
   % Read bottom coordinates
   botcoords = load([botdir filesep files(i).name]);
   % Get number of coordinates
   nc = size(botcoords, 1);
   % Read top coordinates
   topcoords = load([topdir filesep files(i).name]);
   % Write the Gmsh geometry file
   geofile = [botdir filesep files(i).name(1:end-4) '.geo'];
   fid = fopen(geofile, 'w');
   fprintf(fid, 'charl = %g;\n', sz);
   fprintf(fid, 'Point(%g) = {%g, %g, %g, charl};\n', [1:2*nc; [topcoords(:, 1); flipud(botcoords(:, 1))]'; [topcoords(:, 2); flipud(botcoords(:, 2))]'; [topcoords(:, 3); flipud(botcoords(:, 3))]']);
   if smoothtrace
      fprintf(fid, 'CatmullRom(%g) = {%g:%g};\n', [1:2; [1 nc+1; nc 2*nc]]);
      fprintf(fid, 'CatmullRom(%g) = {%g,%g};\n', [3:4; [nc 2*nc; nc+1 1]]);
      fprintf(fid, 'Line Loop(1) = {1, 3, 2, 4};\nRuled Surface(1) = {1};\n');
   else
      ci = [1:(2*nc), 1];
      % Standard lines
      for j = 1:(2*nc)
         fprintf(fid, 'Line(%g) = {%g, %g};\n', j, ci(j), ci(j+1));
      end
      % Panel separations
      for k = 2:(nc-1)
         fprintf(fid, 'Line(%g) = {%g, %g};\n', j+k-1, 2*nc-k+1, k);
      end
      % Line loops and surfaces
      % First
      fprintf(fid, 'Curve Loop(1) = {%g, %g, %g, %g};\nPlane Surface(1) = {1};\n', 1, -(2*nc+1), 2*nc-1, 2*nc);
      % Middle
      for l = 2:(nc-2)
         fprintf(fid, 'Curve Loop(%g) = {%g, %g, %g, %g};\nPlane Surface(%g) = {%g};\n', l, l, -(2*nc+l), 2*nc-l, 2*nc+l-1, l, l);
      end
      % Last
      fprintf(fid, 'Curve Loop(%g) = {%g, %g, %g, %g};\nPlane Surface(%g) = {%g};\n', nc-1, nc-1, nc, nc+1, 2*nc+(nc-2), nc-1, nc-1);
   end
   fclose(fid);

   % Mesh using Gmsh
   
   % Check for preferences file
   if exist('gmshfaultspref.mat', 'file') ~= 0 % If this .mat file exists, 
      load('gmshfaultspref.mat', 'gmshpath') % Load it
   else % If not, 
      if ismac
         if exist('/Applications/Gmsh.app/Contents/MacOS/gmsh', 'file') % Check for default install location
            gmshpath = '/Applications/Gmsh.app/Contents/MacOS/';
         else
            gmshpath = ''; % Or ask for install location
            while ~exist([gmshpath filesep 'gmsh'], 'file')
               gmshpath = input('Enter path to Gmsh application: ');
            end
         end
         % Save Gmsh path to preferences file, to be read in future runs
         gmfp = fileparts(which('gmshfaults'));
         save([gmfp filesep 'gmshfaultspref.mat'], 'gmshpath');
      elseif ispc || (isunix && ~ismac)
         gmshpath = ''; % Or ask for install location
         while ~exist([gmshpath filesep 'gmsh.exe'], 'file')
            gmshpath = input('Enter path to Gmsh application: ');
         end
         % Save Gmsh path to preferences file, to be read in future runs
         gmfp = fileparts(which('gmshfaults'));
         save([gmfp filesep 'gmshfaultspref.mat'], 'gmshpath');
      end
   end
   % Do the meshing
   system(sprintf('%s/gmsh -2 %s -o %s.msh -v 0 > junk', gmshpath, geofile, geofile(1:end-4)));
end
% Remove report file
if isunix
   system('rm junk');
elseif ispc
   %system('del junk');
end
   
% Make a space-separated string of all .msh files
alldir = dir([botdir '/*.msh']);
% Sort files numerically
alldir = sortnumfilenames(alldir);

allstring = '';
for i = 1:length(alldir)
   allstring = sprintf('%s %s/%s', allstring, botdir, alldir(i).name);
end
allstring = allstring(2:end); % Remove leading space