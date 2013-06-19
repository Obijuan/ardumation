use <libs/build_plate.scad>
use <libs/obiscad/bcube.scad>
use <libs/obiscad/bevel.scad>
use <libs/obiscad/attach.scad>
use <libs/teardrop.scad>

X = 0;
Y = 1;
Z = 2;

extra = 10;

//-- Stepper motor parameters (NEMA 17)
nema17_clearance = 1;
nema17_clearance2 = 3;
nema17_size = [42.3, 42.3, 47.0];
nema17_cr = 4;
nema17_cres = 0;
nema17_shaft_diam = 5;
nema17_shaft_length = 24.3;
nema17_shaft_base_diam = 22;
nema17_shaft_base_h = 2.5;
nema17_drill_diam = 3.2;
nema17_drill_radial_dist = 18  + nema17_drill_diam/2 + nema17_shaft_diam/2;

//-- nuts and ohter stuff
M8_washer_diam = 15.8; 
M8_nut_diam = 15.5;
M8_nut_h = 6.5;

M3_screw_diam = 3.2;
M3_nut_h = 2.5;
M3_nut_diam = 6.4;


//-- Distance between the left motor end and the right side of the threaded rod
x_motor_rod_space = 6;
xrod_pos = [nema17_size[X]/2 + x_motor_rod_space + M8_washer_diam/2, 0, -2];

echo("X_rod: ", xrod_pos[X]);

//-- Distance from the bottom to the x-theaded rot nut
x_threaded_rod_diam = 8.5;
x_threaded_rod_bottom_clearance = 3;
motor_top_clearance = 3 + nema17_clearance;
x_threaded_rod_pos = [ xrod_pos[X], nema17_size[Y]/2, 0];
motor_plate_th = 4;
x_smooth_rod_diam = 8.5;

//-- Lateral reinforcements              
rf_wall_th = 3;
rf_base_th = 3;

//-- Screws for lateral reinforments
rf_screw_diam = 3;
rf_screw_head_diam = 6;
rf_screw_clearance = 1;
rf_screw_pos = [0,0,rf_screw_head_diam/2 + rf_screw_clearance];

//-- Calculate the reinformet size
rf_size = [2*(rf_wall_th + rf_screw_clearance + rf_screw_head_diam/2), 
           rf_base_th,
           2*(2*rf_screw_clearance + rf_screw_head_diam)];

//-- General basic x-end parameters
x_end_size = [nema17_size[X] + 2*(x_motor_rod_space + M8_washer_diam +1 + rf_size[X]), 
              motor_top_clearance + nema17_size[Y] + M8_washer_diam/2 + x_threaded_rod_bottom_clearance, 
              12];
              
x_end_pos = [0, -x_end_size[Y]/2 + nema17_size[Y]/2 + motor_top_clearance, 0];              


rf_pos = [rf_size[X]/2 -x_end_size[X]/2+0.01, 
          rf_size[Y]/2 - x_end_size[Y]/2, 
          rf_size[Z]/2 + x_end_size[Z]/2-0.01];
              
//-- Bearing
bearing_diam = 22+0.5;
              
//-- Main plate cutouts
co1_size = [x_end_size[X]/2, x_end_size[Y]/2, x_end_size[Z]+extra];
              
module nema17_drills(l = nema17_size[Z])
{
  for (i=[0:3]) {
    translate([nema17_drill_radial_dist * cos(i*90 + 45),
               nema17_drill_radial_dist * sin(i*90 + 45),
               0])
      cylinder(r = nema17_drill_diam/2, h = l, center = true, $fn = 6);
  }
}

module nema17_motor(clearance = 0, only_body=false)
{
  
  //-- Motor size + clearance
  size = [nema17_size[X] + clearance, nema17_size[Y] + clearance, nema17_size[Z]];
  
  difference() {
  
    //-- Motor: body + shaft + base
    union() {
      //-- Motor body
      color("gray")
	bcube(size, cr = nema17_cr, cres = nema17_cres);

      if (only_body==false) {
        //-- Motor shaft
        color("lightgray")
	  translate([0, 0, size[Z]/2 + nema17_shaft_length/2])
	    cylinder(r = nema17_shaft_diam/2, h = nema17_shaft_length, center = true, $fn=20);
	  
        //-- Motor shaft base
        color("gray")
        translate([0, 0, size[Z]/2 + nema17_shaft_base_h/2 ])
        cylinder(r = nema17_shaft_base_diam/2, h = nema17_shaft_base_h, center = true, $fn = 100);
      }
    }
    
    if (only_body == false) {
      translate([0, 0, nema17_size[Z]/2])
      nema17_drills(l = 10);
    }  
  }
  
}

