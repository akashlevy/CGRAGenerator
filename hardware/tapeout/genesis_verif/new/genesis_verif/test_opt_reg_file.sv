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
//  Source file: /nobackup/nikhil3/github/CGRAGenerator/hardware/generator_z/pe_new/pe/rtl/test_opt_reg_file.svp
//  Source template: test_opt_reg_file
//
// --------------- Begin Pre-Generation Parameters Status Report ---------------
//
//	From 'generate' statement (priority=5):
// Parameter reg_cnt 	= 1
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

// reg_cnt (_GENESIS2_INHERITANCE_PRIORITY_) = 1
//


module  test_opt_reg_file  #(
  parameter DataWidth = 16
) (
  input                  clk,
  input                  clk_en,
  input                  rst_n,

  input                  load,
  input  [DataWidth-1:0] val,


  input  [2:0]           mode,

  input        [DataWidth-1:0] data_in,
  output logic [DataWidth-1:0] res,
  output logic [DataWidth-1:0] reg_data
);

logic [DataWidth-1:0] data_in_reg [0:0];
logic [DataWidth-1:0] data_in_reg_next;
logic                 data_in_le;

localparam REG_CONST  = 3'h0; // FF is loaded only when 'load'=1 with 'val'
localparam REG_VALID  = 3'h1; // Pipeline delay with clock_en = 'clk_en'
localparam REG_BYPASS = 3'h2; // FF is bypassed
localparam REG_DELAY  = 3'h3; // Assumes data is always valid
localparam REG_FILE   = 3'h4;



assign data_in_reg_next = load ? val : data_in;
assign data_in_le       = load | (mode == REG_DELAY) |
                          ((mode == REG_VALID) & clk_en);

always_ff @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    data_in_reg[0] <= 'h0;
  end else if(data_in_le) begin
    data_in_reg[0] <= data_in_reg_next;
  end
end

assign res = (mode == REG_BYPASS) ? data_in : data_in_reg[0];
assign reg_data = data_in_reg[0];

endmodule
