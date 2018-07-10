module top();

   reg [31:0] config_addr;
   reg [31:0] config_data;
   reg 	      clk;
   reg 	      reset;

   initial begin
      #1 config_addr = 0;
      #1 config_en = 0;

      #1 reset = 0;
      #1 reset = 1;
      #1 reset = 0;

      #1 config_en = 1;
      #1 config_data = 32'h1;
      
      #1 clk = 0;
      #1 clk = 1;

      #1 config_en = 0;

      
      
      $finish();
   end

   cb connect_box(.clk(clk), .reset(reset), .config_addr(config_addr), .config_data(config_data), .config_en(config_en));
   
endmodule
