module dataPath(input clock, reset, writeToScreen, loadX, loadY, input [14:0] pixelCount,
                output reg [8:0] vgaOutX, output reg [7:0] vgaOutY, output reg [2:0] vgaOutColour);

//Resolution  = 320 * 240; 76800 = 17b'10010110000000000 (17bits)
//writing to 240*180 grid; 43200 = 15b'1010,1000,1100,0000 (16bits)
//  reg [14:0] regAddress;
  reg [8:0] regX;
  reg [7:0] regY;
  reg [2:0] regColour;
  wire [16:0] wireAddressOut;
  reg [16:0] currentAddress;

  assign wireAddressOut = 17'b01011010000000000;

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
 

  //final mux select to assign outputs of VGA
  //vgaOut = starting position of square (0, 120) + regX/Y
  always@(posedge clock) begin
	if(writeToScreen) begin
      vgaOutX <= 9'd0 + regX;
      vgaOutY <= 8'd60 + regY;
      vgaOutColour <= 3'b111;
      end
  end

endmodule // dataPath