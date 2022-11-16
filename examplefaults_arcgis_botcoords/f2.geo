charl = 0.5;
Point(1) = {0.8303, 3.6703, 0, charl};
Point(2) = {1.7061, 6.2637, 0, charl};
Point(3) = {1.917, 7.033, 0, charl};
Point(4) = {1.917, 7.033, -5, charl};
Point(5) = {1.7061, 6.2637, -5, charl};
Point(6) = {0.8303, 3.6703, -5, charl};
CatmullRom(1) = {1:3};
CatmullRom(2) = {4:6};
CatmullRom(3) = {3,4};
CatmullRom(4) = {6,1};
Line Loop(1) = {1, 3, 2, 4};
Ruled Surface(1) = {1};