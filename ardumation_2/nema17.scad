use <libs/obiscad/bcube.scad>

//-- Constants
X = 0;
Y = 1;
Z = 2;

extra = 10;


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


//-- 4 drills for the M3 screws
module nema17_drills(l = nema17_size[Z])
{
  for (i=[0:3]) {
    translate([nema17_drill_radial_dist * cos(i*90 + 45),
               nema17_drill_radial_dist * sin(i*90 + 45),
               0])
      cylinder(r = nema17_drill_diam/2, h = l, center = true, $fn = 6);
  }
}

//------------------------------------------------
//-- NEMA17 stepper motor
//-- Parameters:
//--    clearance: extra size for the nema17 perimeter
//--    only_body: If true, only he nema17 body is shown
//--
//--  These two parameters are usefulll for creating room for the
//--  nema17 motors just by substracting he motor to he other parts
//------------------------------------------------
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
