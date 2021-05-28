## meshing
# Matlab codes for triangular dislocation element meshing with Gmsh

These functions allow for interaction between Matlab and [Gmsh](https://gmsh.info), with a focus on meshing 3D representations of fault surfaces based on their surface traces. A basic workflow for meshing requires a text file of coordinates defining the surface traces of faults, extraction of those coordinates and projection of surface traces to depth, optional rotation of the fault coordinates to adopt a dip, and finally meshing of fault surfaces.

The text file containing surface coordinates should be a delimited file as exported from ArcGIS (with the beginning of each fault identified by a row containing `FID` and the end of each fault marked by a row with `END`) or identifying distinct entities with a row that starts with `>`. Each data row should contain `x, y, z` coordinates of a point along the surface trace (`z` should be 0). The function `extractcoords.m` reads this file and replicates the surface coordinates' `x, y` locations and adds a specified `z` location to define the base of the fault.

The meshing workflow is: 
    
    % Clone the repository
    !git clone --recursive https://github.com/jploveless/meshing.git
    % Add directories to path
    addpath ./meshing
    addpath ./meshing/tridisl
    [c, nc] = extractcoords('examplefaults.txt', 3); % Read in example faults
    [c, nc] = extractcoords('examplefaults_arcgis.txt', 3); % Same as above, but using another file format
    % Rotate each fault to give a dip of 60 degrees. 
    % Can alternatively specify a vector of dip values to assign a unique value to each fault
    rc = rotatefaultcoords(c, 60, nc);
    p = gmshcoords(c, nc, 0.5); % Mesh faults (original coordinates) with a nominal element size of 0.5 units
    p = PatchCoordsx(p); % Calculate some geometric parameters of faults
    meshview(p.c, p.v, p.zc); % Visualize faults, coloring by element centroid depth
    
![examplefaults](https://user-images.githubusercontent.com/7537266/120029943-cd12f900-bfc4-11eb-8946-9ce0277b1b22.png)
