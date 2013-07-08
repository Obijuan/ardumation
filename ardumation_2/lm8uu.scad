//-- Constants
X = 0;
Y = 1;
Z = 2;

extra = 10;


//-- Linear bearing LM8UU data

lm8uu_diam = 15;  //-- Outer diameter
lm8uu_len = 25;   //-- Axial length
lm8uu_idiam = 8;  //-- Inner diameter
lm8uu_clearance = 2;

//-- Size of the zip tie holes
co_zip_tie_size = [5, 1.5];

co_lm8uu_size = [lm8uu_len, lm8uu_diam/2 + 2];
co_zip_tie_pos = [co_lm8uu_size[X]/4, 
                  co_zip_tie_size[Y]/2 + co_lm8uu_size[Y]/2 + lm8uu_clearance ,
                  0];


//-- lm8uu + zip-ties bounding box              
lm8uu_box_size = [co_lm8uu_size[X], 
                  co_lm8uu_size[Y] + 2*(lm8uu_clearance + co_zip_tie_size[Y]),
                  extra];

//--------------------------------------------------------------------------------
//-- Build a lm8uu part
//--
//--   Parameters:
//--  * clearance: extra diameter
//--  * only_body: Draw only the lm8uu body
//--  
//-- These parameters are mainly used for substracting the lm8uu to other part
//--------------------------------------------------------------------------------
module lm8uu(clearance = 0, only_body = false)
{

  lm8uu_final_diam = lm8uu_diam + clearance;

  difference() {
    cylinder(r = lm8uu_final_diam/2, h = lm8uu_len, center = true, $fn = 50);
    
    if (only_body == false)
      cylinder(r = lm8uu_idiam/2, h = lm8uu_len + extra, center = true, $fn = 50);
  }  
  
}

//----------------------------------------------------
//-- Linear bearing lm8uu + holes for the zip tie
//----------------------------------------------------
module lm8uu_box(h  = 10)
{

  co_zip_tie_size_3D = [co_zip_tie_size[X],
                        co_zip_tie_size[Y],
                        h + extra];

  zip_tie_table = [
    [co_zip_tie_pos[X], co_zip_tie_pos[Y], co_zip_tie_pos[Z]],
    [-co_zip_tie_pos[X], co_zip_tie_pos[Y], co_zip_tie_pos[Z]],
    [-co_zip_tie_pos[X], -co_zip_tie_pos[Y], co_zip_tie_pos[Z]],
    [co_zip_tie_pos[X], -co_zip_tie_pos[Y], co_zip_tie_pos[Z]],
  ];
  
  //------------- Build the object
  
  //-- Central cutout
  bcube([co_lm8uu_size[X], co_lm8uu_size[Y], h + extra], cr = 2, cres = 4);
  
  //-- Zip tie holes
  for (pos = zip_tie_table) {
    translate(pos)
      cube(co_zip_tie_size_3D, center = true);
  }
  
}


//-- Examples
//lm8uu();
//lm8uu(clearance = 2, only_body = true);

