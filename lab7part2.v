// Part 2 skeleton
`timescale 1ns / 1ns // `timescale time_unit/time_precision

module lab7part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		SW,
		KEY,
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

	input			CLOCK_50;				//	50 MHz
	// Declare your inputs and outputs here
	input [3:0]KEY;
	input [9:0] SW;
	wire resetn;
	wire loadX;
	wire writeEn;
	wire plot;
	assign plot = ~KEY[1];
	assign resetn = KEY[0];
	assign loadX = ~KEY[3];
	assign clear = ~KEY[2];
	
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
	wire [7:0] x;
	wire [6:0] y;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			// Signals for the DAC to drive the monitor.
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
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
		part2 I1 (CLOCK_50, resetn, plot, loadX, clear, SW[6:0], SW[9:7], x, y, colour, writeEn); 
	
endmodule
/*

 module lab7part2 (
	input [9:0]SW,
	input [3:0]KEY,
	input CLOCK_50,
	output [7:0] outX,
	output [6:0] outY,
	output [2:0]outColour,
	output PlotPoints
	);
	
	wire resetn;
	wire plot;
	wire loadX;
	assign plot = KEY[1];
	assign resetn = ~KEY[0];
	assign loadX = KEY[3];
	assign clear = KEY[2];
	
	part2 I1 (CLOCK_50, resetn, plot, loadX, clear, SW[6:0], SW[9:7], outX, outY, outColour, PlotPoints); 
	
	endmodule
	*/
	
module part2 (
		input clock,
		input resetn,
		input plot,
		input loadX,
		input clear,
		input [6:0] coordinates,
		input [2:0] colour,
		output [7:0] outX,
		output [6:0]outY,
		output [2:0] outColour,
		output PlotPoints
		);
		
		wire LoadBlack, loadXvalue;
		wire [4:0] squareCounter;
		wire [13:0] clearCounter;
		
		control C0 (clock, resetn, plot, loadX, clear, loadXvalue, loadY, loadColour, PlotPoints, loadBlack, squareCounter, clearCounter);
		datapath D0 (coordinates, colour, clock, resetn, PlotPoints, loadXvalue, loadY, loadColour, loadBlack, squareCounter, clearCounter, outX, outY, outColour);		
endmodule


module control (input clock, input resetn, input plot, input inputloadX, input clear, output reg loadX, output reg loadY, output reg loadColour, output reg PlotPoints, output reg loadBlack, output reg [4:0]squareCounter, output reg [13:0] clearCounter);
	reg [2:0] currentstate, nextstate;
	reg enableSquareCounter, resetSquareCounter;
	reg enableClearCounter, resetClearCounter;
//	reg [4:0]squareCounter;
//	reg [14:0]clearCounter;
	
	localparam 	state_loadX = 3'b000,
					state_loadX_wait = 3'b001,
					state_loadY = 3'b010,
					state_loadY_wait = 3'b011,
					state_loadColour = 3'b100,
					state_plot = 3'b101,
					state_loadBlack = 3'b110;
					
	always@(*)
		begin: state_table
			case(currentstate)
				state_loadX: begin
					if (clear) nextstate = state_loadBlack;
					else begin
						if (inputloadX) nextstate = state_loadX_wait;
						if (!inputloadX) nextstate = state_loadX;
					end
				end
				state_loadX_wait: nextstate = inputloadX ? state_loadX_wait : state_loadY;
				state_loadY: nextstate = plot ? state_loadY_wait : state_loadY;
				state_loadY_wait: nextstate = plot ? state_loadY_wait : state_loadColour;
				state_loadColour: nextstate = state_plot;
				state_plot: nextstate = squareCounter == 5'd16 ? state_loadX : state_plot;
				state_loadBlack: nextstate = clearCounter == 14'd15600  ? state_loadX : state_loadBlack;
				default: nextstate = state_loadX;
			endcase
		end
	
	always @(*)
		begin: enable_signals
			loadX = 1'b0;
			loadY = 1'b0;
			loadColour = 1'b0;
			loadBlack = 1'b0;
			enableSquareCounter = 0;
			resetSquareCounter = 0;
			enableClearCounter = 0;
			resetClearCounter = 1;
			PlotPoints = 1'b0;
			
		case (currentstate)
			state_loadX: begin
				loadX = 1'b1;
				resetSquareCounter = 1'b1;
				end
				state_loadX_wait: begin
				loadX = 1'b1;
				end
			state_loadY: begin
				loadY = 1'b1;
				end
				state_loadY_wait: begin
				loadX = 1'b1;
				end
			state_loadColour: begin
				loadColour = 1'b1;
				end
			state_plot: begin
				PlotPoints = 1'b1;
				enableSquareCounter = 1'b1;
				end
			state_loadBlack: begin
				loadBlack = 1'b1;
				resetClearCounter = 1'b0;
				enableClearCounter = 1'b1;
				end
		endcase
		end
		
		always @ (posedge clock) begin
		if (resetSquareCounter) squareCounter = 5'd0;
		else if (enableSquareCounter) squareCounter = squareCounter + 5'd1;
		end
		
		always @ (posedge clock) begin
		if (resetClearCounter) clearCounter = 14'd0;
		else if (enableClearCounter) clearCounter = clearCounter + 14'd1;
		end

		always @ (posedge clock)
		begin: state_FFs
			if(!resetn) 
				currentstate <= state_loadX;
			else begin
				currentstate <= nextstate;
				end
		end
