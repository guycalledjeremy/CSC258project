module frame	(
		CLOCK_50,						   //	On Board 50 MHz
		// My inputs and outputs here
        resetn,
        go,
        erase,
        x,
        y,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						   //	VGA Clock
		VGA_HS,							   //	VGA H_SYNC
		VGA_VS,							   //	VGA V_SYNC
		VGA_BLANK_N,					   //	VGA BLANK
		VGA_SYNC_N,						   //	VGA SYNC
		VGA_R,   					       //	VGA Red[9:0]
		VGA_G,	 				      	   //	VGA Green[9:0]
		VGA_B   						   //	VGA Blue[9:0]
	);

	input		    CLOCK_50;				//	50 MHz
    input           resetn;
    input           go;
    input           erase;
	input	[7:0]	x;
	input	[6:0] 	y;
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

	// Create the writeEn wires that are inputs to the controller.
    wire reset = resetn;
	wire writeEn;
    wire [7:0]     x_v;
    wire [6:0]     y_v;
    wire [2:0]     c_v;


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
    wire next;
	wire enable;
	wire [3:0]     cq;

    // Instansiate datapath
	// datapath d0(...);
      datapath d0(CLOCK_50,reset,enable,erase,next, x, y, c_v, x_v, y_v, cq);

    // Instansiate FSM control
    // control c0(...);
	  control c0(cq,go,rest,CLOCK_50,enable,writeEn,next);
endmodule
// end main module


// Datapath module
module datapath(clock, reset_n, enable1, erase, next_p, x, y, colour, x_v, y_v, c_q);
    	input 			    reset_n, enable1, clock;
        input               erase;
        input               next_p;
		// The location of the image
		input   [7:0]   x;
		input   [6:0]   y;
		// The location of each pixel
        output  [7:0]   x_v;
        output  [6:0]   y_v;
        output  [2:0]   colour;
    	output  [3:0]   c_q;

        // The datapath should be instansiating a RAM file, reading data about the
        // next pixel from it.

        // if (erase) begin
        //     c_v <- 3'b111;
        // end

endmodule
// end Datapath module


// Control module
module control(c_q, go,reset_n,clock,enable,plot,next_p);
        input [3:0] c_q;
		input go,reset_n,clock;
		output reg enable,plot,next_p;

		reg [3:0] current_state, next_state;

		localparam  S_READ_FILE       = 2'd0,
                    S_CYCLE           = 2'd1,
                    S_END_DRAW        = 2'd2;

		always@(*)
        begin: state_table
            case (current_state)
                S_READ_FILE: next_state = (read == 1'b1) ? S_CYCLE : S_READ_FILE;
                S_CYCLE: next_state = (go_s == 1'b1) ? S_END_DRAW : S_CYCLE;
                S_END_DRAW: next_state =  S_READ_FILE;
            default:     next_state = S_READ_FILE;
            endcase
        end

		always@(*)
        begin: enable_signals
        // By default make all our signals 0
        next = 1'b0;
		enable = 1'b0;

		  case(current_state)
				S_READ_FILE:begin
                    // Send signal to datapath to start reading from RAM
					end
				S_CYCLE:begin
                    enable = 1'b1;
                    next = 1'b1;
					end
                S_END_DRAW:begin
                    // Maybe do nothing?
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
