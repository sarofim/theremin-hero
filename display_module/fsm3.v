module pixelControl (input clock, resetn, startingAddressLoaded,
                     output reg shapeDone, loadX, loadY, writeToScreen, pixelCounterIncrement, clearPixelCounter);
  reg [1:0] currentstate, nextstate;
  reg [15:0] pixelCount;

  //pixelCount maxVal 3600 : 111000010000

  localparam state_idle       = 2'b00;
             state_loadPoint  = 2'b01;
             state_writePoint = 2'b10;

  always@(*)
    begin: state_table
        case(currentstate)
        state_idle: nextstate = startingAddressLoaded ? state_loadPoint : state_idle;
        state_loadPoint: nextstate = state_writePoint;
        state_writePoint: nextstate = pixelCounterIncrement == 16'b111000010000 ? state_idle : state_loadPoint;
        default: nextstate = state_idle;
        endcase
  end

  always@(*)
    begin: enable_signals
      loadX = 1'b0;
      loadY = 1'b0;
      writeToScreen = 1'b0;
      pixelCounterIncrement = 1'b0;

    case(currentstate)
      state_idle:begin
        shapeDone = 1'b1;
        end
      state_loadPoint: begin
        loadX = 1'b1;
        loadY = 1'b1;
        end
      state_writePoint: begin
        writeToScreen = 1'b1;
        pixelCounterIncrement = 1'b1;
    endcase
  end

  always@(posedge clock) begin
    if(clearPixelCounter || resetn) pixelCount = 16'd0;
    else if(pixelCounterIncrement) pixelCount = pixelCount + 1;
  end

endmodule
