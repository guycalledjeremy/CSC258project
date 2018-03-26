// Part 2 skeleton

module p2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
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

//	initial snow_xcoord = 7'b0101011;
//	initial snow_ycoord = 6'b010111;
	// these should be in control
	wire onesecond;

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
    
    // Instansiate datapath
	// datapath d0(...);
//      datapath d0(SW[6:0],SW[9:7],CLOCK_50,KEY[0],enable,ld_x,ld_y,ld_c,x,y,colour);
//		topramsprite snow(CLOCK_50, addr_read, out);
//		drawsnowman(CLOCK_50, addr_read);
//		translateout(CLOCK_50, out, snow_xcoord, snow_ycoord, x, y, colour, writeEn);
		snowman(clock, reset, 6'b010111, 1'b1, onesecond, x, y, colour_out, writeEn, spawn_rdy);
		blacken(x, bx_out, bcolour_out);
		// replace these 4 with datapath after

    // Instansiate FSM control
    // control c0(...);
//	   control c0(KEY[0],onesecond,ld_x,ld_y,ld_colour,ld_writeEn);
		// when ld_ is high it loads the color pixels, when low it loads the black pixels
		slowclk c1(CLOCK_50, ~KEY[0], 1'b1, 2'b01, onesecond);
		

    
endmodule

