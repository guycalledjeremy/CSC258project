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
    // input           resetn;
    // input           go;
    // input           erase;
	input	[7:0]	x;
	input	[5:0] 	y;
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

	reg [7:0] x;
	reg [5:0] y;

	// Create the writeEn wires that are inputs to the controller.
    wire reset = resetn;
	wire writeEn;
    wire [7:0]     x_v;
    wire [5:0]     y_v;
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
    wire go_sw;

    // Instansiate datapath
	// datapath d0(...);
      datapath d0(CLOCK_50,reset,enable,erase,next, x, y, c_v, x_v, y_v, go_sw);

    // Instansiate FSM control
    // control c0(...);
	  control c0(go,go_sw,reset,CLOCK_50,erase,enable,writeEn,next);
endmodule
// end main module


// Datapath module
module datapath(clock, reset_n, enable1, erase, next_p, x, y, colour, x_v, y_v, go_s);
    	input 			    reset_n, enable1, clock;
        input               erase;
        input               next_p;
		// The location of the image
		input   [7:0]   x;
		input   [5:0]   y;
		// The location of each pixel
        output	reg  [7:0]   x_v;
        output	reg  [5:0]   y_v;
        output	reg  [2:0]  colour;
        output reg go_s;

        // The datapath should be instansiating a RAM file, reading data about the
        // next pixel from it.

		reg e;
        // wire [7:0] xv;
        // wire [5:0] xv;
        // wire [2:0] cv;
        // getlocation g0(enable1, clock, reset_n, x, y, x_v, y_v, c_v);

		reg [2:0] x_i;
		reg [2:0] y_i;
		reg nextp;

		wire [7:0] xv;
		wire [5:0] yv;
		wire [2:0] cv;
		wire [15:0] out;
		wire [9:0] addr_read;

		topramsprite snow(clock, addr_read, out);
		drawsnowman d0(clock, addr_read);
		translateout t0(clock, out, x, y, xv, yv, cv, {enable1 | nextp});

	    always @(posedge clock) begin
		if (enable1) begin
	        if (!reset_n) begin
				x_i <= 3'd0;
				y_i <= 3'd0;
	            x_v <= x;
	            y_v <= y;
				go_s <= 1'b0;
				colour <= 3'd0;
				e <= 1'b0;
				nextp <= 1'b0;
	        end
	        else begin
			    if (e) begin
					colour <= 3'd0;
			    end
			    else begin
					colour <= cv;
			    end
				if (erase) begin
					e <= 1'b1;
					colour <= 3'd0;
				end
				if (next_p) begin
					nextp <= 1'b1;
				end
                if (x_i == 5'd20) begin
					x_i <= 5'd0;
                    x_v <= x;
					y_i <= y_i + 1;
                    y_v <= y_v;
		            if (y_i == 6'd41) begin
						y_i <= 6'd0;
		                y_v <= y;
						go_s <= 1'b1;
						e <= 1'b0;
						nextp <= 1'b0;
		            end
                end
                else begin
					x_i <= x_i + 1;
                    x_v <= xv;
                end
	        end
		end
    end
        // assign x_v = xv;
        // assign y_v = yv;
        // assign colour = cv;

endmodule
// end Datapath module


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


// Control module
module control(read, go_s,reset_n,clock,erase,enable,plot,next_p);
		input read,go_s,reset_n,clock,erase;
		output reg enable,plot,next_p;

		reg [3:0] current_state, next_state;

		localparam  S_READ_FILE       = 2'd0,
                    S_CYCLE           = 2'd1,
                    S_END_DRAW        = 2'd2;

		always@(*)
        begin: state_table
            case (current_state)
                S_READ_FILE: next_state = (read || erase == 1'b1) ? S_CYCLE : S_READ_FILE;
                S_CYCLE: next_state = (go_s == 1'b1) ? S_END_DRAW : S_CYCLE;
                S_END_DRAW: next_state =  S_READ_FILE;
            default:     next_state = S_READ_FILE;
            endcase
        end

		always@(*)
        begin: enable_signals
        // By default make all our signals 0
          next_p = 1'b0;
		  enable = 1'b0;
		  plot = 1'b0;

		  case(current_state)
				S_READ_FILE:begin
                    // Send signal to datapath to start reading from RAM
					end
				S_CYCLE:begin
                    enable = 1'b1;
					plot = 1'b1;
                    next_p = 1'b1;
					end
                S_END_DRAW:begin
                    // Maybe do nothing?
					//plot = 1'b1;
                    end
		  endcase
		end


		always@(posedge clock)
      	begin: state_FFs
        if(!reset_n)
            current_state <= S_READ_FILE;
        else
            current_state <= next_state;
      end
endmodule
// end Control module
