module memory(input clock, input [11:0] address, output [2:0] q);

bunImgMem m(.clock(clock), .data(3'b000), .q(q), .wren(1'b0), .address(address));

endmodule
