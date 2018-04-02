// Part 2 skeleton

module SpriteAnimation
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
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
	reg writeEn_reg;
	wire enable,ld_x,ld_y,ld_c;
//	wire [15:0] out;
//	wire [9:0] addr_read;

	wire go_up = ~KEY[2];
	wire go_down = ~KEY[3];
	

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
	 
//		topramsprite snow(CLOCK_50, addr_read, out);
//		drawsnowman d0(CLOCK_50, addr_read);
//		translateout t0(CLOCK_50, out, x_coord, yout_reg, x, y, colour, writeEn_out);
		
		always @(*) begin
			if (backTOwait) begin 
				writeEn_reg <= 1'b0;
			end 
			else begin 
				writeEn_reg <= ~KEY[1];
			end
		end
		assign writeEn = writeEn_reg;
		
	// Try shifting the snowman left automatically
//		
//		wire [7:0] x_coord;
//		wire [6:0] y_coord;
//		wire onesecond;
//		
//		slowclk c1(CLOCK_50, ~KEY[0], 1'b1, 2'b11, onesecond);
//		coordshifter cs0(onesecond, resetn, 1'b1, x_coord, y_coord);
		
//		assign LEDR [0] = x_coord[0];
//		assign LEDR [1] = x_coord[1];
//		assign LEDR [2] = x_coord[2];
//		assign LEDR [3] = x_coord[3];
//		assign LEDR [4] = x_coord[4];

		
		// try spawning
		
		// Block starts
  // The random generation for y.
//  wire spawn;
//  wire [9:0] yout;
//  reg [6:0] yout_reg;
//  LFSR random0(CLOCK_50, ~resetn, 1'b1, spawn, yout);
//  
//  always @(posedge CLOCK_50) begin
//   if (x_coord == 8'b0) begin
//    yout_reg <= yout[5:0] + yout[3:0];
//   end
//  end
  // Block ends
   wire wren_out;
//	datapath d0(CLOCK_50, resetn, KEY[2], x, y, colour, wren_out);

	wire backTOwait;
	datapath d0(CLOCK_50, resetn, go_up, go_down, x, y, colour, wren_out, backTOwait);
	
endmodule

