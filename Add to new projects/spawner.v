module spawner(clk, reset, enable, frequency, spawn, out);
	input clk, reset, enable;
	// input clk should be CLOCK_50
	input [1:0] frequency;
	// frequency at which the pseudo_random numbers cycle. Also determines how long the spawn signal will be held for.
	// 00 for making it enable signal, 01 for 1hz, 10 for 2hz, 11 for 3hz
	output spawn;
	output [9:0] out;
	// 10 digit output, can handle up to height of 1023 pixels
	// might have to put an if statement in the drawing module if the height has to be i.e. between 0 and 800, to check if out value is in the range
	
	wire hertzclk;
	wire spawnenable;
	wire onesecond;
	
	// the modules were written with activehigh reset so it is negated in the modules below
	slowclk c0(clk, ~reset, enable, frequency, hertzclk);
	slowclk c1(clk, ~reset, enable, 2'b01, onesecond);
	LFSR lfsr0(hertzclk, ~reset, spawnenable, spawn, out);
	
	spawncountdown sp0(onesecond, ~reset, enable, spawn, 3'b011, spawnenable);
	// wait for minimum 3 seconds between spawns 
	
	
endmodule 

module spawncountdown (clk, reset, enable, spawn, secs, out);
	// counts down for secs seconds (meant for minimum time in between spawns)
	// out returns 0 or 1, used to enable the LFSR so that there can potentially be another spawn
	input spawn, clk, reset, enable;
	input [2:0] secs;
	// 3 bit input, can wait up to 8 secs
	output reg out;
	
	initial out = 1'b0;
	reg [2:0] q;

	always @(posedge clk, posedge reset, posedge spawn) begin
		if (reset) begin
			q <= secs;
			out <= 1'b0;
		end
		else if (enable) begin
			if (q == 0) begin
				if (spawn == 1) begin
					q <= secs;
					out <= 1'b0;
				end
				else begin
					out <= 1'b1;
				end
			end
			else begin
				q <= q - 1'b1;
				out <= 1'b0;
			end
		end
	end

endmodule

module slowclk (clk, reset, enable, frequency, out);
	input clk, reset, enable;
	// should make input clk be CLOCK_50
	input [1:0] frequency;
	output reg out;
	// this is the slower 'clock', will output 0 or 1

	wire [27:0] w1hz, w2hz, w3hz;

	ratedivider r12hz(enable, {6'b0, 22'd4165165}, clk, reset, w1hz);
	ratedivider r60hz(enable, {8'b0, 20'd833333}, clk, reset, w2hz);
	ratedivider r24hz(enable, {7'b0, 21'd2082582}, clk, reset, w3hz);

	// faster dividers for testing. Uncomment top and comment below for actual. 
//	ratedivider r1hz(enable, {26'd0, 2'b11}, clk, reset, w1hz);
//	ratedivider r2hz(enable, {26'd0, 2'b10}, clk, reset, w2hz);
//	ratedivider r3hz(enable, {26'd0, 2'b01}, clk, reset, w3hz);
	
	always @(*)
		begin
			case(frequency)
				2'b00: out <= enable;
				2'b01: out <= (w1hz == 28'd0) ? 1'b1 : 1'b0;
				2'b10: out <= (w2hz == 28'd0) ? 1'b1 : 1'b0;
				2'b11: out <= (w3hz == 28'd0) ? 1'b1 : 1'b0;
			endcase
		end
		
endmodule

module LFSR (clk, reset, enable, spawn, out);
	input clk, reset, enable;
	// ToDo: make a counter hooked to enable so that there is a gap between each spawn. Make spawn reset the counter. 
	output reg [9:0] out;
	// ToDo: set bits of out to match y-value of screen resolution - height of objects 
	output reg spawn;
	
	reg [9:0] value;
	wire linear_feedback;
	
	assign linear_feedback = (value[1] ^ value[0]);
	
	initial out = 10'b0;
	initial spawn = 0;
	initial value = 10'b0010010100;
	
	always @ (posedge clk, posedge reset) begin
		if (reset) begin
		// seed 
		value <= 10'b0010010100;
		// ToDo: adjust out bits if necessary
		out <= 10'b0;
		spawn <= 0;
		end
		else if (enable) begin
		value <= {linear_feedback,value[9],value[8],value[7],value[6],value[5],value[4],value[3],value[2],value[1]};
		out <= value[9:0];
		spawn <= linear_feedback;
		end
		else begin
		out <= 10'b0;
		spawn <= 0;
		end
	end

endmodule

module ratedivider(enable, load, clk, reset, q);
	input enable, clk, reset;
	input [27:0] load;
	output reg [27:0] q;
	
	initial q = load;
	
	always @(posedge clk)
	begin
		if (reset)
			q <= load;
		else if (enable)
			begin
				if (q == 28'd0)
					q <= load;
				else
					q <= q - 1'b1;
			end
	end
endmodule
