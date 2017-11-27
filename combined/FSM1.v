module FSM1 (clock, reset, readyForSong, beatIncremented, shiftSong, 
	songDone, songCounter, changeScore, addScore);

input clock;
input reset;
input readyForSong;
output reg beatIncremented;
output reg shiftSong;
output reg songDone;
//output reg [3:0]songCounter; //enter with length of song [7:0] for 128
	output reg [7:0] songCounter; //song length is 59 bits - try 63
output reg changeScore, addScore;


reg [3:0]currentState, nextState;
reg enableSongCounter, resetSongCounter;
	reg [4:0]tempoCounter; //enter with correct speed
reg resetTempoCounter;
reg startNextBeat;

localparam 	state_idle = 3'b000,
			state_startSong = 3'b001,
			state_waitForSongBeat = 3'b010,
			state_shiftSong = 3'b011,
			state_drawScreen = 3'b100,
			state_waitForScreen = 3'b101;

always @(*) 
	begin: state_table
	case(currentState)
		state_idle: nextState = readyForSong ? state_startSong : state_idle;
		state_startSong: nextState = state_waitForSongBeat;
		state_waitForSongBeat: begin
			if (startNextBeat) nextState = state_shiftSong;//add max tempo value as determined by speed of song
			else nextState = state_waitForSongBeat;
		end
		state_shiftSong:
			nextState = state_drawScreen;
		state_drawScreen: nextState = state_waitForScreen;
		state_waitForScreen: begin
			if (readyForSong & songCounter == /*4'd8*/ /*8'd128*/ 8'd65) nextState = state_idle;//enter with length of song - 8'd128
			else if (readyForSong & songCounter != /*4'd8*/ /*8'd128*/ 8'65) nextState = state_waitForSongBeat; //8'd128
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
	resetTempoCounter = 1'b0;
	changeScore = 1'b0;
	addScore = 1'b0;

	case (currentState)
	state_idle: begin
		songDone = 1'b1; //is this necessary??
		resetSongCounter = 1'b1;
	end
	state_startSong: begin
		resetTempoCounter = 1'b1;
	end
	state_waitForSongBeat: begin
	end
	state_shiftSong: begin
		shiftSong = 1'b1;
		addScore = 1'b1;

	end
	state_drawScreen:begin
		beatIncremented = 1'b1;
	end
	state_waitForScreen:begin
			enableSongCounter = 1'b1;
			changeScore = 1'b1;
		//if (songCounter == 8'd128) songDone = 1'b1; //might need to put back in
	end
	endcase
end

//tempo - for do file do 1/6 speed of clock
always @ (posedge clock) begin //tempo - currently doing 1 second - 1Hz - 49999999 - 10111110101111000001111111 
	//change tempo to 1/8 of a second - 6250000 - 23'd6250000
	if (tempoCounter == 25'd24999999 /* 23'd6250000*/) startNextBeat <= 1'b1;
	else startNextBeat <= 1'b0;
	if (resetTempoCounter) tempoCounter <= 25'd0; //add with tempo
	else if (tempoCounter == 25'd24999999 /*23'd6250000*/) tempoCounter <= 25'd0;
	else tempoCounter <= tempoCounter + 25'd1;
	
end

always @ (posedge clock) begin //this will have to be changed in scale up
	if (resetSongCounter) songCounter = 8'd0;
	else if (enableSongCounter) songCounter = songCounter + 8'd1;
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
