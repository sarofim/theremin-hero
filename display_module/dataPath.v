module dataPath(input clock, reset, shiftSong, writeToScreen, loadStartAddress, loadX, loadY, loadDefault, writeDefault, songDone,
                input [15:0] gridCounter, input [1:0] boxCounter, input [15:0] pixelCount,
                output reg [8:0] vgaOutX, output reg [7:0] vgaOutY, output reg [2:0] vgaOutColour);

  //Resolution  = 320 * 240; 76800 = 17b'10010110000000000 (17bits)
  //writing to 240*180 grid; 43200 = 15b'101,01000,1100,0000 (15bits)
  reg [14:0] regAddress;
  reg [8:0] regX;
  reg [7:0] regY;
  reg [2:0] regColour;
  wire [14:0] wireAddressOut;
  reg [14:0] currentAddress;

  //3 shit register
  reg [3:0] regNote1, regNote2, regNote3;
  reg [3:0] shiftedRegNote1, shiftedRegNote2, shiftedRegNote3;
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
      shiftedRegNote1 <= regNote1 >> 1'b1;
      shiftedRegNote2 <= regNote2 >> 1'b1;
      shiftedRegNote3 <= regNote3 >> 1'b1;
      end
  end

  reg colourSelect;
  //noteSelect mux - loads start address for each box
  always@(posedge clock) begin
    case(boxCounter)
      0: begin
         colourSelect <= currentNote1;
         currentAddress <= 15'b101101000000000;
         end
      1: begin
         colourSelect <= currentNote2;
         currentAddress <= 15'b101101000111100;
      2: begin
         colourSelect <= currentNote3;
         currentAddress <= 15'b101101001111000;
         end
      default: begin
         colourSelect <= 0;
         currentAddress <= 15'd0;
         end
    endcase
  end

  //colourSelect mux;
  reg [2:0] regInColour;
  always@(posedge clock) begin
    if(colourSelect) regInColour <= 3'b111; /*load white*/
    else regInColour <= 3'b000; /*load black*/
  end

  always@(posedge clock) begin
    if(reset) begin
      regAddress <= 15'd0;
      end
    if(loadStartAddress) begin
      regAddress <= wireAddressOut;
		end
  end

  always @(posedge clock) begin
    if (reset) currentAddress <= 15'd0;
    else currentAddress <= wireAddressOut + pixelCount;
  end

  //regX & regY
  always @(posedge clock) begin
    if (!reset) begin
      regX <= 9'd0;
      regY <= 8'd0;
      end
    else if (loadX && loadY) begin
      regX <= {1'b0, currentAddress[14:7]};
      regX <= {1'b0, currentAddress[6:0]};
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
    if (!reset) begin
      regDefaultX <= 8'd0;
      regDefaultY <= 7'd0;
      regDefaultColour <= 3'd0;
      end
    else if (loadDefault) begin
      regDefaultX <= {1'b0, gridCounter[14:7] /*defaultImageAddress[17:10]*/};
      regDefaultY <= {1'b0, gridCounter[6:0] /*defaultImageAddress[9:3]*/};
      regDefaultColour <= 3'b000 /*defaultImageAddress[2:0]*/;
      end
  end

  //final mux select to assign outputs of VGA
  //vgaOut = starting position of square (0, 120) + regX/Y
  always@(posedge clock) begin
    if(writeToScreen && writeDefault) begin
      vgaOutX <= 9'd0 + regDefaultX;
      vgaOutY <= 8'd120 + regDefaultY;
      vgaOutColour <= regDefaultColour;
      end
    else if(writeToScreen) begin
      vgaOutX <= 9'd0 + regX;
      vgaOutY <= 8'd120 + regY;
      vgaOutColour <= regDefaultColour;
      end
  end

endmodule // dataPath
