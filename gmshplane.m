function p = gmshplane(tx, ty, tz, maxz, dip, sz)
% gmshplane  Makes a triangulated planar fault in Gmsh. 
%    p = gmshplane(tx, ty, tz, L, W, strike, dip, size) creates a 
%    triangulated mesh structure using Gmsh for the plane defined
%    by the input variables. tx, ty, tz are 2-element vectors giving
%    the coordinates of the end points of the tip line; maxz gives 
%    the maximum depth; dip gives the dip, with positive to the right 
%    looking from endpoint 1 to endpoint 2; and size gives the nominal
%    element size ("characteristic length") in Gmsh. 
%   

% Determine deep coordinates based on dip and maximum depth
strike = atan2d(diff(tx), diff(ty));
horzd = (abs(maxz) - abs(tz))./tand(dip);
dx = tx + cosd(strike).*horzd;
dy = ty + sind(strike).*horzd;
dz = [maxz; maxz];

% Write coordinates to Gmsh .geo file
fid = fopen('junk.geo', 'w');
fprintf(fid, 'charl = %g;\n', sz); % Write element size
% Write points: top then bottom
fprintf(fid, 'Point(%g) = {%g, %g, %g, charl};\n', [1:4; [tx(:)', dx(:)']; [ty(:)', dy(:)']; [tz(:)', dz(:)']]);
% Write lines: top, side 1, bottom, side 2
fprintf(fid, 'Line(%g) = {%g,%g};\n', [1, 1, 2, 2, 2, 4, 3, 4, 3, 4, 3, 1]);
% Circulate lines and create plane
fprintf(fid, 'Line Loop(1) = {1, 2, 3, 4};\nRuled Surface(1) = {1};\n');
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
system(sprintf('%s/gmsh -2 junk.geo -o junk.msh -v 0 > junk', gmshpath));

% Read the mesh
p = ReadPatches('junk.msh');

% Remove temp files
system('rm junk*');
