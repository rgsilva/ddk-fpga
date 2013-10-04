// Glitch modes

`define GLITCH_MODE_NOTHING	4'b0000
`define GLITCH_MODE_AND		4'b0001
`define GLITCH_MODE_OR		4'b0010
`define GLITCH_MODE_XOR		4'b0100
`define GLITCH_MODE_ENABLE	4'b1000

// Glitch module states

`define IDLE            2'b00
`define DELAY           2'b01
`define WIDTH           2'b10

// Wishbone interface

`define GLITCH_STATUS   4'h0    // (r/w) Status
`define GLITCH_WIDTH    4'h1    // (r/w) Set glitch width
`define GLITCH_DELAY_0  4'h2    // (r/w) Set delay[7:0]
`define GLITCH_DELAY_1  4'h3    // (r/w) Set delay[15:8]
`define GLITCH_MODE 	4'h4	// (r/w) Set mode