module ring(r, dr, h)
{
  difference() {
   cylinder(r = r + dr, h = h, center = true);
   cylinder(r = r, h = h + extra, center = true);
 }  
}


module reinforcement()
{

  //-- Conectors for the reinforcements
  pos = [-rf_size[X]/2 + rf_wall_th/2, rf_size[Y]/2 - 0.01, -rf_size[Z]/2];
  
  ec1 = [ pos, [1,0,0], 0];
  en1 = [ ec1[0], [0,1,1], 0];
  ec2 = [ [-pos[X], pos[Y], pos[Z]], [1,0,0], 0];
  en2 = [ ec2[0], [0,1,1], 0];
  
  //-- Debug
  //connector(ec1);
  //connector(en1);
  //connector(ec2);
  //connector(en2);
  
  //-- Base + drills
  difference() {
    //--- Base
    cube(rf_size, center = true);

    //-- Far screw
    translate(rf_screw_pos)
      rotate([90,0,0])
	//#cylinder(r = rf_screw_diam/2, h = rf_size[Y]+extra, center = true, $fn=20);
	teardrop(r = rf_screw_diam/2, h = rf_size[Y]+extra);

    //-- Close screw    
    translate(-rf_screw_pos)
      rotate([90,0,0])
	//cylinder(r = rf_screw_diam/2, h = rf_size[Y]+extra, center = true, $fn=20);
	teardrop(r = rf_screw_diam/2, h = rf_size[Y]+extra);
  }
  
  //-- Lateral reinforcements
  bconcave_corner_attach(ec1, en1, l=rf_wall_th, cr=rf_size[Z], cres=0, th=0.01);
  bconcave_corner_attach(ec2, en2, l=rf_wall_th, cr=rf_size[Z], cres=0, th=0.01);
  

}

module main_plate(motor = true)
{
  difference() {

    //-- Base plate
    translate(x_end_pos)
    //color("blue")
      cube(x_end_size, center = true);

    //-- Upper-left cutout
    translate(co1_pos)           
      cube(co1_size, center = true);   

    //-- Upper-right cutout
    translate([-co1_pos[X], co1_pos[Y], co1_pos[Z]])
      cube(co1_size, center = true);
      
    
    
    if (motor == true) {
    
    //-- Room for the motor
    translate([0, 0, nema17_size[Z]/2 - x_end_size[Z]/2 + motor_plate_th])
    rotate([180, 0, 0])
    nema17_motor(clearance = nema17_clearance, only_body = true);
    
    //-- Base shaft
    cylinder(r = nema17_shaft_base_diam/2 + nema17_clearance/2, 
	      h = x_end_size[Z]+extra, center = true, $fn = 100);
	      
      //-- Motor drills    
      nema17_drills(l = x_end_size[Z]+extra);
    }
    else {
      //-- 608 bearing
      cylinder(r = bearing_diam/2, h = x_end_size[Z] + extra, center = true);
      
      translate([0,0, motor_plate_th])
      ring (r = bearing_diam/2 + 3, dr = 6, h = x_end_size[Z]); 
    }
  }
  
  
}




co1_pos = [-co1_size[X]/2 - nema17_size[Y]/2 -nema17_clearance -nema17_clearance2,
           co1_size[Y]/2,
           0];

           
 pos1 = co1_pos;

 //-- Lateral triangles
 ec1 = [ [- nema17_size[Y]/2 -nema17_clearance -nema17_clearance2 +0.05,
          -0.05,
          -x_end_size[Z]/2 + motor_plate_th/2], [0,0,1], 0];
 en1 = [ ec1[0], [-1,1,0], 0];
 
 ec2 = [ [-ec1[0][X],
          -0.05,
          -x_end_size[Z]/2 + motor_plate_th/2], [0,0,1], 0];
 en2 = [ ec2[0], [1,1,0], 0];
  
  //-- Debug
  //connector(ec1);
  //connector(en1);
  //connector(ec2);
  //connector(en2);           
           

