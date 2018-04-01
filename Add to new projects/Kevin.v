// can directly put the BlackSnowman into the toplevel
module Kevin(clock, x_coord, y_coord, x, y, colour, writeEn);
	input clock;
	input [7:0] x_coord;
	input [6:0] y_coord;
	output [7:0] x;
	output [6:0] y;
	output [2:0] colour;
	output writeEn;
	
	wire [9:0] addr_read;
	wire [15:0] out;

	Kevin_topramsprite kev(clock, addr_read, out);
	drawKevin d0(clock, addr_read);
	translateout t0(clock, out, x_coord, y_coord, x, y, colour, writeEn_out);

endmodule

module Kevin_topramsprite(clk, addr_read, out);

	input clk; //should be CLOCK_50
	input [9:0] addr_read;
	output [15:0] out;
	
	wire wren;
	wire [15:0] value;
	reg [9:0] address;
	reg [9:0] addr_write;
	
	Kevin_RAM_IN snow0(out, addr_read, wren);
	
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

module Kevin_RAM_IN (pix_val, indx, wren);

input [9:0] indx;
output [15:0] pix_val;
output reg wren;

reg [15:0] pix_val;
reg [15:0] in_ram [219:0];

always @ (indx) begin
  pix_val = in_ram [indx];
  wren = pix_val[0];
end

initial
begin
  $readmemb("Kevin.txt", in_ram);
end

endmodule

module drawKevin(clock, addr_read);
	input clock;
	output reg [9:0] addr_read;
	initial addr_read = 10'b0;
	always @ (posedge clock) begin
		if (addr_read < 10'd220) begin
			addr_read <= addr_read + 1'b1;
		end
		else begin
			addr_read <= 10'b0;
		end
	end
endmodule