endmodule


module datapath (
	input [6:0]datain_coord,
	input [2:0] datain_colour,
	input clock,
	input resetn,
	input plot,
	input loadX,
	input loadY,
	input loadColour,
	input loadBlack,
	input [4:0] squareCounter,
	input [13:0] clearCounter,
	output reg [7:0]x,
	output reg [6:0]y,
	output reg [2:0]colour
	);

	
		reg [7:0] regX;
		reg [6:0] regY;
		reg [2:0] regColour;
		reg [7:0] xinc;
		reg [6:0] yinc;
		reg [7:0] clearX;
		reg [6:0] clearY;	
		
		always @(posedge clock) begin
			if (!resetn) begin
			clearX <= 8'b0;
			clearY <= 7'b0;
			end
			else begin
				if(clearCounter != 14'd15600) begin//edited # bits
					if (clearX == 8'd130) begin//edited # bits
						clearX <= 8'd0; //edited # bits
						clearY <= clearY + 7'd1; //edited # bits
					end
					else clearX <= clearX + 8'd1; //edit # bits	
				end
			end
		end


		always@(posedge clock) begin
			if (!resetn) begin
				regX <= 8'b0;
				regY <= 7'b0;
				regColour <= 2'b0;
			end
			else begin
				if (loadX)
					regX <= {1'b0, datain_coord};
				if (loadY)
					regY <= datain_coord;
				if (loadColour)
					regColour = datain_colour;
			end
		end
		
		always @(*) begin
			case (squareCounter)
				4'd0: begin
					xinc = 8'd0;
					yinc = 7'd0;
					end
				4'd1: begin
					xinc = 8'd1;
					yinc = 7'd0;
					end
				4'd2: begin
					xinc = 8'd2;
					yinc = 7'd0;
					end
				4'd3: begin
					xinc = 8'd3;
					yinc = 7'd0;
					end
				4'd4: begin
					xinc = 8'd0;
					yinc = 7'd1;
					end
				4'd5: begin
					xinc = 8'd1;
					yinc = 7'd1;
					end
				4'd6: begin
					xinc = 8'd2;
					yinc = 7'd1;
					end
				4'd7: begin
					xinc = 8'd3;
					yinc = 7'd1;
					end
				4'd8: begin
					xinc = 8'd0;
					yinc = 7'd2;
					end
				4'd9: begin
					xinc = 8'd1;
					yinc = 7'd2;
					end
				4'd10: begin
					xinc = 8'd2;
					yinc = 7'd2;
					end
				4'd11: begin
					xinc = 8'd3;
					yinc = 7'd2;
					end
				4'd12: begin
					xinc = 8'd0;
					yinc = 7'd3;
					end
				4'd13: begin
					xinc = 8'd1;
					yinc = 7'd3;
					end
				4'd14: begin
					xinc = 8'd2;
					yinc = 7'd3;
					end
				4'd15: begin
					xinc = 8'd3;
					yinc = 7'd3;
					end	
			endcase
		end
			
	
		always @(posedge clock) begin
			if (!resetn) begin
				x <= 8'b0;
				y <= 7'b0;
				colour <= 2'b0;
				end	
			else begin
				if (plot) 
					begin					
						x <= regX + xinc;
						y <= regY + yinc;
						colour <= regColour;
					end
				if (loadBlack) begin
						x <= clearX;
						y <= clearY;
						colour <= 3'b000;
				end
				end
	end		
		
endmodule