module x_motor_end(motor = true)
{
  difference() {
    union() {
      //-- Main plate
      main_plate(motor = motor);

      //-- Mail plate lateral triangles
      bconcave_corner_attach(ec1, en1, l=motor_plate_th,   
			    cr=nema17_size[Y]/2  +nema17_clearance + nema17_clearance2, 
			    cres=0, th=0.01);
      
      bconcave_corner_attach(ec2, en2, l=motor_plate_th,   
			    cr=nema17_size[Y]/2  +nema17_clearance + nema17_clearance2, 
			    cres=0, th=0.01);
    } 
    
    //-- Left axis smooth bar
  translate([-xrod_pos[X], xrod_pos[Y], xrod_pos[Z]])
    cylinder(r = x_smooth_rod_diam/2, h = x_end_size[Z], center = true, $fn = 50);

    //--- Left axis threaded rod
  translate([-x_threaded_rod_pos[X], -x_threaded_rod_pos[Y], 0])
    cylinder(r = x_threaded_rod_diam/2, h = 70, center = true, $fn = 50);
    
    //-- Right axis smooth bar
  translate([xrod_pos[X], xrod_pos[Y], xrod_pos[Z]])
    cylinder(r = x_smooth_rod_diam/2, h = x_end_size[Z], center = true, $fn = 50);
    
  //--- Right axis threaded rod
  translate([x_threaded_rod_pos[X], -x_threaded_rod_pos[Y], 0])
    cylinder(r = x_threaded_rod_diam/2, h = 70, center = true, $fn = 50);  

    //-- Left zip tie hole
    translate([-xrod_pos[X], xrod_pos[Y], 1])
      ring(r = x_smooth_rod_diam/2 + 1, dr = 1.5, h =3);
    
    //-- Right zip tie hole
    translate([xrod_pos[X], xrod_pos[Y], 1])
      ring(r = x_smooth_rod_diam/2 + 1, dr = 1.5, h =3);
    
  }



  translate(x_end_pos) {   
    //-- Left reinforcement  
    translate(rf_pos)
      reinforcement();
    
    //-- Right reinforcement
    translate([-rf_pos[X], rf_pos[Y], rf_pos[Z]])
      reinforcement();
  }


}



//--- Embebbed nut part
emb_nut_size = [35, M8_nut_h + 4, 20];
clamp_drill_pos = [-emb_nut_size[X]/2 + emb_nut_size[X]/8, 0, 0];


module embebbed_nut_part_basic()
{
  //-- body
  cube(emb_nut_size, center = true);

  pos3 = [0, emb_nut_size[Y]/2, -emb_nut_size[Z]/2];

 ec3 = [ pos3, [1,0,0], 0];
  en3 = [ ec3[0], [0,1,1], 0];
  //ec2 = [ [-pos[X], pos[Y], pos[Z]], [1,0,0], 0];
  //en2 = [ ec2[0], [0,1,1], 0];
  
  //-- Debug
  //connector(ec3);
  //connector(en3);

  bconcave_corner_attach(ec3, en3, l = M8_nut_diam, cr=emb_nut_size[Z], cres=0, th=0.05);
}



module embebbed_nut_part()
{


  difference() {

  //-- Main body
  embebbed_nut_part_basic();

  //-- M8 drill
  rotate([90, 0, 0])
    teardrop(r = x_threaded_rod_diam/2 + 0.2, h = 2*(emb_nut_size[Y] + emb_nut_size[Z]));
  
  //------- Drills for the clamp
  //-- Left drill  
  translate(clamp_drill_pos)
    rotate([90, 0, 0])
      teardrop (r = M3_screw_diam/2, h = emb_nut_size[Y] + extra);
      
  //-- Right drill
  translate(-clamp_drill_pos)
    rotate([90, 0, 0])
      teardrop (r = M3_screw_diam/2, h = emb_nut_size[Y] + extra);
  
  //-- Room for the embbebed nuts
  translate([0, emb_nut_size[Y] - M3_nut_h,0])
  translate(clamp_drill_pos)
  rotate([90,0,0])
  cylinder(r = M3_nut_diam/2, h = emb_nut_size[Y], center = true, $fn = 6);

  translate([0, emb_nut_size[Y] - M3_nut_h,0])
  translate(-clamp_drill_pos)
  rotate([90,0,0])
  cylinder(r = M3_nut_diam/2, h = emb_nut_size[Y], center = true, $fn = 6);
  
}


}

