charl = 0.5;
Point(1) = {2.2538, -2.5934, 0, charl};
Point(2) = {2.4805, -2.1099, 0, charl};
Point(3) = {3.1064, -0.5055, 0, charl};
Point(4) = {4.0358, 1.8681, 0, charl};
Point(5) = {4.5867, 3.3626, 0, charl};
Point(6) = {4.9646, 4.1758, 0, charl};
Point(7) = {4.9646, 4.1758, -5, charl};
Point(8) = {4.5867, 3.3626, -5, charl};
Point(9) = {4.0358, 1.8681, -5, charl};
Point(10) = {3.1064, -0.5055, -5, charl};
Point(11) = {2.4805, -2.1099, -5, charl};
Point(12) = {2.2538, -2.5934, -5, charl};
CatmullRom(1) = {1:6};
CatmullRom(2) = {7:12};
CatmullRom(3) = {6,7};
CatmullRom(4) = {12,1};
Line Loop(1) = {1, 3, 2, 4};
Ruled Surface(1) = {1};
