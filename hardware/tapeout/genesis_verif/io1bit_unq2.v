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
//  Source file: /nobackup/nikhil3/github/CGRAGenerator/hardware/generator_z/io1bit/io1bit.vp
//  Source template: io1bit
//
// --------------- Begin Pre-Generation Parameters Status Report ---------------
//
//	From 'generate' statement (priority=5):
// Parameter io_group 	= 3
// Parameter side 	= 0
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

// io_group (_GENESIS2_INHERITANCE_PRIORITY_) = 3
//
// side (_GENESIS2_INHERITANCE_PRIORITY_) = 0
//


module io1bit_unq2 (
clk, 
reset,
pad,
p2f,
f2p_16,
f2p_1,
config_addr,
config_data,
config_write,
config_read,
tile_id,
read_data,
rte,
esd);

  input rte;
  input esd;
  /* verilator lint_off UNUSED */
  input  clk;
  input  reset;
  inout  pad;
  output p2f;
  input f2p_16;
  input f2p_1;
  input [31:0] config_data;
  input [31:0] config_addr;
  input config_read;
  input config_write;
  input [15:0] tile_id;
  output reg [31:0] read_data;
  /* verilator lint_on UNUSED */

  wire muxed_f2p;
  wire rte, esd;

  reg config_en;
  always @(*) begin
    if (reset) begin
       config_en = 1'b0;
    end else begin
       if (config_write&&(config_addr[15:0]==tile_id)&&(config_addr[23:16]==8'd0)) begin
         config_en = 1'b1;
       end else begin
         config_en = 1'b0;
       end
    end
  end
  reg io_bit;
  reg out_bus;
  always @(posedge clk or posedge reset) begin
    if (reset==1'b1) begin
       io_bit = 1'b0;
       out_bus = 1'b0;
    end else begin
       if (config_en==1'b1) begin
         io_bit = config_data[0];
         out_bus = config_data[1];
       end
    end
  end

  always @(*) begin
    if (config_read&&(config_addr[15:0]==tile_id)&&(config_addr[23:16]==8'd0)) begin
      read_data = {io_bit, out_bus}; 
    end
    else begin
      read_data = 'h0;
    end
  end
  //assign pad = (io_bit==1'b1)?((out_bus==1'b0)?f2p_16:f2p_1):1'bz;
  //assign p2f = pad;

  assign muxed_f2p = (out_bus==1'b0) ? f2p_16 : f2p_1;

PRWDWUWSWCDGH_H IOPAD(
  .PAD(pad),
  .I(muxed_f2p),
  .OEN(io_bit),
  .ST(1'b0),
  .SL(1'b0),
  .IE(io_bit),
  .C(p2f),
  .DS0(1'b0), 
  .DS1(1'b0), 
  .DS2(1'b0),
  .PU(1'b0),
  .PD(1'b0), 
  .RTE(rte),
  .ESD(esd)
);



endmodule