module nut_clamp()
{

  rotate([90, 0, 0])
  difference() {
    cube([emb_nut_size[X], 5, emb_nut_size[Z]], center = true);
    
    //-- M8 drill
    rotate([90, 0, 0])
    cylinder(r = x_threaded_rod_diam/2 + 1.2, h = 2*(emb_nut_size[Y] + emb_nut_size[Z]), center = true);

    translate(clamp_drill_pos)
      rotate([90, 0, 0])
        cylinder (r = M3_screw_diam/2, h = emb_nut_size[Y] + extra, center = true);
      
    //-- Right drill
    translate(-clamp_drill_pos)
      rotate([90, 0, 0])
        cylinder (r = M3_screw_diam/2, h = emb_nut_size[Y] + extra, center=true);
  }      
}


//----------------- x carriage -----------------------
lm8uu_diam = 15;
lm8uu_len = 24;
plate_clearance = [8, 4];
x_carriage_z_rods_xdis = 5;
x_plate_th = 5;

//-- cutout for the lm8uu
co_lm8uu_size = [lm8uu_len + 2, lm8uu_diam/2 + 2];
lm8uu_clearance = 2;

co_zip_tie_size = [5 ,1.5, x_plate_th + extra];
co_zip_tie_pos = [co_lm8uu_size[X]/4, co_zip_tie_size[Y]/2 + co_lm8uu_size[Y]/2 + lm8uu_clearance ,0];

x_plate_size = [co_lm8uu_size[X] + 2*plate_clearance[X],
                2*(xrod_pos[X] + co_lm8uu_size[Y]/2 + lm8uu_clearance + co_zip_tie_size[Y] + plate_clearance[Y]), 
                x_plate_th];



                
x_carriage_z_rods_pos = [x_plate_size[X]/2 - x_threaded_rod_diam/2 - x_carriage_z_rods_xdis, 
                          x_plate_size[Y]/5,
                          0];            



                          
                          
module cutout_lm8uu()
{

  bcube([co_lm8uu_size[X], co_lm8uu_size[Y], x_plate_size[Z] + extra], cr = 2, cres = 4);

  //-- Zip tie holes
    translate(co_zip_tie_pos)
      cube(co_zip_tie_size, center = true);
      
  translate([-co_zip_tie_pos[X], co_zip_tie_pos[Y], co_zip_tie_pos[Z]])
      cube(co_zip_tie_size, center = true);    
      
  translate([-co_zip_tie_pos[X], -co_zip_tie_pos[Y], co_zip_tie_pos[Z]])
      cube(co_zip_tie_size, center = true);   
      
  translate([co_zip_tie_pos[X], -co_zip_tie_pos[Y], co_zip_tie_pos[Z]])
      cube(co_zip_tie_size, center = true);     
      
}
 
 
module x_carriage_main_plate()
{
  difference() {
    //-- Main plate
    bcube(x_plate_size, cr = 2, cres = 4);
  
    //-- lm8uu cutouts
    translate([0, xrod_pos[X],0])
      cutout_lm8uu();

    translate([0, -xrod_pos[X],0])
      cutout_lm8uu();

    //-- Vertical M8 threaded rods
    translate(x_carriage_z_rods_pos)
      cylinder(r = x_threaded_rod_diam/2, h = x_plate_size[Z] + extra, center = true, $fn=20);

    translate([x_carriage_z_rods_pos[X], -x_carriage_z_rods_pos[Y], x_carriage_z_rods_pos[Z]])
      cylinder(r = x_threaded_rod_diam/2, h = x_plate_size[Z] + extra, center = true, $fn=20);
  }    
  
}
 
//-- Distance between the center of the smooth rods until the bottom of the carriage
//-- This distance is quite important for keeping the three rods aligned
d = pow(lm8uu_diam/2, 2);
c = pow(co_lm8uu_size[Y]/2, 2);
x_carriage_smooth_bar_h = sqrt(pow(lm8uu_diam/2, 2) - pow(co_lm8uu_size[Y]/2, 2));

