module FSM2 (clock, reset, start, beatIncremented, songDone, shapeDone, loadDefault, 
	writeDefault, readyForSong, loadStartAddress, startingAddressLoaded, [15:0]gridCounter, [1:0]boxCounter);

input clock;
input start;
input reset;
input beatIncremented;
input songDone;
input shapeDone;
output reg loadDefault;
output reg writeDefault;
output reg readyForSong;
output reg loadStartAddress;
output reg startingAddressLoaded;
output reg [15:0]gridCounter; //240*180 = 43200 in binary - 16 bits
output reg [1:0]boxCounter; //3 boxes - 3 in binary is 11

reg [3:0]currentState, nextState; //1011 = 11 in binary - 4 bits needed
reg enableGridCounter, clearGridCounter, 
	enableBoxCounter, clearBoxCounter;

localparam 	state_reset = 4'b0000,
			state_resetWait = 4'b0001,
			state_idle = 4'b0010,
			state_loadDefault = 4'b0011,
			state_writeDefault= 4'b0100,
			state_start = 4'b0101,
			state_startWait = 4'b0110,
			state_waitForSong = 4'b0111,
			state_loadBoxCoordinate = 4'b1000,
			state_drawShape = 4'b1001,
			state_waitForShape = 4'b1010;

always@(*)
	begin: state_table
	case(currentState)
		state_reset: nextState = reset ? state_resetWait : state_reset;
		state_resetWait: nextState = reset ? state_resetWait : state_idle;
		state_idle: nextState = state_loadDefault;
		state_loadDefault: nextState = state_writeDefault;
		state_writeDefault: nextState = (gridCounter == 16'd43200) ? state_start : state_loadDefault;
		state_start: nextState = start ? state_startWait : state_start;
		state_startWait: nextState = start ? state)startWait : waitForSong;
		state_waitForSong: begin
			if (beatIncremented & SongDone) nextState = state_idle;
			else if (beatIncremented & !SongDone) nextState = state_loadBoxCoordinate;
			else nextState = state_waitForSong;
		end
		state_loadBoxCoordinate: nextState = state_drawShape;
		state_drawShape: nextState = state_waitForShape;
		state_waitForShape: begin
			if (shapeDone & boxCounter == 2'd3) nextState = state_waitForSong; //this will have to be changed in scale up
			else if (shapeDone & boxCounter != 2'd3) nextState = state_loadBoxCoordinate; //this will have to be changed in scale up
			else nextState = state_waitForShape;
		end
		default: nextState = state_idle;
	endcase
end		

always @(*)
	begin: enable_signals
		loadDefault = 1'b0;
		writeDefault = 1'b0;
		readyForSong = 1'b0;
		loadStartAddress = 1'b0;
		startingAddressLoaded = 1'b0;
		enableBoxCounter = 1'b0;
		resetBoxCounter = 1'b0;
		enableGridCounter = 1'b0;
		resetGridCounter = 1'b0;

	case (currentState)
		state_reset: begin
			//nothing
		end
		state_resetWait: begin
			//nothing
		end
		state_idle: begin
			resetGridCounter;
		end
		state_loadDefault: begin
			loadDefault = 1'b1;
		end
		state_writeDefault: begin
			writeDefault = 1'b1;
			enableGridCounter = 1'b1;
		end
		state_start: begin
			//nothing?
		end
		state_startWait: begin
			//nothing?
		end
		state_waitForSong: begin
			readyForSong = 1'b1;
			resetBoxCounter = 1'b1;
		end
		state_loadBoxCoordinate: begin
			loadStartAddress = 1'b1;
		end
		state_drawShape: begin
			startingAddressLoaded = 1'b1;
			enableBoxCounter = 1'b1; //is this the right place to enableBoxCounter???
			//box counter must be enables after start address is loaded, but should be in a state that is only hit once at a time

		end
		state_waitForShape: begin
			//nothing? its a wait state
		end

	endcase		
end


always @ (posedge clock) begin
	if (resetGridCounter) gridCounter = 16'd0;
	else if (enableGridCounter) gridCounter = gridCounter + 16'd1;
end

always @ (posedge clock) begin //this will have to be changed in scale up
	if (resetBoxCounter) boxCounter = 2'd0;
	else if (enableBoxCounter) boxCounter = boxCounter + 2'd1;
end

always @ (posedge clock)
begin: state_FFs
	if(reset)
		currentState <= state_resetWait; //is this needed? probably yea
	else begin
		currentState <= nextState;
	end
end


endmodule
