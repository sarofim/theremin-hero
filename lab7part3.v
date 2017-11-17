`timescale 1ns / 1ns // `timescale time_unit/time_precision

module lab7part3
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
	input [9:7] SW;
	wire resetn;
	wire writeEn;
	wire startMovement;
	assign startMovement = ~KEY[1];
	assign resetn = KEY[0];


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
			.plot(writeEn | writetoblack),
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
		part3 I1 (.clock(CLOCK_50), .resetn(resetn), .plot(plot), .colour(SW[9:7]), .outX(x), .outY(y), .outColour(colour), .PlotPoints(writeEn));

endmodule

module part3 (
		input clock,
		input resetn,
		input plot,
		input [2:0] colour,
		output [7:0] outX,
		output [6:0]outY,
		output [2:0] outColour,
		output PlotPoints);

		wire LoadBlack, loadXvalue;
		wire [4:0] counter;
		wire square_Done, count_Done, xdir, ydir;
		wire resetClearCounter;
		wire writetoblack;

		directionControl C1(.clk(clock), .resetn(resetn), .squareDone(square_Done), .countDone(count_Done), .xDir(xdir), .yDir(ydir));

		controlinner C0 (startMovement, clock, resetn, countDone, clearScreen, PlotPoints, loadColour, squareCounter, clearCounter, loadPoints, squareDone, resetClearCounter, writetoblack);
		datapath D0 (colour, clock, resetn, PlotPoints, loadColour, loadPoints, squareCounter, clearCounter, xdir, ydir, resetClearCounter, writetoblack, outX, outY, outColour);
endmodule