module x_carriage(show_bearings = false)
{
  difference() {                          

    union() {
    
      //-- Main plate
      translate([0, 0, - x_plate_size[Z]/2 - x_carriage_smooth_bar_h ])
      x_carriage_main_plate();

      translate([emb_nut_size[Y]/2 - x_plate_size[X]/2, 0, 0])
      rotate([0,0,-90])
      embebbed_nut_part();
    }   
    
    //-- Embebbed nut
    translate([-emb_nut_size[Y]/2 - x_plate_size[X]/2 + 4, 0, 0 ])
      rotate([0, 90, 0])
        rotate([0,0,90])
	cylinder(r = M8_nut_diam/2, h = emb_nut_size[Y], center = true, $fn = 6);   
  
  }
  
  if (show_bearings == true) {
  
    //-- Linear bearings lm8uu
    color("gray")
    translate([0,xrod_pos[X], 0])
      rotate([0, 90, 0])
	cylinder(r = lm8uu_diam/2, h = lm8uu_len, center = true);
	
    //-- Linear bearings lm8uu
    color("gray")
    translate([0,-xrod_pos[X], 0])
      rotate([0, 90, 0])
	cylinder(r = lm8uu_diam/2, h = lm8uu_len, center = true);
      
  }    
      
}

//---- y carriage -------------
y_plate_size = [x_plate_size[X], x_plate_size[Y] + 2*20, x_plate_size[Z]];
y_carriage_z_rods_pos = [x_carriage_z_rods_pos[X], y_plate_size[Y]/2 -11, 0];


module y_carriage_main_plate()
{
  difference() {
    //-- Main plate
    bcube(y_plate_size, cr = 2, cres = 4);
  
    //-- lm8uu cutouts
    translate([0, xrod_pos[X],0])
      cutout_lm8uu();

    translate([0, -xrod_pos[X],0])
      cutout_lm8uu();

    //-- Vertical M8 threaded rods
    translate(y_carriage_z_rods_pos)
      cylinder(r = x_threaded_rod_diam/2, h = x_plate_size[Z] + extra, center = true, $fn=20);

    translate([y_carriage_z_rods_pos[X], -y_carriage_z_rods_pos[Y], y_carriage_z_rods_pos[Z]])
      cylinder(r = x_threaded_rod_diam/2, h = x_plate_size[Z] + extra, center = true, $fn=20);
      
    translate([-y_carriage_z_rods_pos[X], -y_carriage_z_rods_pos[Y], y_carriage_z_rods_pos[Z]])
      cylinder(r = x_threaded_rod_diam/2, h = x_plate_size[Z] + extra, center = true, $fn=20);
      
    translate([-y_carriage_z_rods_pos[X], y_carriage_z_rods_pos[Y], y_carriage_z_rods_pos[Z]])
      cylinder(r = x_threaded_rod_diam/2, h = x_plate_size[Z] + extra, center = true, $fn=20);
  }  
   
}

module y_carriage()
{
  difference() {                          

    union() {
    
      //-- Main plate
      translate([0, 0, - x_plate_size[Z]/2 - x_carriage_smooth_bar_h ])
      y_carriage_main_plate();

      translate([emb_nut_size[Y]/2 - x_plate_size[X]/2, 0, 0])
      rotate([0,0,-90])
      embebbed_nut_part();
    }   
    
    //-- Embebbed nut
    translate([-emb_nut_size[Y]/2 - x_plate_size[X]/2 + 4, 0, 0 ])
      rotate([0, 90, 0])
        rotate([0,0,90])
	cylinder(r = M8_nut_diam/2, h = emb_nut_size[Y], center = true, $fn = 6);   
  
  }
  
  if (show_bearings == true) {
  
    //-- Linear bearings lm8uu
    color("gray")
    translate([0,xrod_pos[X], 0])
      rotate([0, 90, 0])
	cylinder(r = lm8uu_diam/2, h = lm8uu_len, center = true);
	
    //-- Linear bearings lm8uu
    color("gray")
    translate([0,-xrod_pos[X], 0])
      rotate([0, 90, 0])
	cylinder(r = lm8uu_diam/2, h = lm8uu_len, center = true);
      
  } 
}

