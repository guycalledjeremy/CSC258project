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


// Datapath module in frame.v


// end Datapath module in frame.v
