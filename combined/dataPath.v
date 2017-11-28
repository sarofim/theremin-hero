module dataPath(input clock, reset, shiftSong, writeToScreen, loadStartAddress, loadX, loadY, loadDefault, writeDefault, songDone,
		input [15:0] gridCounter, memAddressGridCounter, input /*[1:0]*/ [3:0] boxCounter, input [14:0] pixelCount, input [14:0] memAddressPixelCount, input changeScore, addScore, note1, note2, note3,
                output reg [8:0] vgaOutX, output reg [7:0] vgaOutY, output reg [2:0] vgaOutColour, output reg[7:0] score, output [6:0]HEX0);

  //Resolution  = 320 * 240; 76800 = 17b'10010110000000000 (17bits)
  //writing to 240*180 grid; 43200 = 15b'1010,1000,1100,0000 (16bits)
//  reg [14:0] regAddress;
  reg [8:0] regX;
  reg [7:0] regY;
  reg [2:0] regColour;
  reg [16:0] wireAddressOut;
  reg [16:0] currentAddress;
  reg [3:0]finalScore;


  reg [9:0] scoreCounterDummy;
  reg [7:0] scoreCounter;
  //3 shit register
  //reg [7:0] regNote1, regNote2, regNote3;
  reg [114:0] regNote1, regNote2, regNote3;
  reg currentBox1, currentBox2, currentBox3, currentBox4, currentBox5, currentBox6, currentBox7, currentBox8,
      currentBox9, currentBox10, currentBox11, currentBox12;
  always@(posedge clock) begin
    if(reset || songDone || writeDefault) begin
		regNote1 <= 115'b0000000000000000000000001111111100000000000000000000000000000000000000001111111100000000000000000000000011111111000;
		regNote2 <= 115'b0000000000000000111111110000000010101010000000000000000000000000111111110000000000000000000000001111111100000000000;
		regNote3 <= 115'b1111111111111111000000000000000000000000101010101111111111111111000000000000000011111111111111110000000000000000000;
		end
    else if(shiftSong) begin
      //set rightmost node as current note
      currentBox1 <= regNote1[3];
      currentBox2 <= regNote1[2];
      currentBox3 <= regNote1[1];
      currentBox4 <= regNote1[0];
      currentBox5 <= regNote2[3];
      currentBox6 <= regNote2[2];
      currentBox7 <= regNote2[1];
      currentBox8 <= regNote2[0];
      currentBox9 <= regNote3[3];
      currentBox10 <= regNote3[2];
      currentBox11 <= regNote3[1];
      currentBox12 <= regNote3[0];
      //shift all registers right
      regNote1 <= regNote1 >> 1'b1;
      regNote2 <= regNote2 >> 1'b1;
      regNote3 <= regNote3 >> 1'b1;
      end
  end

  reg colourSelect;
  //noteSelect mux - loads start address for each box
  always@(posedge clock) begin
    case(boxCounter)
      1: begin
         colourSelect <= currentBox1;
         wireAddressOut <= 17'b00000000000000000;
         end
      2: begin
         colourSelect <= currentBox2;
         wireAddressOut <= 17'b00011110000000000;
			   end
      3: begin
         colourSelect <= currentBox3;
         wireAddressOut <= 17'b00111100000000000;
         end
      4: begin
         colourSelect <= currentBox4;
         wireAddressOut <= 17'b01011010000000000;
         end
      5: begin
         colourSelect <= currentBox5;
         wireAddressOut <= 17'b00000000000111100;
         end
      6: begin
         colourSelect <= currentBox6;
         wireAddressOut <= 17'b00011110000111100;
        end
      7: begin
         colourSelect <= currentBox7;
         wireAddressOut <= 17'b00111100000111100;
         end
      8: begin
         colourSelect <= currentBox8;
         wireAddressOut <= 17'b01011010000111100;
         end
      9: begin
         colourSelect <= currentBox9;
         wireAddressOut <= 17'b00000000001111000;
         end
      10: begin
         colourSelect <= currentBox10;
         wireAddressOut <= 17'b00011110001111000;
        end
      11: begin
         colourSelect <= currentBox11;
         wireAddressOut <= 17'b00111100001111000;
         end
      12: begin
         colourSelect <= currentBox12;
         wireAddressOut <= 17'b01011010001111000;
         end
      default: begin
         colourSelect <= 0;
         wireAddressOut <= 17'd0;
         end
    endcase
  end

  //bun memory block
  //memory address size 13bit - (4096 = 13'b1000000000000 - 3600 = 0111000010000)
  //memory block output = 3'b --> colour
  wire [11:0] bunMemInputAddress;
	assign bunMemInputAddress = memAddressPixelCount[11:0];
  wire [2:0] bunMemColour;
  bunImgMem memB(.clock(clock), .address(bunMemInputAddress),
                  .data(3'd0), .wren(1'b0), .q(bunMemColour));

  //other expantion : memory block for hold note
  //wire [2:0] bunHoldMemColour;
  //same input
  //bunHoldImgMem memBH(.clock(clock), .address(bunMemInputAddress), .data(3'd0), .wren(1'b0), .q(bunHoldMemColour));

  //colourSelect mux;
  reg [2:0] regInColour;
  always@(posedge clock) begin
    //if(holdSelect) regInColour <= bunHoldMemColour; //load hold img colour
    //else
    if(colourSelect) regInColour <= bunMemColour; /*colour from memory block*/
    else regInColour <= 3'b111; /*white - background*/
  end