//-- y_carriage.. second floor...
y_carriage_2_screw_pos = [y_carriage_z_rods_pos[X],
                          y_carriage_z_rods_pos[Y] - M3_screw_diam/2 - x_threaded_rod_diam/2 -10,
                          y_carriage_z_rods_pos[Z]];


module y_carriage_2()
{
  cyl_len = y_plate_size[Z] + extra;
  
  

  difference() {
      //-- Main plate
      bcube(y_plate_size, cr = 2, cres = 4);

      //-- Vertical M8 threaded rods
      translate(y_carriage_z_rods_pos)
	cylinder(r = x_threaded_rod_diam/2, h = x_plate_size[Z] + extra, center = true, $fn=20);

      translate([y_carriage_z_rods_pos[X], -y_carriage_z_rods_pos[Y], y_carriage_z_rods_pos[Z]])
	cylinder(r = x_threaded_rod_diam/2, h = x_plate_size[Z] + extra, center = true, $fn=20);
	
      translate([-y_carriage_z_rods_pos[X], -y_carriage_z_rods_pos[Y], y_carriage_z_rods_pos[Z]])
	cylinder(r = x_threaded_rod_diam/2, h = x_plate_size[Z] + extra, center = true, $fn=20);
	
      translate([-y_carriage_z_rods_pos[X], y_carriage_z_rods_pos[Y], y_carriage_z_rods_pos[Z]])
	cylinder(r = x_threaded_rod_diam/2, h = x_plate_size[Z] + extra, center = true, $fn=20);
	
      //-- M3 screws for attaching the tablet base
      translate(y_carriage_2_screw_pos)
	cylinder(r = M3_screw_diam/2, h = y_plate_size[Z] + extra, center = true, $fn=20);
	
      translate([y_carriage_2_screw_pos[X], y_carriage_2_screw_pos[Y], y_carriage_2_screw_pos[Z]] )
	cylinder(r = M3_screw_diam/2, h = y_plate_size[Z] + extra, center = true, $fn=20);  
	
      translate([-y_carriage_2_screw_pos[X], y_carriage_2_screw_pos[Y], y_carriage_2_screw_pos[Z]] )
	cylinder(r = M3_screw_diam/2, h = y_plate_size[Z] + extra, center = true, $fn=20);   
	
      translate([y_carriage_2_screw_pos[X], -y_carriage_2_screw_pos[Y], y_carriage_2_screw_pos[Z]] )
	cylinder(r = M3_screw_diam/2, h = y_plate_size[Z] + extra, center = true, $fn=20);  
	
      translate([-y_carriage_2_screw_pos[X], -y_carriage_2_screw_pos[Y], y_carriage_2_screw_pos[Z]] )
	cylinder(r = M3_screw_diam/2, h = y_plate_size[Z] + extra, center = true, $fn=20); 
	
      //-- M3 embebbed nuts
      translate([0, 0, cyl_len/2 + y_plate_size[Z]/2 - M3_nut_h]) {
    
      translate(y_carriage_2_screw_pos) 
        cylinder(r = M3_nut_diam/2, h = cyl_len, center = true, $fn=6); 
      
      translate([-y_carriage_2_screw_pos[X], y_carriage_2_screw_pos[Y], y_carriage_2_screw_pos[Z]] )
        cylinder(r = M3_nut_diam/2, h = cyl_len, center = true, $fn=6); 
        
      translate([y_carriage_2_screw_pos[X], -y_carriage_2_screw_pos[Y], y_carriage_2_screw_pos[Z]] )
        cylinder(r = M3_nut_diam/2, h = cyl_len, center = true, $fn=6); 
        
       translate([-y_carriage_2_screw_pos[X], -y_carriage_2_screw_pos[Y], y_carriage_2_screw_pos[Z]] )
        cylinder(r = M3_nut_diam/2, h = cyl_len, center = true, $fn=6);  
        
        
      }
      
      //-- Center cutout
      bcube([2*y_carriage_2_screw_pos[X], 
             2 * (y_carriage_2_screw_pos[Y] - M3_nut_diam/2 - 10) , 
            y_plate_size[Z] + extra], cr=2, cres = 4);
      
    } 
    
    
}



