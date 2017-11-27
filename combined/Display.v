module Display
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		SW,
		KEY,
		GPIO_0,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B ,  						//	VGA Blue[9:0]
		HEX1,
		HEX0
	);

	input			CLOCK_50;				//	50 MHz
	// Declare your inputs and outputs here
	input [3:0]KEY;
	input [9:0] SW;
	input [35:0] GPIO_0;
	wire reset;
	wire writeToScreen, writeDefault;
	wire start;
	assign start = ~KEY[1];
	assign reset = ~KEY[0];

	output [6:0]HEX0;
	output [6:0]HEX1;

	
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [8:0] x;
	wire [7:0] y;
	wire note1, note2, note3;

	assign note1 = ~GPIO_0[32];
	assign note2 = ~GPIO_0[31];
	assign note3 = ~GPIO_0[30];


	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(~reset),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeToScreen | writeDefault),
			// Signals for the DAC to drive the monitor.
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "bg-320x240.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
		CombinedShit I1 (CLOCK_50, reset, start, note1, note2, note3, x, y, colour, writeToScreen, writeDefault); 
	
endmodule

module CombinedShit (clock, reset, start, note1, note2, note3, vgaOutX, vgaOutY, vgaOutColour, writeToScreen, writeDefault);

input clock, reset, start, note1, note2, note3;
output [7:0] vgaOutY;
output [8:0] vgaOutX;
output [2:0] vgaOutColour;
output writeToScreen, writeDefault;

wire loadDefault, loadX, loadY, loadStartAddress, shiftSong, songDone, changeScore, addScore;

	wire [15:0] gridCounter, memAddressGridCounter;
wire [3:0] boxCounter;
	wire [14:0] pixelCount, memAddressPixelCount;
//wire [3:0] songCounter;
wire [7:0] songCounter;
wire [7:0] score;
wire[7:0] scoreFinal;
FSM B1 (clock, reset, start, loadDefault, writeDefault, loadX, loadY, 
	writeToScreen, loadStartAddress, shiftSong, gridCounter, memAddressGridCounter, boxCounter, songCounter, pixelCount, memAddressPixelCount, songDone, changeScore, addScore);
	
	
dataPath B2 (clock, reset, shiftSong, writeToScreen, loadStartAddress, loadX, loadY, loadDefault, writeDefault, songDone,
	gridCounter, memAddressGridCounter, boxCounter, pixelCount, memAddressPixelCount, changeScore, addScore, note1, note2, note3, vgaOutX, vgaOutY, vgaOutColour, score);

assign scoreFinal = (score / 8'd107) * 8'd100;

hex H1 (scoreFinal[7:4], HEX1);
hex H2 (scoreFinal[3:0], HEX0);

endmodule


module hex(input [3:0]c, output [6:0]seg);
  
	assign seg[0] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & ~c[1] & ~c[0]) | (c[3] & ~c[2] & c[1] & c[0]) | (c[3] & c[2] & ~c[1] & c[0]);
	assign seg[1] = (~c[3] & c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & c[1] & ~c[0]) | (c[3] & ~c[2] & c[1] & c[0]) | (c[3] & c[2] & ~c[1] & ~c[0]) | (c[3] & c[2] & c[1] & ~c[0]) | (c[3] & c[2] & c[1] & c[0]);
	assign seg[2] = (~c[3] & ~c[2] & c[1] & ~c[0]) | (c[3] & c[2] & ~c[1] & ~c[0]) | (c[3] & c[2] & c[1] & ~c[0]) | (c[3] & c[2] & c[1] & c[0]);
	assign seg[3] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & ~c[1] & ~c[0]) | (~c[3] & c[2] & c[1] & c[0]) | (c[3] & ~c[2] & c[1] & ~c[0]) | (c[3] & c[2] & c[1] & c[0]);
	assign seg[4] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & ~c[2] & c[1] & c[0]) | (~c[3] & c[2] & ~c[1] & ~c[0]) | (~c[3] & c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & c[1] & c[0]) | (c[3] & ~c[2] & ~c[1] & c[0]);
	assign seg[5] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & ~c[2] & c[1] & ~c[0]) | (~c[3] & ~c[2] & c[1] & c[0]) | (~c[3] & c[2] & c[1] & c[0]) | (c[3] & c[2] & ~c[1] & c[0]);
	assign seg[6] = (~c[3] & ~c[2] & ~c[1] & ~c[0]) | (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & c[1] & c[0]) | (c[3] & c[2] & ~c[1] & ~c[0]);
endmodule
