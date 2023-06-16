function p = process_fault_geom(filestem, faultdepth, dip, elsize, lengthcutoff)
% process_fault_geom Processes ArcGIS fault coordinates to make fault meshes.
%   p = process_fault_geom(filestem, faultdepth, dip, elsize, lengthcutoff)


% For east-west faults:
% ew = nchile_fault_geom('EWScarps_Vertices_w_dips', 10000, 45, 2500, 7500);
% For north-south faults:
% ns = nchile_fault_geom('scarps_Vertices_w_dips', 10000, 80, 2500, 7500);


% Read coordinate file and process into fault info array
vertexdata = load([filestem, '.csv']);
% Find unique fault indices
[fid, unique_idx] = unique(vertexdata(:, 3));
% Create fault data array: [fault_id, dip_direction, fault_length]
faultdata = [fid, vertexdata(unique_idx, 4:5)];
% Modulate nominal dip value by dip direction
% -1 gives north/east dip, 1 gives south/west dip
dips = dip*faultdata(:, 2);

% Project surface traces to specified depth, except for shorter faults, 
% which are assigned the fault length as their width
faultdepth = faultdepth*ones(length(faultdata), 1);
shortfaultidx = faultdepth > faultdata(:, 3);
faultdepth(shortfaultidx) = faultdata(shortfaultidx, 3);

% Use ArcGIS coordinate file to generate individual fault coordinate files
maketopbotcoords([filestem, '.csv'], faultdepth);

% Rotate fault coordinates to nominal 45 degree dips
rotatefaultcoords_dir([filestem, '_botcoords'], dips);

% Mesh faults with 2500 m characteristic length 
out = gmshfaults([filestem, '_topcoords'], [filestem, '_botcoords_truedip'], elsize);

% Read faults into a structure
p = ReadPatches(out);
% Calculate element properties
p = PatchCoordsx(p);



% Optional: Define subset of faults that are longer than a specified length
if exist('lengthcutoff', 'var')
   % Logical indices of faults to keep
   keepfaults = faultdata(:, 3) > lengthcutoff;
   % Initialize an element keeping array: start with all false
   keepels = false(length(p.v), 1);
   % Identify ending and starting indices of faults within element list
   ends = cumsum(p.nEl);
   begs = [1; ends(1:end-1) + 1];
   % Loop through faults, and for those to be kept, set their elements to true
   for i = 1:length(keepfaults)
      if keepfaults(i),
         keepels(begs(i):ends(i)) = true;
      end
   end
   
   % Extract a subset of faults
   p = patchsubset(p, keepels);
end