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
//  Source file: /nobackup/nikhil3/github/CGRAGenerator/hardware/generator_z/global_signal_tile/global_signal_tile.vp
//  Source template: global_signal_tile
//
// --------------- Begin Pre-Generation Parameters Status Report ---------------
//
//	From 'generate' statement (priority=5):
// Parameter global_signal_count 	= 4
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

// global_signal_count (_GENESIS2_INHERITANCE_PRIORITY_) = 4
//

module global_signal_tile_unq1 (
gin_l_0,
gin_u_0,
gout_l_0,
gin_l_1,
gin_u_1,
gout_l_1,
gin_l_2,
gin_u_2,
gout_l_2,
gin_l_3,
gin_u_3,
gout_l_3,
gout_u,
clk,
reset,
config_addr,
config_data,
config_read,
config_write,
tile_id,
read_data
);
  input gin_l_0;
  input gin_u_0;
  input gin_l_1;
  input gin_u_1;
  input gin_l_2;
  input gin_u_2;
  input gin_l_3;
  input gin_u_3;
  output reg gout_l_0;
  output reg gout_l_1;
  output reg gout_l_2;
  output reg gout_l_3;
  output reg gout_u;
  input  clk;
  input  reset;
  input [31:0] config_addr;
  input [31:0] config_data;
  input config_read;
  input config_write;
  input [15:0] tile_id;
  output reg [31:0] read_data;

 reg [3:0] config_reg;
 always @(posedge clk or posedge reset) begin
   if (reset==1'b1) begin
     config_reg <= {4'd0};
   end else begin
       if (config_write && (config_addr[15:0]==tile_id)&&(config_addr[23:16]==8'd0)&&(config_addr[31:24]==8'd0)) begin
         config_reg <= config_data[3:0];
       end
   end
 end
  always @(*) begin
    if (config_read && (config_addr[15:0]==tile_id)&&(config_addr[23:16]==8'd0)&&(config_addr[31:24]==8'd0)) begin
      read_data = config_reg;
    end
    else begin
      read_data = 'h0;
    end
  end
  always @(*) begin
    gout_u = gin_l_0 | gin_l_1 | gin_l_2 | gin_l_3 | 1'b0;
  end

  always @(*) begin
    case (config_reg[0])
      1'd0: gout_l_0 = gin_u_0;
      1'd1: gout_l_0 = gin_l_0;
      default: gout_l_0 =  gin_u_0;
    endcase
  end
  always @(*) begin
    case (config_reg[1])
      1'd0: gout_l_1 = gin_u_1;
      1'd1: gout_l_1 = gin_l_1;
      default: gout_l_1 =  gin_u_1;
    endcase
  end
  always @(*) begin
    case (config_reg[2])
      1'd0: gout_l_2 = gin_u_2;
      1'd1: gout_l_2 = gin_l_2;
      default: gout_l_2 =  gin_u_2;
    endcase
  end
  always @(*) begin
    case (config_reg[3])
      1'd0: gout_l_3 = gin_u_3;
      1'd1: gout_l_3 = gin_l_3;
      default: gout_l_3 =  gin_u_3;
    endcase
  end
endmodule
