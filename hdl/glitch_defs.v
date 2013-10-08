// Glitch modes

// Nothing and gates
`define GLITCH_MODE_BYPASS	8'b00000000
`define GLITCH_MODE_ZERO	8'b00000001
`define GLITCH_MODE_ONE		8'b00000010
`define GLITCH_MODE_NOT		8'b00000100

// Glitch module states

`define IDLE            	2'b00
`define DELAY           	2'b01
`define WIDTH           	2'b10

// Wishbone interface

`define GLITCH_STATUS   	4'h0    // (r/w) Status
`define GLITCH_WIDTH    	4'h1    // (r/w) Set glitch width
`define GLITCH_DELAY_0  	4'h2    // (r/w) Set delay[7:0]
`define GLITCH_DELAY_1  	4'h3    // (r/w) Set delay[15:8]
`define GLITCH_MODE 		4'h4	// (r/w) Set mode
