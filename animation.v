module animation(
      CLOCK_50,
      reset,
      load,
      go,
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

  frame	f0(
    .CLOCK_50(CLOCK_50),						//	On Board 50 MHz
    // Your inputs and outputs here
    .reset(reset),
    .load(load),
    .go(go),
    .x_v(8'b10100000),
    .y_v(7'd0),
    // The ports below are for the VGA output.  Do not change.
    .VGA_CLK(VGA_CLK),   						//	VGA Clock
    .VGA_HS(VGA_HS),							//	VGA H_SYNC
    .VGA_VS(VGA_VS),							//	VGA V_SYNC
    .VGA_BLANK_N(VGA_BLANK_N),						//	VGA BLANK
    .VGA_SYNC_N(VGA_SYNC_N),						//	VGA SYNC
    .VGA_R(VGA_R),   						//	VGA Red[9:0]
    .VGA_G(VGA_G),	 						//	VGA Green[9:0]
    .VGA_B(VGA_B)   						//	VGA Blue[9:0]
  );

endmodule

module datapath();

endmodule


module counterx(clock, reset_n, enable, q);
	input 				clock, reset_n, enable;
	output   reg 	[7:0] 	q;

	always @(posedge clock) begin
		if(reset_n == 1'b0)
			q <= 8'd0;
		else if (enable == 1'b1)
			q <= q + 1'b1;
		  if (q == 8'b10100000) begin
			   q <= 8'd0;
		  end
   end
endmodule


module control();

  reg [3:0] current_state, next_state;

  localparam  S_LOAD_FRAME   = 2'd0,
              S_CYCLE        = 2'd2,
              S_END_ANI      = 2'd3;

  always@(*)
    begin: state_table
          case (current_state)
              S_LOAD_FRAME: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X;
              S_CYCLE: next_state = ({&c_q} == 1'b0) ? S_LOAD_X : S_CYCLE_0;
              S_END_ANI: next_state = ;
          default:     next_state = S_LOAD_X;
      endcase
    end

  always@(*)
    begin: enable_signals
      // By default make all our signals 0

    case(current_state)
      S_LOAD_FRAME:begin
        end
      S_CYCLE:begin
        end
      S_END_ANI:begin
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


module slowcounter(enable, clk, reset, go);
  input enable, clk, reset;
  output go;

  wire [5:0] q;
  ratedivider(enable, 6'b111011, clk, reset, q);
  go = (q == 6'd0) ? 1 : 0;

endmodule


module ratedivider(enable, load, clk, reset, q);
	input enable, clk, reset;
	input [5:0] load;
	output reg [5:0] q;

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