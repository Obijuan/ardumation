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

//-- Distance between the left motor end and the right side of the threaded rod
x_motor_rod_space = 6;
xrod_pos = [nema17_size[X]/2 + x_motor_rod_space + M8_washer_diam/2, 0, -2];

//-- Distance from the bottom to the x-theaded rot nut
x_threaded_rod_diam = 8.4;
x_threaded_rod_bottom_clearance = 3;
motor_top_clearance = 3 + nema17_clearance;
x_threaded_rod_pos = [ xrod_pos[X], nema17_size[Y]/2, 0];
motor_plate_th = 4;
x_smooth_rod_diam = 8.4;

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

           
rotate([0,0,0]) {

//-- Manually adjutable build plate
//build_plate(3,200,200);

*translate([0, 0, nema17_size[Z]/2- x_end_size[Z]/2 + motor_plate_th])
rotate([180, 0, 0])
nema17_motor();
   
  x_motor_end(motor = true); 
}






