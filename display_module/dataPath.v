module dataPath(input clock, resetn, shiftSong, writeToScreen, loadStartAddress, loadX, loadY, loadDefault, writeDefault,
                input [13:0] gridCounter, input [3:0] boxCounter, input [15:0] pixelCount
                output reg [7:0] vgaOutX, output reg [6:0] vgaOutY, output reg [2:0] vgaOutColour);
  //Resolution  = 320 * 240; 76800 = 17b'10010110000000000 (17bits)
  //writing to 240*180 grid; 43200 = 15b'101,01000,1100,0000 (15bits)
  reg [14:0] regAddress;
  reg [7:0] regX;
  reg [6:0] regY;
  reg [2:0] regColour;
  reg [14:0] wireAddressOut, currentAddress;
  wire colourSelect;

  //3 shit register
  reg [3:0] regNote1, regNote2, regNote3;
  reg currentNote1, currentNote2, currentNote3;
  always@(posedge clock) begin
    if(resetn) begin
      regNote1 <= /*note1 seq*/
      regNote2 <= /*note1 seq*/
      regNote3 <= /*note1 seq*/
      end
    else if(shiftSong) begin
      //set rightmost node as current note
      currentNote1 = regNote1[0];
      currentNote2 = regNote2[0];
      currentNote3 = regNode3[0];

      //shift all registers right
      regNote1 >> 1b'1;
      regNote2 >> 1b'1;
      regNote3 >> 1b'1;

      //set leftmost to current value
      regNote1[3] = currentNote1;
      regNote2[3] = currentNote2;
      regNote3[3] = currentNote3;
      end
  end

  wire colourSelect;
  //noteSelect mux
  always@(posedge clock) begin
    case(boxCounter)
      0: colourSelect <= currentNote1;
      1: colourSelect <= currentNote2;
      2: colourSelect <= currentNote3;
      default: colourSelect <= 1b'0;
    endcase
  end

  //colourSelect mux;
  wire [2:0] regInColour;
  always@(posedge clock) begin
    if(colourSelect) regInColour <= 3'b000; /*load black*/
    else regInColour <= 3'b111; /*load white*/
  end

  //address memory register : 15 bit wide, 12 rows (12*15)
  startAddressMem memA(.clock(clock), .address({0,boxCounter}), .data(15'd0),
                       .wren(1'b0), .q(wireAddressOut));

  always@(posedge clock) begin
    if(resetn) begin
      regAddress <= 15'd0;
      end
    if(loadStartAddress) begin
      regAddress <= wireAddressOut;
      end
  endmodule

  always @(posedge clock) begin
    if (resetn) currentAddress <= 15'd0;
    else currentAddress <= wireAddressOut + pixelCount;
  end

  //regX & regY
  always @(posedge clock) begin
    if (!resetn) begin
      regX <= 8'd0;
      regY <= 7'd0;
      end
    else if (loadX) regX <= currentAddress[14:7];
    else if (loadY) regY <= currentAddress[6:0];
  end

  //loading default image
  //memory address 15bits for position - added 3 for color
  //required memory block 43200*15bits (closest 8192)
  //8192 = 10,0000,0000,0000 = 14bit
  reg [17:0] defaultImageAddress;
  reg [7:0] regDefaultX;
  reg [6:0] regDefaultY;
  reg [2:0] regDefaultColour;s
  startImageMem memD(.address(gridCounter), .clock(clock), .data(15'd0),
                       .wren(1'b0), .q(defaultImageAddress));

  //default registers stuff
  always @(posedge clock) begin
    if (!resetn) begin
      regDefaultX <= 8'd0;
      regDefaultY <= 7'd0;
      regDefaultColour <= 3'd0;
      end
    else if (loadDefault) begin
      regDefaultX <= defaultImageAddress[17:10];
      regDefaultY <= defaultImageAddress[9:3];
      regDefaultColour <= defaultImageAddress[2:0]
      end
  end

  //final mux select to assign outputs of VGA
  //vgaOut = starting position of square (0, 120) + regX/Y
  always@(posedge clock) begin
    if(writeToScreen && writeDefault) begin
      vgaOutX <= 0 + regDefaultX;
      vgaOutY <= 120 + regDefaultY;
      vgaOutColour <= regDefaultColour;
      end
    else if(writeToScreen) begin
      vgaOutX <= 0 + regX;
      vgaOutY <= 120 + regY;
      vgaOutColour <= regDefaultColour;
      end
  end

endmodule // dataPath
