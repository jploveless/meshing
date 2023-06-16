function [el_ints, mesh_ints] = intersecting_meshes(p)

% Mesh element indices
ends = cumsum(p.nEl);
begs = [1; ends(1:end-1) + 1];

% Indices of all elements
all_els = 1:ends(end); all_els = all_els(:);
% Placeholder for number of element intersections
el_ints = zeros(size(all_els));
% Placeholder for number of mesh intersections
mesh_ints = zeros(size(p.nEl));

% Find scalar component of element normals
d = -p.nv(:, 1).*p.x1 - p.nv(:, 2).*p.y1 - p.nv(:, 3).*p.z1;

% For each mesh, 
for i = 1:length(begs)
   % ID elements of mesh
   these_els = begs(i):ends(i);
   % ID elements of other meshes
   other_els = setdiff(all_els, these_els);
   % For each element of this mesh, 
   for j = these_els
      % Check whether each leg of all other triangles intersects this element
      
      % Calculate denominators
      denom1 = p.nv(j, 1).*(p.x2(other_els) - p.x1(other_els)) + p.nv(j, 2).*(p.y2(other_els) - p.y1(other_els)) + p.nv(j, 3).*(p.z2(other_els) - p.z1(other_els));
      denom2 = p.nv(j, 1).*(p.x3(other_els) - p.x2(other_els)) + p.nv(j, 2).*(p.y3(other_els) - p.y2(other_els)) + p.nv(j, 3).*(p.z3(other_els) - p.z2(other_els));
      denom3 = p.nv(j, 1).*(p.x1(other_els) - p.x3(other_els)) + p.nv(j, 2).*(p.y1(other_els) - p.y3(other_els)) + p.nv(j, 3).*(p.z1(other_els) - p.z3(other_els));      
      % Calculate slopes
      mu1 = -(d(j) + p.nv(j, 1).*p.x1(other_els) + p.nv(j, 2).*p.y1(other_els) + p.nv(j, 3).*p.z1(other_els))./denom1;
      mu2 = -(d(j) + p.nv(j, 1).*p.x2(other_els) + p.nv(j, 2).*p.y2(other_els) + p.nv(j, 3).*p.z2(other_els))./denom2;
      mu3 = -(d(j) + p.nv(j, 1).*p.x3(other_els) + p.nv(j, 2).*p.y3(other_els) + p.nv(j, 3).*p.z3(other_els))./denom3;
      % Coordinates of intersection points
      int_point1 = [p.x1(other_els) + mu1.*(p.x2(other_els) - p.x1(other_els)), p.y1(other_els) + mu1.*(p.y2(other_els) - p.y1(other_els)), p.z1(other_els) + mu1.*(p.z2(other_els) - p.z1(other_els))];
      int_point2 = [p.x2(other_els) + mu2.*(p.x3(other_els) - p.x2(other_els)), p.y2(other_els) + mu2.*(p.y3(other_els) - p.y2(other_els)), p.z2(other_els) + mu2.*(p.z3(other_els) - p.z2(other_els))];
      int_point3 = [p.x3(other_els) + mu3.*(p.x1(other_els) - p.x3(other_els)), p.y3(other_els) + mu3.*(p.y1(other_els) - p.y3(other_els)), p.z3(other_els) + mu3.*(p.z1(other_els) - p.z3(other_els))];
      % Check whether intersection points are within triangle
      int1_vert_line1 = [p.x1(j), p.y1(j), p.z1(j)] - int_point1;
      int1_vert_line2 = [p.x2(j), p.y2(j), p.z2(j)] - int_point1;
      int1_vert_line3 = [p.x3(j), p.y3(j), p.z3(j)] - int_point1;
      int1_vert_line1 = int1_vert_line1./mag(int1_vert_line1, 2);
      int1_vert_line2 = int1_vert_line2./mag(int1_vert_line2, 2);
      int1_vert_line3 = int1_vert_line3./mag(int1_vert_line3, 2);
      a11 = dot(int1_vert_line1, int1_vert_line2, 2);
      a12 = dot(int1_vert_line2, int1_vert_line3, 2);
      a13 = dot(int1_vert_line3, int1_vert_line1, 2);
      int1_tot_ang = acosd(a11) + acosd(a12) + acosd(a13);
      int1_check = find(abs(int1_tot_ang - 360) < 1e-15 & mu1 > 0 & mu1 < 1, 1);
      
      int2_vert_line1 = [p.x1(j), p.y1(j), p.z1(j)] - int_point2;
      int2_vert_line2 = [p.x2(j), p.y2(j), p.z2(j)] - int_point2;
      int2_vert_line3 = [p.x3(j), p.y3(j), p.z3(j)] - int_point2;
      int2_vert_line1 = int2_vert_line1./mag(int2_vert_line1, 2);
      int2_vert_line2 = int2_vert_line2./mag(int2_vert_line2, 2);
      int2_vert_line3 = int2_vert_line3./mag(int2_vert_line3, 2);
      a21 = dot(int2_vert_line1, int2_vert_line2, 2);
      a22 = dot(int2_vert_line2, int2_vert_line3, 2);
      a23 = dot(int2_vert_line3, int2_vert_line1, 2);
      int2_tot_ang = acosd(a21) + acosd(a22) + acosd(a23);
      int2_check = find(abs(int2_tot_ang - 360) < 1e-15 & mu2 > 0 & mu2 < 1, 1);
      
      int3_vert_line1 = [p.x1(j), p.y1(j), p.z1(j)] - int_point3;
      int3_vert_line2 = [p.x2(j), p.y2(j), p.z2(j)] - int_point3;
      int3_vert_line3 = [p.x3(j), p.y3(j), p.z3(j)] - int_point3; 
      int3_vert_line1 = int3_vert_line1./mag(int3_vert_line1, 2);
      int3_vert_line2 = int3_vert_line2./mag(int3_vert_line2, 2);
      int3_vert_line3 = int3_vert_line3./mag(int3_vert_line3, 2);
      a31 = dot(int3_vert_line1, int3_vert_line2, 2);
      a32 = dot(int3_vert_line2, int3_vert_line3, 2);
      a33 = dot(int3_vert_line3, int3_vert_line1, 2);
      int3_tot_ang = acosd(a31) + acosd(a32) + acosd(a33);     
      int3_check = find(abs(int3_tot_ang - 360) < 1e-15 & mu3 > 0 & mu3 < 1, 1); 
   
      int_el_idx = other_els(max([int1_check, int2_check, int3_check]));
      if ~isempty(int_el_idx)
          el_ints(j) = int_el_idx;
      end
   end
end