//--  Hand...
hand_clearance = 4;
hand_size = [2*(x_carriage_z_rods_pos[Y] + M8_washer_diam/2 + hand_clearance), 55, 5];
micro_usb_size = [14, 27, 9];
micro_usb_wall_th = [2 + M3_nut_diam + 2, 3, 0];
micro_usb_box_size = [micro_usb_size[X] + 2*micro_usb_wall_th[X],
                      micro_usb_size[Y] + micro_usb_wall_th[Y],
                      micro_usb_size[Z]];
                      
micro_usb_pos =  [0, 
                  -micro_usb_box_size[Y]/2 + hand_size[Y]/2,
                  micro_usb_box_size[Z]/2 + hand_size[Z]/2 -0.01];

co_size = [micro_usb_size[X], micro_usb_size[Y]+extra, micro_usb_size[Z]+extra];
co_zip = [co_zip_tie_size[Y], 
          co_zip_tie_size[X], 
          2*(micro_usb_size[Z] + hand_size[Z]) + extra]; 
co_zip_pos = [co_zip_tie_size[Y]/2 + micro_usb_size[X]/2 - 0.05,
              co_zip_tie_size[X]/2,0];  
              
micro_usb_drill_pos = [- (micro_usb_box_size[X]/4 - micro_usb_size[X]/4) + (micro_usb_box_size[X])/2, 
            micro_usb_size[Y]/4, 0];
                      
module micro_usb_box()
{

  difference() {
    cube(micro_usb_box_size, center = true);
  
    translate([0,co_size[Y]/2 - micro_usb_box_size[Y]/2 + micro_usb_wall_th[Y],0])
    cube(co_size, center = true);
    
  }  
  
}
 
module micro_usb_hand()
{
  nut_drill_h = M3_nut_h + extra;
  cap_h = 0.4;
  cap_pos = [0, 0, cap_h/2 - hand_size[Z]/2 + M3_nut_h ];

  difference() {
 
    //-- Base + micro usb box
    union() {
    
      //-- Base
      bcube(hand_size, cr = 2, cres = 4); 
      
    //--micro USB box
      translate([0, 
	      -micro_usb_box_size[Y]/2 + hand_size[Y]/2,
	      micro_usb_box_size[Z]/2 + hand_size[Z]/2 -0.01])
	      micro_usb_box();
    }
    
    //-- z-Rods
    translate([0, -hand_size[Y]/2 + M8_washer_diam/2 + hand_clearance, 0]) {
      translate([x_carriage_z_rods_pos[Y], 0, 0])
	cylinder(r = x_threaded_rod_diam/2, h = x_plate_size[Z] + extra, center = true, $fn=20);
	
      translate([-x_carriage_z_rods_pos[Y], 0, 0])
	cylinder(r = x_threaded_rod_diam/2, h = x_plate_size[Z] + extra, center = true, $fn=20);
    }  

    //-- Zip tie holes
    translate(micro_usb_pos)
      translate(co_zip_pos)
	cube(co_zip, center = true);
	
    translate(micro_usb_pos)
      translate([-co_zip_pos[X], co_zip_pos[Y], co_zip_pos[Z]])
	cube(co_zip, center = true);    
    
    //-- Drills
    translate(micro_usb_drill_pos)
      cylinder(r = M3_screw_diam/2, h = 2*(micro_usb_size[Z] + hand_size[Z]), center = true);
      
    translate([-micro_usb_drill_pos[X], micro_usb_drill_pos[Y], micro_usb_drill_pos[Z]])
      cylinder(r = M3_screw_diam/2, h = 2*(micro_usb_size[Z] + hand_size[Z]), center = true); 
    
   //-- Captive nuts
    translate([0, 0, -nut_drill_h/2 - hand_size[Z]/2 + M3_nut_h])
    translate(micro_usb_drill_pos)
      cylinder(r = M3_nut_diam/2, h = nut_drill_h, center = true, $fn = 6); 
      
     translate([0, 0, -nut_drill_h/2 - hand_size[Z]/2 + M3_nut_h])
    translate([-micro_usb_drill_pos[X], micro_usb_drill_pos[Y], micro_usb_drill_pos[Z]])
      cylinder(r = M3_nut_diam/2, h = nut_drill_h, center = true, $fn = 6);   
    
  }  
  
  
  //-- Caps for the drills (for printing ok the room for the embebbed nuts
  translate(cap_pos)
    translate(micro_usb_drill_pos)
  cylinder(r = M3_screw_diam/2+0.1, h = cap_h, center = true, $fn = 6); 
  