module drawsnowman(clock, addr_read);
	input clock;
	output reg [9:0] addr_read;
	initial addr_read = 10'b0;
	always @ (posedge clock) begin
		if (addr_read < 10'd840) begin
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
		writeEn <= wren;
		if (coord_x == 8'b0) begin
			colour <= 3'b0;
		end
		else begin
			colour <= col;
		end
	end

endmodule

module coordshifter(clock, reset, go_back, snowx_coord, snowy_coord);
	input clock, reset, go_back;
	
	output reg [7:0] snowx_coord;
//	initial snowx_coord = 8'b00001011;
		
	output reg [6:0] snowy_coord;
//	initial snowy_coord = 7'b0010111;
		
	always @ (posedge clock, negedge reset) begin
		if (!reset) begin
			snowx_coord <= 8'd138;
			snowy_coord <= 7'b0010111;
		end
		else begin 
			if (snowx_coord == 8'b0) begin
				if (go_back) begin
					snowx_coord <= 8'd138;
				end
				else begin 
				snowx_coord <= 8'b0;
				end
			end
			else begin
				snowx_coord <= snowx_coord - 1'b1;
			end
		end
	end
endmodule

module datapath(clock, resetn, go_up, go_down, x_out, y_out, colour_out, wren_out, backTOwait);
	input clock, resetn, go_up, go_down;
	output reg [7:0] x_out;
	output reg [6:0] y_out;
	output reg [2:0] colour_out;
	output reg wren_out;
	output reg backTOwait;
	
	wire [7:0] x_k;
	wire [6:0] y_k;
	wire [2:0] colour_k;
	wire writeEn_k;
	
	wire [15:0] out;
	wire [9:0] addr_read;
	
	wire [7:0] x;
	wire [6:0] y;
	wire [2:0] colour;
	wire writeEn_out;
	
	reg [6:0] kev_y;
	always @(posedge halfc1) begin
		if (~resetn) begin
			kev_y <= 7'd50;
			backTOwait <= 1'b0;
		end
		if ((8'd14 >= x_coord) && (yout_reg <= kev_y + 7'b0010101 ) && (kev_y <= yout_reg + 7'b0100111)) begin
			backTOwait <= 1'b1;
		end
		else begin
			if (go_up && (kev_y > 7'b0) 366) begin
				kev_y <= kev_y - 1'b1;
			end
			else begin
				if (go_down && (kev_y < 7'd98)) begin 
					kev_y <= kev_y + 1'b1; 
				end 
			end 
		end 
	end 

	Kevin k0(clock, 8'd5, kev_y, x_k, y_k, colour_k, writeEn_k);
	
//	wire [6:0] y_up;
//	wire [6:0] y_down;
//	assign y_up = 
	
	topramsprite snow(clock, addr_read, out);
	drawsnowman d0(clock, addr_read);
	translateout t0(clock, out, x_coord, yout_reg, x, y, colour, writeEn_out);
	
	wire [7:0] x_coord;
	wire [6:0] y_coord;
	wire onesecond;
	wire halfc1;
		
	slowclk c1(clock, ~resetn, 1'b1, 2'b11, onesecond);
	slowclk c2(clock, ~resetn, 1'b1, 2'b01, halfc1);
	coordshifter cs0(onesecond, resetn, 1'b1, x_coord, y_coord);
	
	wire spawn;
   wire [9:0] yout;
   reg [6:0] yout_reg;
   LFSR random0(clock, ~resetn, 1'b1, spawn, yout);
	
	wire [1:0] sprite_num;
	control(clock, resetn, sprite_num);
  
   always @(posedge clock) begin
		if (x_coord == 8'b0) begin
			yout_reg <= yout[5:0] + yout[3:0];
		end
   end
	
	always @(*) begin
		x_out = 8'd0;
		y_out = 7'd0;
		colour_out = 3'd0;
		wren_out = 1'b0;
	
		case (sprite_num)
			2'b00: begin
				x_out = 8'd0;
				y_out = 7'd0;
				colour_out = 3'd0;
				wren_out = 1'b0;
			end
			2'b01: begin
				x_out = x_k;
				y_out = y_k;
				colour_out = colour_k;
				wren_out = writeEn_k;
			end
			2'b10: begin
				x_out = x;
				y_out = y;
				colour_out = colour;
				wren_out = writeEn_out;
			end
			default: begin
				x_out = 8'd0;
				y_out = 7'd0;
				colour_out = 3'd0;
				wren_out = 1'b0;
			end
		endcase
	end
	
endmodule

module control(clock, resetn, sprite_num);
	input clock, resetn;
	output reg [1:0] sprite_num;

	wire sixtyHz;

	slowclk slow0(clock, ~resetn, 1'b1, 2'b10, sixtyHz);
	
	reg [1:0] current_state, next_state;
	
	localparam CYCLE_WAIT = 2'b00,
					CYCLE_KEV = 2'b01,
					CYCLE_SNOWMAN = 2'b10;
					
	always@(*)
      begin: state_table 
            case (current_state)
                CYCLE_WAIT: next_state = CYCLE_KEV; 
                CYCLE_KEV: next_state = CYCLE_SNOWMAN;
                CYCLE_SNOWMAN: next_state = CYCLE_WAIT;
            default:     next_state = CYCLE_WAIT;
        endcase
      end 
	
	always @(*) begin
		// reset all parameters
		sprite_num <= 2'b00;
	
		case(current_state)
			CYCLE_WAIT: begin
				sprite_num <= 2'b00;
			end
			CYCLE_KEV: begin 
				sprite_num <= 2'b01;
			end
			CYCLE_SNOWMAN: begin 
				sprite_num <= 2'b10;
			end
			default: sprite_num <= 2'b00;
		endcase
	end
	
	always@(posedge sixtyHz)
   begin: state_FFs
		if(!resetn) begin 
         current_state <= CYCLE_WAIT;
		end
      else begin 
			current_state <= next_state;
		end
   end 
	
endmodule
