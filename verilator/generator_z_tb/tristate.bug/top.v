module top (
  inout  [15:0] bus1,
  input en1, // Set to 0 for input, 1 for output

  input clk,
  output [15:0] result
);
tri  [15:0] bus1;
wire en1;
wire clk;
wire [15:0] result;

wire [15:0] bus1_in;

// Bidirectional bus 1
// If en1==0 can read id '13333' from bus1
// else bus1 = whatever harness sets it to
assign bus1 = en1 ? 13333 : 16'bz;

assign result = bus1 + 10000;

/*
always @(bus1 or en1 or clk) begin
  $display("        %m: en1=%0b bus1=%d", en1, bus1);
end
*/

endmodule


