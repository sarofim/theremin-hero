module FSM3 (input clock, reset, startingAddressLoaded,
                     output reg shapeDone, loadX, loadY, writeToScreen,
                     output reg [14:0] pixelCount);
  reg [1:0] currentState, nextState;

  reg pixelCounterIncrement, clearPixelCounter;
  
  localparam state_idle       = 2'b00,
             state_loadPoint  = 2'b01,
             state_writePoint = 2'b10;

  always@(*)
    begin: state_table
        case(currentState)
        state_idle: nextState = startingAddressLoaded ? state_loadPoint : state_idle;
        state_loadPoint: nextState = state_writePoint;
        state_writePoint: nextState = pixelCount == 15'b000111000010000 /*15'd4*/ ? state_idle : state_loadPoint;
        default: nextState = state_idle;
        endcase
  end

  always@(*)
    begin: enable_signals
      loadX = 1'b0;
      loadY = 1'b0;
      writeToScreen = 1'b0;
      pixelCounterIncrement = 1'b0;
		clearPixelCounter = 1'b0;
		shapeDone = 1'b0;

    case(currentState)
      state_idle:begin
        shapeDone = 1'b1;
		  clearPixelCounter = 1'b1;
        end
      state_loadPoint: begin
        loadX = 1'b1;
        loadY = 1'b1;
        end
      state_writePoint: begin
        writeToScreen = 1'b1;
        pixelCounterIncrement = 1'b1;
		  end
    endcase
  end

  //pixelCount maxVal 3600 : 111000010000
  always@(posedge clock) begin
    if(clearPixelCounter || reset) pixelCount = 15'd0;
    else if (pixelCount == 15'b000111000010000 /*15'd4 */ & pixelCounterIncrement) pixelCount = 15'd0;
	 else if(pixelCounterIncrement) pixelCount = pixelCount + 1;
  end
  
  always@(posedge clock)
  begin: state_FFs
	if (reset) currentState = state_idle;
	else begin
		currentState <= nextState;
	end
end

endmodule