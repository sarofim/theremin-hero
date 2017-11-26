module FSM (clock, reset, start, loadDefault, writeDefault, loadX, loadY, 
	writeToScreen, loadStartAddress, shiftSong, gridCounter, boxCounter, songCounter, pixelCount, songDone, changeScore, addScore);
	
	input clock;
	input reset;
	input start;
	output loadDefault, writeDefault, loadX, loadY, writeToScreen, loadStartAddress, shiftSong;
	output [15:0]gridCounter;
	output [3:0]boxCounter;
	output [14:0]pixelCount;
	//output [3:0]songCounter;
	output [7:0]songCounter;
	output songDone;
	output addScore, changeScore;

	wire readyForSong, beatIncremented, shapeDone, startingAddressLoaded;
	
	wire [3:0] currentState, nextState;
	
	FSM1 B1 (clock, reset, readyForSong, beatIncremented, shiftSong, 
		songDone, songCounter, changeScore, addScore);
		
	FSM2 B2 (clock, reset, start, beatIncremented, songDone, shapeDone, loadDefault, 
		writeDefault, readyForSong, loadStartAddress, startingAddressLoaded, gridCounter, boxCounter, currentState, nextState);
	
	FSM3 B3 (clock, reset, startingAddressLoaded, shapeDone, loadX, loadY, writeToScreen, pixelCount);
	
	
	
endmodule
