use <libs/obiscad/bcube.scad>



X = 0;
Y = 1;
Z = 2;

extra = 10;

M3_washer_diam = 9;
M3_screw_diam = 3.2;
M3_nut_h = 3;
M3_nut_diam = 6.4;

//-- Parameters
L_corner_wall_th = 9;
L_corner_bottom_th = 3;
L_corner_h = 8;
L_corner_inner_size = [60, 20, L_corner_h];
L_corner_wall_th = 9;
L_corner_size = [L_corner_inner_size[X] + L_corner_wall_th,
                 L_corner_inner_size[Y] + L_corner_wall_th,
                 L_corner_h + L_corner_inner_size[Z] ];

//-- Outer corner radius                 
L_cr = 3;
L_inner_cr = 11;  //-- Inner corner radius

//-- Rail base
rail_base_cl = 2;  //-- Rail base clearance
rail_base_len = 30;  //-- Rail lengh
rail_base_size = [rail_base_cl + M3_washer_diam + rail_base_cl + M3_washer_diam + rail_base_cl,
                  rail_base_cl + M3_washer_diam + rail_base_len + rail_base_cl,
                  L_corner_bottom_th];

module basic_L()
{
  inner_cube =   [L_corner_size[X]+extra, L_corner_size[Y]+extra, L_corner_size[Z]+extra];             
  difference() {                 
    bcube(L_corner_size, cr = L_cr, cres = 4);   

    translate([inner_cube[X]/2 - L_corner_size[X]/2 + L_corner_wall_th, 
              inner_cube[Y]/2  - L_corner_size[Y]/2 + L_corner_wall_th,
              inner_cube[Z]/2 - L_corner_size[Z]/2 + L_corner_bottom_th])
      bcube(inner_cube, cr = L_inner_cr, cres = 10);
  }    
      
}

module rail() {
  hull() {
    translate([0, rail_base_len/2, 0])
      cylinder(r = M3_screw_diam/2, h = L_corner_bottom_th + extra, center = true, $fn = 10);

    translate([0, -rail_base_len/2, 0])
      cylinder(r = M3_screw_diam/2, h = L_corner_bottom_th + extra, center = true, $fn = 10);
  }
}

module rail_base()
{
  rail_pos = [rail_base_size[X]/2  - rail_base_cl - M3_washer_diam/2
            ,0,0];

  difference() {            
    bcube(rail_base_size, cr = L_cr, cres = 4);

    translate([rail_pos[X],0,0])
    rail();

    translate([-rail_pos[X],0,0])
    rail();
  }
}

nut_room_size = [M3_nut_diam, M3_nut_diam + extra, M3_nut_h];                
nut_cl = 5;
cap_drill_pos1 = [-L_corner_size[X]/2 + M3_screw_diam/2 + 3,
                 L_corner_size[Y]/2 - M3_screw_diam/2 - nut_cl,
                 0];
                 
cap_drill_pos2 = [-L_corner_size[X]/2 + M3_screw_diam/2 + nut_cl,
                 L_corner_size[Y]/2 - M3_screw_diam/2 - 3,
                 0];


difference() {                 
  //-- Basic L corner
  basic_L();
                 
                 
  //-- Embebbed nuts
  translate([cap_drill_pos1[X], cap_drill_pos1[Y], -nut_room_size[Z]/2 + L_corner_size[Z]/2 - 3])
  rotate([0, 0, -90])
  translate([0,  -nut_room_size[Y]/2 + M3_nut_diam/2, 0])
    cube(nut_room_size, center = true);  
  
  translate([ -cap_drill_pos2[X], 
             -nut_room_size[Y]/2 + M3_nut_diam/2 - cap_drill_pos2[Y],
             -nut_room_size[Z]/2 + L_corner_size[Z]/2 - 3])
    cube(nut_room_size, center = true);                 


  
    
  //-- Drills -------------
  //--- Left drill
  translate([cap_drill_pos1[X], cap_drill_pos1[Y], -3 - nut_room_size[Z]/2])
    cylinder(r = M3_screw_diam/2, h = L_corner_size[Z], center = true);

  translate([cap_drill_pos1[X], cap_drill_pos1[Y], -3/2 + L_corner_size[Z]/2 + 0.4])
    cylinder(r = M3_screw_diam/2, h = 3, center = true);

  //-- Right drill
  translate([-cap_drill_pos2[X], -cap_drill_pos2[Y],  -3 - nut_room_size[Z]/2 ])
    cylinder(r = M3_screw_diam/2, h = L_corner_size[Z], center = true);

  translate([-cap_drill_pos2[X], -cap_drill_pos2[Y], -3/2 + L_corner_size[Z]/2 + 0.4])
    cylinder(r = M3_screw_diam/2, h = 3, center = true);  
  
}  

//-- Rail base
translate([-rail_base_size[X]/2 + L_corner_size[X]/2 - 3, 
           -rail_base_size[Y]/2 - L_corner_size[Y]/2 +2, rail_base_size[Z]/2 - L_corner_size[Z]/2])
  rail_base();