//  always@(posedge clock) begin
//    if(reset) begin
//      regAddress <= 15'd0;
//      end
//    if(loadStartAddress) begin
//      regAddress <= wireAddressOut;
//		end
//  end

wire [16:0] pixelCountCorrectBits;
assign pixelCountCorrectBits = {1'd0, pixelCount[14:7], 1'd0, pixelCount[6:0]};

  always @(posedge clock) begin
    if (reset) currentAddress <= 17'd0;
    else if(loadX && loadY) currentAddress <= wireAddressOut + pixelCountCorrectBits;
  end

  //regX & regY
  always @(posedge clock) begin
    if (reset) begin
      regX <= 9'd0;
      regY <= 8'd0;
      end
    else if (loadX && loadY) begin
      regX <= currentAddress[16:8];
      regY <= currentAddress[7:0];
      end
  end

  //loading default image
  //required memory block 43200*15bits (43200 = 16'b1010100011000000)
  // closest mem size 65536 = 17'b10000000000000000
  reg [8:0] regDefaultX;
  reg [7:0] regDefaultY;
  reg [2:0] regDefaultColour;

  //default image memory
  wire [2:0] defaultMemColour;
  wire [15:0] defaultMemInputAddress;
  assign defaultMemInputAddress = memAddressGridCounter;
  defaultImgMem memD(.clock(clock), .address(defaultMemInputAddress),
                     .data(3'd0), .wren(1'b0), .q(defaultMemColour));

  //default registers stuff
  always @(posedge clock) begin
    if (reset) begin
      regDefaultX <= 9'd0;
      regDefaultY <= 8'd0;
      regDefaultColour <= 3'd0;
      end
    else if (loadDefault) begin
      regDefaultX <= {1'b0, gridCounter[15:8]};
      regDefaultY <= gridCounter[7:0];
      //add out of default mem block
      regDefaultColour <= defaultMemColour;
      end
  end

  always @(posedge clock) begin
	if (reset) begin
		scoreCounter = 8'd0;
		scoreCounterDummy = 10'd0;
		score = 8'd0;
	end
  
  if (changeScore) begin
      if (regNote1[0] && note1) scoreCounterDummy = scoreCounterDummy + 10'd1;
      if (regNote2[0] && note2) scoreCounterDummy = scoreCounterDummy + 10'd1;
      if (regNote3[0] && note3) scoreCounterDummy = scoreCounterDummy + 10'd1;
    end
	 
	else if (addScore) begin
		if (scoreCounterDummy != 10'd0) begin
			scoreCounter = scoreCounter + 8'd1;
			scoreCounterDummy = 10'd0;
			score = 8'd0;		
		end
		else scoreCounterDummy = 10'd0;
	end
	
	
	//if (!songDone) score = 8'd0;
	
	else if (songDone) begin
		score = scoreCounter;
		scoreCounter = 8'd0;
		scoreCounterDummy = 10'd0;
		if (score >= 8'd85) finalScore = 4'b1010;
		else if (score >= 8'd75) finalScore = 4'b1011;
		else if (score >= 8'd65) finalScore = 4'b1100;
		else if (score >= 8'd50) finalScore = 4'b1101;
		else if (score == 8'd0) finalScore = 4'b0000;
		else finalScore = 4'b1111;
		
	end
	
end
//assign finalScore = (score / 8'd107) * 8'd100;
hex H1 (finalScore, HEX0);

/*
always @(posedge clock) begin    
    if (addScore) begin
      if (scoreCounterDummy != 0) begin
        scoreCounter <= scoreCounter + 8'd1;
      end
    end
    if (songDone) begin
        score <= scoreCounter;
        scoreCounter <= 8'd0;        
       end
    else score <= 8'd0;
  end
  */
  //final mux select to assign outputs of VGA
  //vgaOut = starting position of square (0, 120) + regX/Y
  always@(posedge clock) begin
    if(writeDefault) begin
      vgaOutX <= 9'd0 + regDefaultX;
      vgaOutY <= 8'd60 + regDefaultY;
      vgaOutColour <= regDefaultColour;
      end
    else if(writeToScreen) begin
      vgaOutX <= 9'd0 + regX;
      vgaOutY <= 8'd60 + regY;
      vgaOutColour <= regInColour;
      end
  end

endmodule // dataPath