  translate(cap_pos)
    translate([-micro_usb_drill_pos[X], micro_usb_drill_pos[Y], micro_usb_drill_pos[Z]])
  cylinder(r = M3_screw_diam/2+0.1, h = cap_h, center = true, $fn = 6); 
    

}
      
      
micro_usb_clamp_size = [micro_usb_box_size[X],
                        micro_usb_box_size[Y]/2 + micro_usb_wall_th[Y],
                        3];      
      
module micro_usb_clamp()
{
  difference() {
    translate([0, micro_usb_clamp_size[Y]/2 - micro_usb_wall_th[Y], 0])
      cube(micro_usb_clamp_size, center = true);
      
    //-- Drills
    translate(micro_usb_drill_pos)
      cylinder(r = M3_screw_diam/2, h = 2*(micro_usb_size[Z] + hand_size[Z]), center = true);
	
    translate([-micro_usb_drill_pos[X], micro_usb_drill_pos[Y], micro_usb_drill_pos[Z]])
      cylinder(r = M3_screw_diam/2, h = 2*(micro_usb_size[Z] + hand_size[Z]), center = true);   
  }  
}



module assembly()
{
  axis_len = 150;

  //-- x motor end (with the motor drawn)
  translate([0, -axis_len/2, 0])
  rotate([90, 0, 0]) {
    x_motor_end(motor = true); 
  
    //-- Motor
    translate([0, 0, nema17_size[Z]/2- x_end_size[Z]/2 + motor_plate_th])
      rotate([180, 0, 0])
        nema17_motor();    
  }     
  
  //-- Smooth bars
  rotate([90, 0, 0]) {
  
    color("lightgray")
      translate([-xrod_pos[X], xrod_pos[Y], xrod_pos[Z]])
        cylinder(r = x_smooth_rod_diam/2, h = axis_len, center = true, $fn = 50);
    
    color("lightgray")
      translate([xrod_pos[X], xrod_pos[Y], xrod_pos[Z]])
        cylinder(r = x_smooth_rod_diam/2, h = axis_len, center = true, $fn = 50);
  }
  
  //-- Linear bearings lm8uu
  color("gray")
  translate([xrod_pos[X],0, 0])
    rotate([90, 0, 0])
      cylinder(r = lm8uu_diam/2, h = lm8uu_len, center = true);
      
  color("gray")
  translate([-xrod_pos[X],0, 0])
    rotate([90, 0, 0])
      cylinder(r = lm8uu_diam/2, h = lm8uu_len, center = true);
  
  //-- Bearing end
  translate([0, axis_len/2, 0])
  rotate([0, 0, 180])
  rotate([90, 0, 0])
    x_motor_end(motor = false); 
  
  
  //-- X-carriage
  rotate([0, 180, 0])
  rotate([0, 0, 90])
  x_carriage();
  
  //-- Hand...
  color("blue")
  //translate(micro_usb_drill_pos)
  translate([0, hand_size[Y]/2 - M8_washer_diam/2 - hand_clearance, 0])
    translate([0,x_carriage_z_rods_pos[X], 
              hand_size[Z]/2 + x_carriage_smooth_bar_h + x_plate_size[Z] + 20 ])
  micro_usb_hand();
  
  
  //-- Vertical theaded rods
  color("lightgray")
  translate([x_carriage_z_rods_pos[Y], x_carriage_z_rods_pos[X], 20])
  cylinder(r = x_threaded_rod_diam/2, h = 40, center = true, $fn = 50);
  
  color("lightgray")
  translate([-x_carriage_z_rods_pos[Y], x_carriage_z_rods_pos[X], 20])
  cylinder(r = x_threaded_rod_diam/2, h = 40, center = true, $fn = 50);
  
}


//--- Parts for printing

//-- right: bearing end
*x_motor_end(motor = false);

//-- Left: motor end
*x_motor_end(motor = true); 


//-- Carriage
*x_carriage();

y_carriage_2();

//-- Nut clamp
*nut_clamp();


//-- Assembly!
*assembly();

*micro_usb_hand();

*micro_usb_clamp();
