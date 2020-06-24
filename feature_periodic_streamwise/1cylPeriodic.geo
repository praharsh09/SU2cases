// Praharsh_Periodic_Mesh
// Kattmann_Inspireed, 23.06.2020, 2D 3 Zone mesh
// ------------------------------------------------------------------------- //
// Which domain part should be handled
Which_Mesh_Part= 0; // 0=all, 1=Fluid, 2=SolidB, 3=InnerSolid
// Evoque Meshing Algorithm?
Do_Meshing= 1; // 0=false, 1=true
// Write Mesh files in .su2 format
Write_mesh= 0; // 0=false, 1=true

N_r_f = 101; //Gridpoints in radial direction for the fluid region
N_r_sb = 51; //Gridpoints in radial direction for solid region
N_theta = 51;//Grid points in theta direction for all regions

R_r_f = 1/1.02; //Progression radial direction for fluid region

d = 1; //diameter of the SolidB
lx = 2*d; //total periodic repeating part length
ly = lx; //total periodic repeating part width
wx = d; //x cord of center of the SolidB circular pin
wy = d; //y cord ofcenter of the SolidB circular pin

b = 0.15*d; //half of inner rectangle length of inner solid

// Mesh inputs
gs = 0.1; // gridsize standard input for points
rad2deg= Pi/180; // conversion factor as gmsh Cos/Sin functions take radian values

If (Which_Mesh_Part == 0 || Which_Mesh_Part == 1)
//outer fluid points
    Point(1) = {0, 0, 0, gs};
    Point(2) = {lx, 0, 0, gs};
    Point(3) = {lx, ly, 0, gs};
    Point(4) = {0, ly, 0, gs};

    Line(1) = {1,2};
    Line(2) = {2,3};
    Line(3) = {3,4};
    Line(4) = {4,1};
    Transfinite Line {1,2,3,4} = N_theta;
EndIf


If (Which_Mesh_Part == 0 || Which_Mesh_Part == 2 || Which_Mesh_Part == 3)
//inner rectangle points
    Point(11) = {wx-b, wy-b, 0, gs};
    Point(12) = {wx+b, wy-b, 0, gs};
    Point(13) = {wx+b, wy+b, 0, gs};
    Point(14) = {wx-b, wy+b, 0, gs};

    Line(11) = {11,12};
    Line(12) = {12,13};
    Line(13) = {13,14};
    Line(14) = {14,11};
    Transfinite Line {11,12,13,14} = N_theta;
EndIf

If (Which_Mesh_Part == 0 || Which_Mesh_Part == 1 || Which_Mesh_Part == 2)
//solidB circular points
    Point(20) = {wx, wy, 0, gs};
    Point(21) = {wx+((d/2)*Cos(225*rad2deg)), wy+((d/2)*Sin(225*rad2deg)), 0, gs};
    Point(22) = {wx+((d/2)*Cos(315*rad2deg)), wy+((d/2)*Sin(315*rad2deg)), 0, gs};
    Point(23) = {wx+((d/2)*Cos(45*rad2deg)), wy+((d/2)*Sin(45*rad2deg)), 0, gs};
    Point(24) = {wx+((d/2)*Cos(135*rad2deg)), wy+((d/2)*Sin(135*rad2deg)), 0, gs};

    Circle(31) = {21,20,24};
    Circle(32) = {24,20,23};
    Circle(33) = {23,20,22};
    Circle(34) = {22,20,21};
    Transfinite Line {31,32,33,34} = N_theta;
EndIf


If (Which_Mesh_Part == 0 || Which_Mesh_Part == 1)
//fluid region lines for gridpoints
    Line(21) = {1,21};
    Line(23) = {2,22};
    Line(25) = {3,23};
    Line(27) = {4,24};
    Transfinite Line {21,23,25,27} = N_r_f Using Progression R_r_f;
EndIf

If (Which_Mesh_Part == 0 || Which_Mesh_Part == 2)
//solidB region lines for gridpoints
    Line(22) = {21,11};
    Line(24) = {22,12};
    Line(26) = {23,13};
    Line(28) = {24,14};
    Transfinite Line {22,24,26,28} = N_r_sb;
EndIf

If (Which_Mesh_Part == 0 || Which_Mesh_Part == 1)
//fluid region surfaces and physical lines,surface
    Curve Loop(1) = {21, 31, -27, 4};
    Plane Surface(1) = {1};

    Curve Loop(2) = {27, 32, -25, 3};
    Plane Surface(2) = {2};

    Curve Loop(3) = {25, 33, -23, 2};
    Plane Surface(3) = {3};

    Curve Loop(4) = {1, 23, 34, -21};
    Plane Surface(4) = {4};
    Physical Line("fluid_solid_interface") = {31,32,33,34};
    Physical Line("inlet") = {4};
    Physical Line("outlet") = {2};
    Physical Line("symmetry") = {1,3};
    Physical Surface("fluid_surf") = {1,2,3,4};
EndIf

If (Which_Mesh_Part == 0 || Which_Mesh_Part == 2)
//solidB region surfaces and physical lines,surface
    Curve Loop(5) = {22, -14, -28, -31};
    Plane Surface(5) = {5};

    Curve Loop(6) = {13, -28, 32, 26};
    Plane Surface(6) = {6};

    Curve Loop(7) = {26, -12, -24, -33};
    Plane Surface(7) = {7};

    Curve Loop(8) = {24, -11, -22, -34};
    Plane Surface(8) = {8};
    Physical Line("solidB_inner_interface") = {11,12,13,14};
    Physical Line("solidB_outer_interface") = {31,32,33,34};
    Physical Surface("solidB_surf") = {5,6,7,8};
EndIf

If (Which_Mesh_Part == 0 || Which_Mesh_Part == 3)
//innersolid region surfaces and physical lines,surface
    Curve Loop(9) = {11, 12, 13, 14};
    Plane Surface(9) = {9};
    Physical Line("innersolid_inner_interface") = {11,12,13,14};
    Physical Surface("solid_inner_surf") = {9};
EndIf

// Meshing
Coherence;
Transfinite Surface "*";
Recombine Surface "*";
Transfinite Volume "*";

If (Do_Meshing == 1)
    Mesh 1; Mesh 2; Mesh 3;
EndIf

// Write .su2 meshfile
If (Write_mesh == 1)
    Mesh.Format = 42; // .su2 mesh format,
    If (Which_Mesh_Part == 1)
        Save "fluid1cylPer.su2";
    ElseIf (Which_Mesh_Part == 2)
        Save "solidB1cylPer.su2";
    ElseIf (Which_Mesh_Part == 3)
        Save "solidInner1cylPer.su2";
    Else
        Printf("Unvalid Which_Mesh_Part variable for output writing.");
        Abort;
    EndIf
EndIf
