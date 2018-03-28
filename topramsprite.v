//`include "ramsprite.v"

module topramsprite(clk, addr_read, out);

	input clk; //should be CLOCK_50
	input [9:0] addr_read;
	output [15:0] out;
	
	wire wren;
	wire [15:0] value;
	reg [9:0] address;
	reg [9:0] addr_write;
	
//	readSnowman snow0(clk, addr_write, value, wren);
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



//module readSnowman(clk, address, value, wren);
//
//	input clk;
//	
//	output reg [15:0] value;
//	output reg [9:0] address;
//	output reg wren;
//
//	integer               data_file    ; // file handler
//	integer               scan_file    ; // file handler
//
//	reg [2:0] color_val;
//	reg [5:0] x_val;
//	reg [5:0] y_val;
//	reg stop_val;
//	
//	reg [2:0] color;
//	`define NULL 0    
//	
//
//
//initial begin
//  data_file = $fopen("EvilSnowman.txt", "r");
//  address <= 10'b1111111111;
//  stop_val <= 1'b1;
//  x_val <= 6'b111111;
//  y_val <= 6'b000000;
//  wren <= 1'b0;
//  if (data_file == `NULL) begin
//    $display("data_file handle was NULL");
//    $finish;
//  end
//end
//
//always @(posedge clk) begin
//  scan_file = $fscanf(data_file, "%b\n", color); 
//  if (!$feof(data_file)) begin
//    //use captured_data as you would any other wire or reg value;
//	 color_val <= color;
//	 x_val <= x_val + 1'b1;
//	 address <= address + 1'b1;
//	 if (x_val == 6'd20) begin
//		x_val <= 6'b0;
//		y_val <= y_val + 1'b1;
//	 end
//	 if ((x_val == 6'd19) && (y_val == 6'd39)) begin
//		stop_val <= 1'b0;
//	 end
//	 wren <= 1'b1;
//	 value <= {x_val[5:0],y_val[5:0],color_val[2:0],stop_val};
//  end
//  else begin
//	wren <= 1'b0;
//  end
//end
//
//endmodule

module RAM_IN (pix_val, indx, wren);

input [9:0] indx;
output [15:0] pix_val;
output reg wren;

reg [15:0] pix_val;
reg [15:0] in_ram [799:0];

always @ (indx) begin
  pix_val = in_ram [indx];
  wren = pix_val[0];
end

initial
begin
  $readmemb("EvilSnowman.txt", in_ram);
end

endmodule

//module tb;
//reg [0:5] indx; 
//wire [2:0] pix_val;
//
//RAM_IN ram_in(pix_val, indx);
//
//initial
//begin
//  indx = 'b0;
//  $monitor ($realtime, " Read Data = %0b" ,pix_val);
//  repeat(4)
//  begin
//    #10;
//    indx = indx + 1'd1;
//  end
//  $finish;
//end
//endmodule

