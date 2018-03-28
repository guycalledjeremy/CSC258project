// Part 2 skeleton

module SpriteAnimation
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		  LEDR,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	output [9:0] LEDR;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock      
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire enable,ld_x,ld_y,ld_c;
	wire [15:0] out;
	wire [9:0] addr_read;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		
		
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
//    	assign x_coord = SW[7:0];
	 
		topramsprite snow(CLOCK_50, addr_read, out);
		drawsnowman d0(CLOCK_50, addr_read);
		translateout t0(CLOCK_50, out, x_coord, 7'b0010111, x, y, colour, writeEn_out);
		
		assign writeEn = ~KEY[2];
		
//		slowclk c1(CLOCK_50, ~resetn, 1'b1, 2'b01, onesecond);
//		wire [27:0] q;
//		ratedivider(~KEY[1], {2'b00, 26'd49999999}, CLOCK_50, ~resetn, q);

//		assign LEDR[1] = ~onesecond;
//		assign LEDR[0] = onesecond;
//		
//		reg a1;
//		assign LEDR[2] = a1;
//		
//		always @(posedge onesecond) begin
//			if (a1) begin
//				a1 <= 1'b0;
//			end
//			else begin
//				a1<= 1'b1;
//			end
//		end


//		reg [7:0] a_reg;
//		wire [7:0] a = a_reg;
//		
//		always @(onesecond) begin
//			if (a == 8'b00010111) begin
//				a_reg <= 8'b00101110;
//			end
//			else begin
//				a_reg <= 8'b00010111;
//			end
//		end
		
		//assign LEDR[0] = onesecond;
		
	// Try shifting the snowman left automatically
//		
		wire [7:0] x_coord;
		wire [6:0] y_coord;
		wire onesecond;
		
		slowclk c1(CLOCK_50, ~KEY[0], 1'b1, 2'b01, onesecond);
		coordshifter cs0(onesecond, resetn, x_coord, y_coord);
		
		assign LEDR [0] = x_coord[0];
		assign LEDR [1] = x_coord[1];
		assign LEDR [2] = x_coord[2];
		assign LEDR [3] = x_coord[3];
		assign LEDR [4] = x_coord[4];


    
endmodule

module drawsnowman(clock, addr_read);
	input clock;
	output reg [9:0] addr_read;
	initial addr_read = 10'b0;
	always @ (posedge clock) begin
		if (addr_read < 10'd800) begin
			addr_read <= addr_read + 1'b1;
		end
		else begin
			addr_read <= 10'b0;
		end
	end
endmodule

module translateout(clock, out, coord_x, coord_y, x, y, colour, writeEn);
	input clock;
	input [15:0] out;
	input [7:0] coord_x;
	input [6:0] coord_y;
	output reg [7:0] x;
	output reg [6:0] y;
	output reg writeEn;
	output reg [2:0] colour;
	wire [5:0] x_rel;
	wire [5:0] y_rel;
	wire [2:0] col;
	wire wren;
	
	assign x_rel = out[15:10];
	assign y_rel = out[9:4];
	assign col = out[3:1];
	assign wren = out[0];
	
	always @ (posedge clock) begin
		x <= coord_x + x_rel;
		y <= coord_y + y_rel;
		colour <= col;
		writeEn <= wren;
	end

endmodule

module coordshifter(clock, reset, snowx_coord, snowy_coord);
	input clock, reset;
	
	output reg [7:0] snowx_coord;
//	initial snowx_coord = 8'b00001011;
		
	output reg [6:0] snowy_coord;
//	initial snowy_coord = 7'b0010111;
		
	always @ (posedge clock, negedge reset) begin
		if (!reset) begin
			snowx_coord <= 8'b00001011;
			snowy_coord <= 7'b0010111;
		end
		else begin 
			if (snowx_coord == 8'b0) begin
				snowx_coord <= 8'b00001011;
			end
			else begin
				snowx_coord <= snowx_coord - 1'b1;
			end
		end
	end
endmodule
