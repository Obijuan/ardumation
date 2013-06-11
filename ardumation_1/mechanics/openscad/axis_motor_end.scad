use <libs/build_plate.scad>
use <libs/obiscad/bcube.scad>

X = 0;
Y = 1;
Z = 2;


//-- Stepper motor parameters (NEMA 17)
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
xrod_pos = [nema17_size[X]/2 + x_motor_rod_space + M8_washer_diam/2, 0, 0];

//-- General basic x-end parameters
//x_end_size = 


module nema17_drills(l = nema17_size[Z])
{
  for (i=[0:3]) {
    translate([nema17_drill_radial_dist * cos(i*90 + 45),
               nema17_drill_radial_dist * sin(i*90 + 45),
               0])
      cylinder(r = nema17_drill_diam/2, h = l, center = true, $fn = 6);
  }
}

module nema17_motor()
{
  
  difference() {
  
    //-- Motor: body + shaft + base
    union() {
      //-- Motor body
      color("gray")
	bcube(nema17_size, cr = nema17_cr, cres = nema17_cres);

      //-- Motor shaft
      color("lightgray")
	translate([0, 0, nema17_size[Z]/2 + nema17_shaft_length/2])
	  cylinder(r = nema17_shaft_diam/2, h = nema17_shaft_length, center = true, $fn=20);
	  
      //-- Motor shaft base
      color("gray")
      translate([0, 0, nema17_size[Z]/2 + nema17_shaft_base_h/2 ])
      cylinder(r = nema17_shaft_base_diam/2, h = nema17_shaft_base_h, center = true, $fn = 100);
    }
    
    translate([0, 0, nema17_size[Z]/2])
    nema17_drills(l = 10);
  }
  
}



translate(-xrod_pos)
  cylinder(r = 8/2, h = 70, center = true, $fn = 50);



//-- Manually adjutable build plate
build_plate(3,200,200);

nema17_motor();




