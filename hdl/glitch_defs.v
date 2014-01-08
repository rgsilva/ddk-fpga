// Glitch modes

// Nothing and gates
`define GLITCH_MODE_BYPASS	8'b00000000
`define GLITCH_MODE_ZERO	8'b00000001
`define GLITCH_MODE_ONE		8'b00000010
`define GLITCH_MODE_NOT		8'b00000100
`define GLITCH_MODE_CLKGL	8'b00001000

// Glitch module states

`define GLITCH_STATE_IDLE	3'b000
`define GLITCH_STATE_WAIT	3'b001
`define GLITCH_STATE_READ	3'b010
`define GLITCH_STATE_DELAY	3'b011
`define GLITCH_STATE_WIDTH	3'b100

// Glitch reset module states
`define GLITCH_RESET_IDLE	1'b0
`define GLITCH_RESET_RESET	1'b1

// Wishbone interface

`define GLITCH_STATUS   	4'h0    // (r) Status
`define GLITCH_QUEUE_0		4'h1	// (r/w) Data[7:0]
`define GLITCH_QUEUE_1		4'h2	// (r/w) Data[15:8]
`define GLITCH_QUEUE_2		4'h3	// (r/w) Data[23:16]
`define GLITCH_QUEUE_3		4'h4	// (r/w) Data[31:24]
`define GLITCH_FIFO_EMPTY	4'h5	// (r) Fifo EMPTY flag
`define GLITCH_FIFO_FULL	4'h6	// (r) Fifo FULL flag