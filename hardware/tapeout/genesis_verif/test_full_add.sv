//
//--------------------------------------------------------------------------------
//          THIS FILE WAS AUTOMATICALLY GENERATED BY THE GENESIS2 ENGINE        
//  FOR MORE INFORMATION: OFER SHACHAM (CHIP GENESIS INC / STANFORD VLSI GROUP)
//    !! THIS VERSION OF GENESIS2 IS NOT FOR ANY COMMERCIAL USE !!
//     FOR COMMERCIAL LICENSE CONTACT SHACHAM@ALUMNI.STANFORD.EDU
//--------------------------------------------------------------------------------
//
//  
//	-----------------------------------------------
//	|            Genesis Release Info             |
//	|  $Change: 11789 $ --- $Date: 2013/03/25 $   |
//	-----------------------------------------------
//	
//
//  Source file: /nobackup/nikhil3/github/CGRAGenerator/hardware/generator_z/pe_new/pe/rtl/test_full_add.svp
//  Source template: test_full_add
//
// --------------- Begin Pre-Generation Parameters Status Report ---------------
//
//	From 'generate' statement (priority=5):
//
//		---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
//
//	From Command Line input (priority=4):
//
//		---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
//
//	From XML input (priority=3):
//
//		---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
//
//	From Config File input (priority=2):
//
// ---------------- End Pre-Generation Pramameters Status Report ----------------

// dual (_GENESIS2_DECLARATION_PRIORITY_) = 0
//
module test_full_add  #(
  parameter DataWidth = 16
) (

  input  [DataWidth-1:0]        a,
  input  [DataWidth-1:0]        b,
  input                         c_in,
  output logic [DataWidth-1:0]  res,
  output logic                  c_out
);

assign {c_out, res} = a + b + c_in;

endmodule

