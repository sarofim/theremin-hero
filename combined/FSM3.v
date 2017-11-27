module FSM3 (input clock, reset, startingAddressLoaded,
                     output reg shapeDone, loadX, loadY, writeToScreen,
	     output reg [14:0] pixelCount, memAddressPixelCount);
  reg [1:0] currentState, nextState;
	reg [7:0]xCount;
	reg [6:0]yCount;
  reg pixelCounterIncrement, clearPixelCounter;
  
  localparam state_idle       = 2'b00,
             state_loadPoint  = 2'b01,
             state_writePoint = 2'b10;

  always@(*)
    begin: state_table
        case(currentState)
        state_idle: nextState = startingAddressLoaded ? state_loadPoint : state_idle;
        state_loadPoint: nextState = state_writePoint;
        state_writePoint: nextState = (xCount == 8'd60 && yCount == 7'd60) ? state_idle : state_loadPoint;
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
    if(clearPixelCounter || reset) begin
		pixelCount = 15'd0;
		xCount = 8'd0;
		yCount = 7'd0;
	    	memAddressPixelCount = 15'd0;
	 end
    else begin
	    if (xCount == 8'd60 && yCount == 7'd60 & pixelCounterIncrement)
		begin
			pixelCount = 15'd0;
			xCount = 8'd0;
			yCount = 7'b0;			
		end
	 else if(pixelCounterIncrement) begin
		if (xCount == 8'd60) begin
			yCount = yCount + 1'd1;
			xCount = 8'd0;
			memAddressPixelCount = memAddressPixelCount + 15'd1;
		end
		else begin
			memAddressPixelCount = memAddressPixelCount + 15'd1;
			xCount = xCount + 8'd1;
		end
		pixelCount = {xCount, yCount};
	end
    end
end

  always@(posedge clock)
  begin: state_FFs
	if (reset) currentState = state_idle;
	else begin
		currentState <= nextState;
	end
end

endmodule




 /*//pixelCount maxVal 3600 : 111000010000
  always@(posedge clock) begin
    if(clearPixelCounter || reset) pixelCount = 15'd0;
    else if (pixelCount == 15'b000111000010000 & pixelCounterIncrement) pixelCount = 15'd0;
	 else if(pixelCounterIncrement) pixelCount = pixelCount + 1;
  end
  

*/
