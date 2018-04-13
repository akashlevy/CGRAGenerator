

module lb_tb ();
	reg clk;
	reg reset;
	reg [15:0] data_in;
	reg [15:0] data_out;
	reg [31:0] i;
	reg startup;
	reg [31:0] config_addr;
	reg [31:0] config_data;
	reg config_en;
	reg flush;
	reg wen_in;		
	memory_core_unq1 mem_core (
		.clk_in(clk),
		.clk_en(1),
		.reset(reset),
		.config_en(config_en),
		.config_en_sram(config_en),
		.config_addr(config_addr),
		.config_data(config_data),
		.data_in(data_in),
		.data_out(data_out),
		.wen_in(wen_in),
		.ren_in(0),
		.valid_out(valid_out),
		.chain_in(0),
		.flush(flush)
	);

	initial begin
		clk = 0;
		flush = 0;
		config_en = 0;
		reset = 1;
		config_addr = 0;
		flush = 0;
		data_in = 0;
		startup = 0;
		repeat(3)@ (posedge clk);
		reset = 0;
		@ (posedge clk);
		config_en = 1;
		config_addr = 0;
		config_data = {16'b0,13'd10,1'b1,2'b0};
		@ (posedge clk);
		config_en = 0;
		@ (posedge clk);
		startup = 1;
	end
	always begin
		#5
		clk = ~clk;
	end
	always @ (posedge clk) begin
		if(startup) begin
			i = i+1;
			//wen_in = (i < 15) || (i > 20 && i < 40) || (i > 45);
			wen_in = $urandom_range(1,0);
			if( wen_in == 1 && i>1)
				data_in = data_in + 1;
		end
		else begin
			i = 0;
			data_in = 1;
			wen_in = 0;
		end
	end
endmodule
