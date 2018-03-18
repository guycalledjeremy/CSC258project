module frame	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        reset,
        go,
        x_v,
        y_v,
        c_v,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						 //	VGA Clock
		VGA_HS,							   //	VGA H_SYNC
		VGA_VS,							   //	VGA V_SYNC
		VGA_BLANK_N,					 //	VGA BLANK
		VGA_SYNC_N,						 //	VGA SYNC
		VGA_R,   						   //	VGA Red[9:0]
		VGA_G,	 						   //	VGA Green[9:0]
		VGA_B   						   //	VGA Blue[9:0]
	);

	input		    CLOCK_50;				//	50 MHz
    input           reset;
    input           go;
    input [7:0]     x_v;
    input [6:0]     y_v;
    input [2:0]     c_v;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	    [9:0]	VGA_R;   			//	VGA Red[9:0]
	output	    [9:0]	VGA_G;	 			//	VGA Green[9:0]
	output	    [9:0]	VGA_B;   			//	VGA Blue[9:0]

	assign resetn = reset;

	// Create the writeEn wires that are inputs to the controller.
	wire writeEn;
	wire enable;
	wire [3:0] cq;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(c_v),
			.x(x_v),
			.y(y_v),
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
      datapath d0(CLOCK_50,KEY[0],enable, cq);

    // Instansiate FSM control
    // control c0(...);
	  control c0(cq, ~KEY[3],KEY[0],~KEY[1],CLOCK_50,enable,ld_x,ld_y,ld_c,writeEn);
endmodule
// end main module


// Datapath module
module datapath(clock, reset_n, enable1, c_q);
	input 			    reset_n, enable1, clock;
	input 	[6:0] 	data_in;
	output  [3:0]   c_q;

	wire    [1:0]   c1, c2;
    // Counters for x and y.
    // This datapath is drawing a 2^4 * 2^4 block.
    wire    [3:0]   count1;
	counterx m1(clock, reset_n, enable1, count1);
    wire count2 = | count1;
    wire enable2;
    countery m2(clock, reset_n, enable2, count2);

	assign c_q = count2;
	assign c1[1:0] = count[3:2];
	assign c2[1:0] = count[1:0];
	assign X = x1 + c1;
	assign Y = y1 + c2;
	assign Colour = co1;
endmodule
// end Datapath module


// Counterx module
module counterx(clock, reset_n, enable, q);
	input 				clock, reset_n, enable;
	output   reg 	[3:0] 	q;

	always @(posedge clock) begin
		if(reset_n == 1'b0)
			q <= 4'b0000;
		else if (enable == 1'b1)
			q <= q + 1'b1;
		  if (q == 4'b1111) begin
			   q <= 4'd0;
		  end
   end
endmodule
// end Counterx module


// Countery module
module countery(clock, reset_n, enable, q);
	input 				clock, reset_n, enable;
	output   reg 	[3:0] 	q;

	always @(posedge clock) begin
		if(reset_n == 1'b0)
			q <= 4'b0000;
		else if (enable == 1'b1)
			q <= q + 1'b1;
		if (q == 4'b1111) begin
			q <= 4'd0;
		end
   end
endmodule
// end Countery module


// Control module
module control(c_q, go,reset_n,KEY,clock,enable,plot);
		input go,reset_n,clock,KEY;
		input [3:0] c_q;

		output reg enable,plot;

		reg [3:0] current_state, next_state;

		localparam  S_LOAD_X        = 3'd0,
                S_LOAD_X_WAIT   = 3'd1,
                S_LOAD_Y        = 3'd2,
                S_LOAD_Y_WAIT   = 3'd3,
					      S_CYCLE_0       = 3'd4;

		always@(*)
      begin: state_table
            case (current_state)
                S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X;
                S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_LOAD_Y;
                S_LOAD_Y: next_state = KEY ? S_LOAD_Y_WAIT : S_LOAD_Y;
                S_LOAD_Y_WAIT: next_state = KEY ? S_LOAD_Y_WAIT : S_CYCLE_0;
                S_CYCLE_0: next_state = ({&c_q} == 1'b0) ? S_LOAD_X : S_CYCLE_0;
            default:     next_state = S_LOAD_X;
        endcase
      end

		always@(*)
      begin: enable_signals
        // By default make all our signals 0
        ld_x = 1'b0;
        ld_y = 1'b0;
		    enable = 1'b0;

		  case(current_state)
				S_LOAD_X:begin
					ld_x = 1'b1;
				  plot = 1'b0;
					ld_c = 1'b1;
					end
				S_LOAD_Y:begin
					ld_y = 1'b1;
					end
        S_LOAD_Y_WAIT:begin
          plot = 1'b1;
          end
				S_CYCLE_0:begin
					enable = 1'b1;
					ld_c = 1'b1;
					end
		  endcase
		end


		always@(posedge clock)
      begin: state_FFs
        if(!reset_n)
            current_state <= S_LOAD_X;
        else
            current_state <= next_state;
      end
endmodule
// end Control module
