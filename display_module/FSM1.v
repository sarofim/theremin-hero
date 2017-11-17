module FSM1 (clock, reset, readyForSong, beatIncremented, shiftSong, 
	songDone, songCounter);

input clock;
input reset;
input readyForSong;
output reg beatIncremented;
output reg shiftSong;
output reg songDone;
output reg [x:0]songCounter; //enter with length of song

reg [3:0]currentState, nextState;
reg enableSongCounter, resetSongCounter;

localparam 	state_idle = 3'b000,
			state_startSong = 3'b001,
			state_shiftSong = 3'b010,
			start_drawScreen = 3'b011,
			start_waitForScreen = 3'b100;

always @(*) 
	begin: state_table
	case(currentState)
		state_idle: nextState = readyForSong ? state_startSong : state_idle;
		state_startSong: nextState = state_shiftSong;
		start_shiftSong: nextState = state_drawScreen;
		start_drawScreen: nextState = state_waitForScreen;
		start_waitForScreen: begin
			if (readyForSong & songCounter == x) nextState = state_idle;//enter with length of song
			else if (readyForSong & songCounter != x) nextState = state_drawScreen;
			else nextState = state_waitForScreen;
		end
	endcase
end

always @(*)
	begin: enable_signals
	shiftSong = 1'b0;
	songDone = 1'b0;
	enableSongCounter = 1'b0;
	resetSongCounter = 1'b0;
	beatIncremented = 1'b0;

	case (currentState)
	state_idle: begin
		//nothing
	end
	state_startSong: begin
		resetSongCounter = 1'b1;
	end
	start_shiftSong: begin
		shiftSong = 1'b1;
	end
	start_drawScreen:begin
		beatIncremented = 1'b1;
		enableSongCounter = 1'b1;
	end
	start_waitForScreen:begin
		//nothing
	end
	endcase
end

always @ (posedge clock) begin //this will have to be changed in scale up
	if (resetSongCounter) songCounter = 2'd0;
	else if (enableSongCounter) songCounter = songCounter + 2'd1;
end

always @ (posedge clock)
begin: state_FFs
	if(reset)
		currentState <= state_idle; //is this needed? probably yea
	else begin
		currentState <= nextState;
	end
end

endmodule