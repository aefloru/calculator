`timescale 10 ns/ 1 ns


module tb();
// constants                                           
// general purpose registers
//reg CLOCK_50;
reg clk;
wire [9:0] LEDR;
wire [6:0] HEX0;
wire [6:0] HEX1;
wire [6:0] HEX2;
wire [6:0] HEX3;
wire [6:0] HEX4;
wire [6:0] HEX5;
wire [3:0] pc;
reg [10:0] inst_w;
reg [2:0] overflow;
//wire [11:0] BCD;

//myrom myrom(.clock(CLOCK_50), .q(inst_w), .address(pc));

// assign statements (if any)                          
calculator calc(
// port map - connection between master ports and signals/registers   
	.CLOCK_50(clk),
	.inst_w(inst_w),
	.pc(pc),
	.overflow(overflow),
//	.BCD(BCD),
	.HEX0(HEX0),
	.HEX1(HEX1),
	.HEX2(HEX2),
	.HEX3(HEX3),
	.HEX4(HEX4),
	.HEX5(HEX5),
	.LEDR(LEDR)
	
);

//output reg signed [7:0] out_stack,

always @*
	#1 clk <= ~clk;
	
initial
begin

$monitor("%d %d %b", $realtime, clk, pc, LEDR, HEX0, HEX1, HEX2, HEX3);
clk = 0;




#20 $finish;

end 


endmodule