module controlinner (
		input startMovement,
		input clock,
		input resetn,
		input countDone,
		output reg clearScreen,
		output reg PlotPoints,
		output reg loadColour,
		output reg [4:0] squareCounter,
		output reg [14:0] clearCounter,
		output reg loadPoints,
		output reg squareDone,
		output reg resetClearCounter,
		output reg writetoblack);  //edited # bits

	reg [2:0] currentstate, nextstate;
	reg enableSquareCounter, resetSquareCounter;
	reg enableClearCounter;

	localparam 		
					state_idle = 3'b000,
					state_setColour = 3'b001,
					state_loadBlack = 3'b010,
					state_clearScreen = 3'b011,
					state_loadPoints = 3'b100,
					state_plotSquare = 3'b101;

	always@(*)
		begin: state_table
			case(currentstate)
				state_idle: nextstate = (countDone | startMovement) ? state_setColour : state_idle;
				state_setColour: nextstate = state_clearScreen;
				state_loadBlack: nextstate = state_clearScreen;
				state_clearScreen: nextstate = (clearCounter == (15'd19200)) ? state_loadPoints : state_loadBlack;//edited # bits
				state_loadPoints: nextstate = state_plotSquare;
				state_plotSquare: nextstate = squareCounter == 5'd16 ? state_idle : state_plotSquare;
				default: nextstate = state_idle;
			endcase
		end



	always @(*)
		begin: enable_signals
			loadColour = 1'b0;
			clearScreen = 1'b0;
			enableSquareCounter = 1'b0;
			resetSquareCounter = 1'b0;
			enableClearCounter = 1'b0;
			resetClearCounter = 1'b0;
			PlotPoints = 1'b0;
			loadPoints = 1'b0;
			squareDone = 1'b0;
			writetoblack = 1'b0;

		case (currentstate)
			state_idle: begin
			squareDone = 1'b1;
			end
			state_setColour: begin
				loadColour = 1'b1;
				resetClearCounter = 1'b1;
			end
			state_loadBlack: begin
				clearScreen = 1'b1;
				enableClearCounter = 1'b1;
			end
			state_clearScreen: begin
				writetoblack = 1'b1;
				end
			state_loadPoints: begin
				loadPoints = 1'b1;
				resetSquareCounter = 1'b1;
			end
			state_plotSquare: begin
				enableSquareCounter = 1'b1;
				PlotPoints = 1'b1;
			end
		endcase
	end

		always @ (posedge clock) begin
		if (resetSquareCounter) squareCounter = 5'd0;
		else if (enableSquareCounter) squareCounter = squareCounter + 5'd1;
		end

		always @(posedge clock) begin
			if (resetClearCounter) clearCounter = 15'd0; //edited # bits
			else if (enableClearCounter) clearCounter = clearCounter + 15'd1; //edited # bits

		end
		always @ (posedge clock)
		begin: state_FFs
			if(!resetn)
				currentstate<= state_idle;
			else begin
				currentstate <= nextstate;
				end
		end
endmodule



/*
module directionControl(input clk, resetn, squareDone,
                        output reg countDone, xDir, yDir);
  //5 states: s_downRight, s_downLeft, s_upRight, s_upLeft, s_wait
  //right 0, x left 1, y down 0, y up 1
  //s_downRight 00, s_downLeft 10, s_upRight 01, s_upLeft 11
  reg [2:0] current_state, next_state;
  reg [7:0] xCount;
  reg [6:0] yCount;
  reg [19:0] count60Hz;
  reg [3:0] frameCount;
  wire clock;

  localparam  s_wait = 3'b000,
              s_downRight = 3'b001,
              s_downLeft = 3'b010,
              s_upLeft = 3'b011,
              s_upRight = 3'b100;

	
  always@(*)
    begin: state_table
      case(current_state)
        s_wait: begin
          if(!squareDone) next_state = s_wait;
          else begin
              if (xCount == 8'd0 && yCount == 7'd0) begin
                next_state = s_downRight;
                end

              else if(xDir == 0 && yDir == 0) begin
                  if (yCount == 7'd5) next_state = s_upRight;
                  else next_state = s_downRight;
                end

              else if(xDir == 0 && yDir == 1) begin
                  if (xCount == 8'd7) next_state = s_upLeft;
                  else next_state = s_upLeft;
                end

              else if(xDir == 1 && yDir == 1) begin
                  if(yCount == 7'd0) next_state = s_downLeft;
                  else next_state = s_upLeft;
                end

              else if(xDir == 1 && yDir == 0) begin
                  if(xCount == 8'd0) next_state = s_downRight;
                  else next_state = s_downLeft;

                end
              end
          end
        s_downRight:begin
                    next_state = s_wait;
                    end
        s_downLeft: begin
                    next_state = s_wait;
                    end
        s_upRight: begin
                   next_state = s_wait;
                   end
      endcase
  end

  //enable_signals
  always @(*)
		begin: enable_signals
      countDone = 1'b0;
      xDir = 1'b0;
      yDir = 1'b0;

		case (current_state)
      s_wait: begin
        countDone <= 1'b1;
        end
      s_downRight: begin
        xDir <= 1'b0;
        yDir <= 1'b0;
        end
      s_downLeft: begin
        xDir <= 1'b0;
        yDir <= 1'b1;
        end
      s_upRight: begin
        xDir <= 1'b0;
        yDir <= 1'b1;
        end
      s_upLeft: begin
        xDir <= 1'b1;
        xDir <= 1'b1;
        end
		endcase
	end

  //xposition & ypsosition counter
  // always@(posedge clk) begin
  always@(posedge clock) begin
    if(!resetn) begin
          xCount <= 8'd0;
          yCount <= 7'd0;
          end
    else begin
            if(xDir == 1'b0 && yDir == 1'b0) begin
              xCount <= xCount + 1;
              yCount <= yCount + 1;
            end

            else if(xDir == 1'b0 && yDir == 1'b1) begin
              xCount <= xCount + 1;
              yCount <= yCount - 1;
            end

            else if(xDir == 1'b1 && yDir == 1'b0) begin
              xCount <= xCount - 1;
              yCount <= yCount + 1;
            end

            else if(xDir == 1'b1 && yDir == 1'b1) begin
              xCount <= xCount - 1;
              yCount <= yCount - 1;
            end
         end
  end

  //state_FF
  // always @ (posedge clk)
  always @ (posedge clock)
  begin: state_FFs
    if(!resetn)
      current_state <= s_wait;
    else current_state <= next_state;
  end

  //assign clock counters
  wire count_frame_enable;
  //60Hz counter
  always @(posedge clk) // triggered every time clock rises
    begin
      if (!resetn) // when resetn is 0
        count60Hz <= 0; // q is set to 0
      else if (count60Hz == 20'd0)
        // count60Hz <= 20'd2;
        count60Hz <= 20'b11001011011100110110;
      else // increment q only when Enable is 1
        count60Hz <= count60Hz - 1; // decrement q
  end

  assign count_frame_enable = (count60Hz == 0)? 1:0;
  //frame counter
  always @(posedge clk) // triggered every time clock rises
    begin
      if (!resetn) // when Clear b is 0
        frameCount <= 0; // q is set to 0
      else if (frameCount == 0)
        frameCount <= 4'd15; // q reset to 0
      else if (count_frame_enable) // increment q only when Enable is 1
        frameCount <= frameCount - 1; // increment q
  end

  assign clock = (frameCount == 0)? 1:0;

endmodule

*/
module datapath (
	input [2:0] datain_colour,
	input clock,
	input resetn,
	input clearScreen,
	input PlotPoints,
	input loadColour,
	input loadPoints,
	input [4:0] squareCounter,
	input [14:0] clearCounter, //edited # bits
	input xdir,
	input ydir,
	input resetClearCounter,
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
		reg [14:0] address;

		always@(posedge clock) begin
			if (!resetn) begin
				regX <= 8'b0;
				regY <= 7'b0;
				regColour <= 2'b0;
			end
			else begin
				if (loadColour) begin
					regColour <= datain_colour;
				end
				if (loadPoints) begin
					if ((xdir == 1'b0) && (ydir == 1'b0)) begin
					regX <= regX + 8'd1;
					regY <= regY + 7'd1;
					end
					if ((xdir == 1'b1) && (ydir == 1'b1)) begin
					regX <= regX - 8'd1;
					regY <= regY - 7'd1;
					end
					if ((xdir == 1'b0) && (ydir == 1'b1)) begin
					regX <= regX + 8'd1;
					regY <= regY - 7'd1;
					end
					if ((xdir == 1'b1) && (ydir == 1'b0)) begin
					regX <= regX - 8'd1;
					regY <= regY + 7'd1;
					end
				end
			end
		end

		always @ (posedge clock) begin
			if (resetClearCounter | !resetn | clearCounter == 15'd19600) begin
				address <= 15'd0;
			end
			else if (clearScreen) begin
				address <= address + 1'b1;
			end
		end	
/*		always @(posedge clock) begin
			if(clearCounter != 15'd19200) begin//edited # bits
				if (clearX == 8'd160) begin //edited # bits
					clearX <= 8'd0; //edited # bits
					clearY <= clearY + 7'd1; //edited # bits
					end
				else begin
					clearX <= clearX + 8'd1; //edit # bits
				end
			end
		end
*/
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
				if (PlotPoints)
					begin
						x <= regX + xinc;
						y <= regY + yinc;
						colour <= regColour;
					end
				else if (clearScreen) begin
					x <= address[7:0];
					y <= address[14:8];
					colour <= 3'b000;
				end
			end
		end

endmodule


module directionControl(input clk, resetn, squareDone,
                        output reg countDone, xDir, yDir);
  //5 states: s_downRight, s_downLeft, s_upRight, s_upLeft, s_wait
  //right 0, x left 1, y down 0, y up 1
  //s_downRight 00, s_downLeft 10, s_upRight 01, s_upLeft 11
  reg [2:0] current_state, next_state;
  reg [7:0] xCount;
  reg [6:0] yCount;
  reg [19:0] count60Hz;
  reg [3:0] frameCount;
  wire clock;
  reg enableCount;

  localparam  s_wait = 3'b000,
              s_downRight = 3'b001,
              s_downLeft = 3'b010,
              s_upLeft = 3'b011,
              s_upRight = 3'b100;

  always@(*)
    begin: state_table
      case(current_state)
        s_wait: begin
          if(!squareDone) next_state = s_wait;
          else begin
              if (xCount == 8'd0 && yCount == 7'd0) begin
                next_state = s_downRight;
                end
              else if(xDir == 0 && yDir == 0) begin
                  if (yCount == 7'd5) next_state = s_upRight;
                  else next_state = s_downRight;
                end
              else if(xDir == 0 && yDir == 1) begin
                  if (xCount == 8'd7) next_state = s_upLeft;
                  else next_state = s_upRight;
                end
              else if(xDir == 1 && yDir == 1) begin
                  if(yCount == 7'd0) next_state = s_downLeft;
                  else next_state = s_upLeft;
                end
              else if(xDir == 1 && yDir == 0) begin
                  if(xCount == 8'd0) next_state = s_downRight;
                  else next_state = s_downLeft;
                end
              end
          end
        s_downRight:begin
                    next_state = s_wait;
                    end
        s_downLeft: begin
                    next_state = s_wait;
                    end
        s_upRight: begin
                   next_state = s_wait;
                   end
        default : next_state = s_downRight;
      endcase
  end

  //enable_signals
  always @(*)
		begin: enable_signals
      countDone = 1'b0;
      enableCount = 1'b0;

		case (current_state)
      s_wait: begin
        countDone <= 1'b1;
        end
      s_downRight: begin
        enableCount = 1'b1;
        xDir <= 1'b0;
        yDir <= 1'b0;
        end
      s_downLeft: begin
        enableCount = 1'b1;
        xDir <= 1'b1;
        yDir <= 1'b0;
        end
      s_upRight: begin
        enableCount = 1'b1;
        xDir <= 1'b0;
        yDir <= 1'b1;
        end
      s_upLeft: begin
        enableCount = 1'b1;
        xDir <= 1'b1;
        xDir <= 1'b1;
        end
		endcase
	end

  //xposition & ypsosition counter
  // always@(posedge clk) begin
  always@(posedge clock) begin
    if(!resetn) begin
          xCount <= 8'd0;
          yCount <= 7'd0;
          end
    else if(enableCount) begin
            if(xDir == 1'b0 && yDir == 1'b0) begin
              xCount <= xCount + 1;
              yCount <= yCount + 1;
            end

            else if(xDir == 1'b0 && yDir == 1'b1) begin
              xCount <= xCount + 1;
              yCount <= yCount - 1;
            end

            else if(xDir == 1'b1 && yDir == 1'b0) begin
              xCount <= xCount - 1;
              yCount <= yCount + 1;
            end

            else if(xDir == 1'b1 && yDir == 1'b1) begin
              xCount <= xCount - 1;
              yCount <= yCount - 1;
            end
         end
  end

  //state_FF
  // always @ (posedge clk)
  always @ (posedge clock)
  begin: state_FFs
    if(!resetn) begin
      current_state <= s_wait;
      end
    else current_state <= next_state;
  end

  //assign clock counters
  wire count_frame_enable;
  //60Hz counter
  always @(posedge clk) // triggered every time clock rises
    begin
      if (!resetn) // when resetn is 0
        count60Hz <= 0; // q is set to 0
      else if (count60Hz == 20'd0)
        // count60Hz <= 20'd2;
        count60Hz <= 20'd2;
      else // increment q only when Enable is 1
        count60Hz <= count60Hz - 1; // decrement q
  end

  assign count_frame_enable = (count60Hz == 0)? 1:0;
  //frame counter
  always @(posedge clk) // triggered every time clock rises
    begin
      if (!resetn) // when Clear b is 0
        frameCount <= 0; // q is set to 0
      else if (frameCount == 0)
        frameCount <= 4'd3; // q reset to 0
      else if (count_frame_enable) // increment q only when Enable is 1
        frameCount <= frameCount - 1; // increment q
  end

  assign clock = (frameCount == 0)? 1:0;

endmodule

