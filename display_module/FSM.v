module FSM (clock, reset, start, loadDefault, writeDefault, loadX, loadY, 
	writeToScreen, loadStartAddress, shiftSong, gridCounter, boxCounter, songCounter, pixelCount, songDone);
	
	input clock;
	input reset;
	input start;
	output loadDefault, writeDefault, loadX, loadY, writeToScreen, loadStartAddress, shiftSong;
	output [15:0]gridCounter;
	output [1:0]boxCounter;
	output [15:0]pixelCount;
	output [2:0]songCounter;
	output songDone;

	wire readyForSong, beatIncremented, shapeDone, startingAddressLoaded, pixelCounterIncrement, clearPixelCounter;
	
	wire [3:0] currentState, nextState;
	
	FSM1 B1 (clock, reset, readyForSong, beatIncremented, shiftSong, 
		songDone, songCounter);
		
	FSM2 B2 (clock, reset, start, beatIncremented, songDone, shapeDone, loadDefault, 
		writeDefault, readyForSong, loadStartAddress, startingAddressLoaded, gridCounter, boxCounter, currentState, nextState);
	
	FSM3 B3 (clock, reset, startingAddressLoaded, shapeDone, loadX, loadY, writeToScreen, 
		pixelCounterIncrement, clearPixelCounter, pixelCount);
	
	
	
endmodule