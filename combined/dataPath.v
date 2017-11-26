module dataPath(input clock, reset, shiftSong, writeToScreen, loadStartAddress, loadX, loadY, loadDefault, writeDefault, songDone,
                input [15:0] gridCounter, input /*[1:0]*/ [3:0] boxCounter, input [14:0] pixelCount,
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
  //reg [7:0] regNote1, regNote2, regNote3;
  reg [114:0] regNote1, regNote2, regNote3;
  reg currentBox1, currentBox2, currentBox3, currentBox4, currentBox5, currentBox6, currentBox7, currentBox8,
      currentBox9, currentBox10, currentBox11, currentBox12;
  always@(posedge clock) begin
    if(reset || songDone || writeDefault) begin
      //regNote1 <= 4'b0010;
      //regNote2 <= 4'b0100;
      //regNote3 <= 4'b1000;
      //regNote1 <= 8'b00110000;
      //regNote2 <= 8'b01001000;
      //regNote3 <= 8'b10000000;
		//regNote1 <= 128'b1111111100000000000000000000000011111111000000000000000000000000000000000000000011111111000000000000000000000000;
		//regNote2 <= 128'b0000000011111111000000000000000000000000111111110000000000000000000000001010101000000000111111110000000000000000;
		//regNote3 <= 128'b0000000000000000111111111111111100000000000000001111111111111111101010100000000000000000000000001111111111111111;


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
  wire [12:0] bunMemInputAddress;
  assign bunMemInputAddress = {/*discuss it with michelle*/};
  wire [2:0] bunMemColour;
  bunImgMem memB(.clock(clock), .address(bunMemInputAddress),
                  .data(3'd0), .wren(1'b0), .q(bunMemColour));

  //other expantion : memory block for hold note
  //wire [2:0] bunHoldMemColour;
  //same input
  //bugHoldImgMem bun(.clock(clock), .address(bunMemInputAddress), .data(3'd0), .wren(1'b0), .q(bunHoldMemColour));

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
  assign defaultMemInputAddress = gridCounter;
  defaultImgMem memD(.clock(clock), .address(defaultInputAddress),
                     .data(3'd0), .wren(1'b0), .q(defaultMemColour));;

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
