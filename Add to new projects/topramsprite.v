//`include "ramsprite.v"

module topramsprite(clk, addr_read, out);

	input clk; //should be CLOCK_50
	input [9:0] addr_read;
	output [15:0] out;
	
	wire wren;
	wire [15:0] value;
	reg [9:0] address;
	reg [9:0] addr_write;
	
	RAM_IN snow0(out, addr_read, wren);
	
	initial begin
		addr_write <= 10'b0;
	end
	
	always @(posedge clk) begin
		if (wren == 1'b1) begin
			addr_write <= addr_write + 1;
			address <= addr_write;
		end
		else if (wren == 1'b0) begin
			address <= addr_read;
		end
	end

endmodule

module RAM_IN (pix_val, indx, wren);

input [9:0] indx;
output [15:0] pix_val;
output reg wren;

reg [15:0] pix_val;
reg [15:0] in_ram [839:0];

always @ (indx) begin
  pix_val = in_ram [indx];
  wren = pix_val[0];
end

initial
begin
  $readmemb("EvilSnowman.txt", in_ram);
end

endmodule
