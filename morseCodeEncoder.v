`timescale 1ns / 1ns // `timescale time_unit/time_precision

//if reset = 1, everything resets
//if KEY0 = 0 (pressed down), Parallel load should be 1 - everything loads
module morseCodeEncoder(input [9:0]SW, input CLOCK_50, input [1:0]KEY, output [9:0]LEDR);
	wire [10:0]code, Shiftout;
	wire [27:0] Rate, Q;
	wire countDownDone;

	assign Rate = 28'b01011111010111100000111111;
	mux8to1 B0 (SW[2:0], code[10:0]);
	RateDivider B1 (CLOCK_50, countDownDone, Rate, SW[9], Q);
	assign countDownDone = (28'b0000000000000000000000000000 == Q) ? 1 : 0;

	shiftregister11bits B2 (KEY[0], countDownDone, code[10:0], SW[9], Shiftout[10:0], LEDR[0]);


endmodule

module RateDivider(input clock, input ParallelLoad, input [27:0]D, input resetn, output reg [27:0]Q);
	always @ (posedge clock)
	begin
		if (ParallelLoad == 1'b1)
			Q <= D;
	    else if (resetn)
	       Q <= D;
		else
			Q <= Q-1;
	end
endmodule

module mux8to1 (input [2:0] Function, output reg [10:0]code);
	always @(*)
	begin
		case(Function)
			0: code = 11'b10111000000; //A
			1: code = 11'b11101010100; //B
			2: code = 11'b11101011101; //C
			3: code = 11'b11101010000; //D
			4: code = 11'b10000000000; //E
			5: code = 11'b10101110100; //F
			6: code = 11'b11101110100; //G
			7: code = 11'b10101010000; //H
			default: code = 11'b00000000000; //whatever
		endcase
	end
endmodule



module shiftregister11bits (input ParallelLoadn, input clock, input [10:0]DATA_IN, input Reset_b, output reg [10:0]Q, output reg Out);
	always @(posedge clock, negedge ParallelLoadn)
	begin
		if (ParallelLoadn == 0)
			Q <= DATA_IN;
		else if(Reset_b == 1'b1)
			Q <= 11'b00000000000;

		else
			begin
				Out <= Q[10];
				Q <= Q << 1'b1;
			end
	end
endmodule


module ShiftRegSubCircuit (input leftLoad, input Datain, input loadn, input clock, input reset, output Q);
	wire dataToDff;
	mux2to1 M1 (leftLoad, Datain, loadn, DataToDff);
	Dflipflop D0 (DataToDff, clock, reset, Q);
endmodule

module Dflipflop (input d, input Clock, input Reset_b, output reg q);
	always @(posedge Clock)
	begin
		if (Reset_b == 1'b1)
			q <= 0;
		else
			q <= d;
	end

endmodule

module mux2to1(x, y, s, m);
    input x; //select 0
    input y; //select 1
    input s; //select signal
    output m; //output

    assign m = (~s & x) | (s & y);

endmodule
