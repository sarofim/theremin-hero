module dataPath(input clock, reset, shiftSong, writeToScreen, loadStartAddress, loadX, loadY, loadDefault, writeDefault, songDone,
                input [15:0] gridCounter, input [1:0] boxCounter, input [14:0] pixelCount,
                output reg [8:0] vgaOutX, output reg [7:0] vgaOutY, output reg [2:0] vgaOutColour);

  //Resolution  = 320 * 240; 76800 = 17b'10010110000000000 (17bits)
  //writing to 240*180 grid; 43200 = 15b'1010,1000,1100,0000 (16bits)
//  reg [14:0] regAddress;
  reg [8:0] regX;
  reg [7:0] regY;
  reg [2:0] regColour;
  reg [16:0] wireAddressOut;
  reg [16:0] currentAddress;

  //3 shit register
  reg [3:0] regNote1, regNote2, regNote3;
  reg currentNote1, currentNote2, currentNote3;
  always@(posedge clock) begin
    if(reset || songDone) begin
      regNote1 <= 4'b0010;
      regNote2 <= 4'b0100;
      regNote3 <= 4'b1000;
      end
    else if(shiftSong) begin
      //set rightmost node as current note
      currentNote1 <= regNote1[0];
      currentNote2 <= regNote2[0];
      currentNote3 <= regNote3[0];

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
         colourSelect <= currentNote1;
         wireAddressOut <= 17'b01011010000000000;
         end
      2: begin
         colourSelect <= currentNote2;
         wireAddressOut <= 17'b01011010000111100;
			end
      3: begin
         colourSelect <= currentNote3;
         wireAddressOut <= 17'b01011010001111000;
         end
      default: begin
         colourSelect <= 0;
         wireAddressOut <= 17'd0;
         end
    endcase
  end

  //colourSelect mux;
  reg [2:0] regInColour;
  always@(posedge clock) begin
    if(colourSelect) regInColour <= 3'b111; /*load white*/
    else regInColour <= 3'b000; /*load black*/
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
assign pixelCountCorrectBits = {2'd0, pixelCount};

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
  //memory address 15bits for position - added 3 for color
  //required memory block 43200*15bits (43200 = 16'b1010100011000000)
  // closest mem size 65536 = 17'b10000000000000000
  reg [8:0] regDefaultX;
  reg [7:0] regDefaultY;
  reg [2:0] regDefaultColour;
  //memory block to be used in later implementations
  // wire [17:0] defaultImageAddress;
  // wire [16:0] tempMemAddress1;
  // assign tempMemAddress1 = {1'b0, gridCounter};
  // startImageAddress memD(.address(tempMemAddress1), .clock(clock), .data(18'd0),
  //                        .wren(1'b0), .q(defaultImageAddress));

  //default registers stuff
  always @(posedge clock) begin
    if (reset) begin
      regDefaultX <= 9'd0;
      regDefaultY <= 8'd0;
      regDefaultColour <= 3'd0;
      end
    else if (loadDefault) begin
      regDefaultX <= {1'b0, gridCounter[15:8] /*defaultImageAddress[17:10]*/};
      regDefaultY <= gridCounter[7:0] /*defaultImageAddress[9:3]*/;
      regDefaultColour <= 3'b000 /*defaultImageAddress[2:0]*/;
      end
  end

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