module snowman(clock, reset, spawn_y, spawn_sig, move_sig, x, y, colour_out, writeEn, spawn_rdy);
// continuously returns global x y coordinates for a snowman with given top left coords snow_x & ycoord
//movesig is a slower clock
	input clock;
	input reset;
	input [6:0] spawn_y;
	input spawn_sig, move_sig;
	output [7:0] x;
	output [6:0] y;
	output reg [2:0] colour_out;
	output reg writeEn;
	output spawn_rdy;
	
	reg [7:0] snow_xcoord;
	reg [6:0] snow_ycoord;

	initial snow_xcoord = 8'b10001011;
	wire [9:0] addr_read;
	wire [15:0] out;
	wire [2:0] colour;
	
	topramsprite snow(clock, addr_read, out);
	drawsnowman(clock, addr_read);
	translateout(clock, out, snow_xcoord, snow_ycoord, x, y, colour, writeEn);
	
	reg [3:0] current_state, next_state;
	
	localparam  Load_y = 4'd0,
					Load_y_wait = 4'd1,
					S_PLOT   = 4'd2,
               S_MOVE   = 4'd3,
					S_ENDSCREEN = 4'd4,
               S_CYCLE  = 4'd5;
	
	always@(*)
   begin: state_table 
		case (current_state)
			Load_y: next_state = spawn_sig? Load_y_wait : Load_y;
			Load_y_wait: next_state = spawn_sig? Load_y_wait : S_PLOT;
			S_PLOT: next_state =  (snow_xcoord == 8'd0) ? S_ENDSCREEN : S_MOVE; 
			S_MOVE: next_state = (snow_xcoord == 8'd0) ? S_ENDSCREEN : S_MOVE;
			S_ENDSCREEN: next_state = S_CYCLE;
			S_CYCLE: next_state = Load_y;
         default:     next_state = Load_y;
      endcase
   end 
		
	always @(*) begin
		writeEn <= 1'b0;
		colour_out <= colour;
		
		case (current_state)
			Load_y: begin
				snow_xcoord = 8'b10001011;
			end
			Load_y_wait: begin
				snow_ycoord = spawn_y;
			end
			S_PLOT: begin
				writeEn = 1'b1;
			end
			S_MOVE: begin
				writeEn = 1'b1;
				snow_xcoord = snow_xcoord - 1;
			end
			S_ENDSCREEN: begin
				colour_out = 3'b000;
			end
			S_CYCLE: begin
				snow_xcoord = 8'b10001011;
			end
		endcase
	end
	
	
	always @(posedge move_sig) begin
		if (!reset)
			current_state <= Load_y;
		else
			current_state <= next_state;
	end

endmodule

module blacken(x_in, x_out, colour_out);
// takes the output of a draw and returns a black rectangle 1 x unit to the right (+1)
// move the sprite first and then draw from this to black out the previous location then draw the new sprite
	input [7:0] x_in;
	output [7:0] x_out;
	output [2:0] colour_out;
	
	assign colour_out = 3'b000;
	assign x_out = x_in + 1;

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

//module datapath(); 
//
//endmodule

//module control(reset_n,clock,ld_x,ld_y,ld_c,plot);
//		input go,reset_n,clock,KEY;
//		reg drawhigh;
//		reg endscreen;
//		
//		output reg ld_x,ld_y,ld_c,plot;
//		
//		reg [3:0] current_state, next_state;
//
//		localparam  S_PLOT      = 4'd0,
//                S_MOVE   = 4'd1,
//                S_STOP        = 4'd2,
//                S_CYCLE   = 4'd3,
//		
////		always@(*)
////      begin: state_table 
////            case (current_state)
////                S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X; 
////                S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_LOAD_Y; 
////                S_LOAD_Y: next_state = KEY ? S_LOAD_Y_WAIT : S_LOAD_Y; 
////                S_LOAD_Y_WAIT: next_state = KEY ? S_LOAD_Y_WAIT : S_CYCLE_0; 
////                S_CYCLE_0: next_state = S_LOAD_X;
////            default:     next_state = S_LOAD_X;
////        endcase
////      end 
//		
//		always@(*)
//      begin: state_table 
//            case (current_state)
//                S_PLOT: next_state =  endscreen ? S_STOP : S_MOVE; 
//                S_MOVE: next_state = drawhigh ? S_PLOT: S_MOVE; 
//                S_STOP: next_state = KEY ? S_LOAD_Y_WAIT : S_LOAD_Y; 
//                S_CYCLE: next_state = KEY ? S_LOAD_Y_WAIT : S_CYCLE_0; 
//            default:     next_state = S_LOAD_X;
//        endcase
//      end 
//		
//		always@(*)
//      begin: enable_signals
//        // By default make all our signals 0
//        ld_x = 1'b0;
//        ld_y = 1'b0;
//        ld_c = 1'b0;
//		  enable = 1'b0;
//		  plot = 1'b0;
//		  
//		  case(current_state)
//				S_LOAD_X:begin
//					ld_x = 1'b1;
//					end
//				S_LOAD_Y:begin
//					ld_y = 1'b1;
//					end
//				S_CYCLE_0:begin
//					ld_c = 1'b1;
//					enable = 1'b1;
//					plot = 1'b1;
//					end
//		  endcase
//		end
//		
//		
//		always@(posedge clock)
//      begin: state_FFs
//        if(!reset_n)
//            current_state <= S_LOAD_X;
//				drawhigh <= 1'b1;
//        else
//            current_state <= next_state;
//				drawhigh <= drawhigh + 1'b1;
//      end 
//endmodule

//module try(data_in,colour,reset_n,clock,go,KEY,X,Y,Colour);
//		input [6:0] data_in;
//		input [2:0] colour;
//		input reset_n,clock,go,KEY;
//		output[6:0] X,Y;
//		output[2:0] Colour;
//		
//		wire enable,ld_x,ld_y,ld_c,plot;
//		
//		control c(go,reset_n,KEY,clock,enable,ld_x,ld_y,ld_c,plot);
//		datapath d(data_in,colour,clock,reset_n,enable,ld_x,ld_y,ld_c,X,Y,Colour);
//endmodule
		
module counter(clk, q);
	input clk;
	input [27:0] load;
	output reg [27:0] q;
	
	initial q = load;
	
	always @(posedge clk)
	begin
		if (reset)
			q <= load;
		else if (enable)
			begin
				if (q == 0)
					q <= load;
				else
					q <= q - 1'b1;
			end
	end
endmodule
