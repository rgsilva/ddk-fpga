`timescale 1 ns/1 ps
`include "../hdl/glitch_defs.v"

// --------------------------------------------------------------------
// Definitions

module glitch_wb_tb();

reg	tb_clk;
reg	tb_rst;

reg tb_clk_in;
reg tb_clk_gl;
wire tb_clk_out;

reg 			tb_we_o;
reg		[7:0]	tb_dat_o;
reg		[5:2]	tb_adr_o;
reg 			tb_stb_o;
wire	[7:0]	tb_dat_i;
wire			tb_ack_i;

glitch_wb gi(
	.clk_i(tb_clk),
	.rst_i(tb_rst),
	.dat_i(tb_dat_o),
	.adr_i(tb_adr_o),
	.dat_o(tb_dat_i),
	.stb_i(tb_stb_o),
	.we_i(tb_we_o),
	.ack_o(tb_ack_i),
	.clk_in(tb_clk_in),
	.clk_gl(tb_clk_gl),
	.clk_out(tb_clk_out)
);

// --------------------------------------------------------------------
// Tasks

task wb_write;
input [7:0] adr_o;
input [7:0] dat_o;

begin
  @(posedge tb_clk);
  tb_stb_o <= 1'b1;
  tb_we_o <= 1'b1;
  tb_dat_o <= dat_o;
  tb_adr_o <= adr_o;

  @(posedge tb_clk);
  tb_stb_o <= 1'b0;

  @(posedge tb_clk);
  if(!tb_ack_i)
  begin
    $display("Write failed: 0x%02H, 0x%02H", tb_adr_o, tb_dat_o);
  end
end
endtask

reg [7:0] read_data;
task wb_read;
input [7:0] adr_o;

begin
  @(posedge tb_clk);
  tb_stb_o <= 1'b1;
  tb_we_o <= 1'b0;
  tb_adr_o <= adr_o;

  @(posedge tb_clk);
  tb_stb_o <= 1'b0;

  @(posedge tb_clk);
  read_data <= tb_dat_i;

  if(!tb_ack_i)
  begin
    $display("Read failed: 0x%02H, 0x%02H", tb_adr_o, tb_dat_i);
  end
end
endtask

task wb_wait;
begin
	#500 begin
		
	end
end
endtask

// --------------------------------------------------------------------
// Code

initial
begin
	tb_clk <= 1'b0;
	tb_clk_in <= 1'b0;
	tb_clk_gl <= 1'b0;
	tb_rst <= 1'b0;
	#5 tb_rst <= 1'b1;
	#40 tb_rst <= 1'b0;
end

always
begin
	#10 tb_clk <= ~tb_clk;
end

always
begin
	#15 tb_clk_in <= ~tb_clk_in;
end

always
begin
	#7 tb_clk_gl <= ~tb_clk_gl;
end

initial
begin
	// Wait for the reset to finish.
	#50
	begin
		
	end

	// It should start as ready.
	#1 wb_read(`GLITCH_STATUS);
	#1 if(read_data != 8'b1) $stop;

	// -- Test blocks --

	#1 wb_write(`GLITCH_QUEUE_0, `GLITCH_MODE_CLKGL);
	#1 wb_write(`GLITCH_QUEUE_1, 8'h0);
	#1 wb_write(`GLITCH_QUEUE_2, 8'h0);
	#1 wb_write(`GLITCH_QUEUE_3, 8'h0);

	// Delay = 0x2, Width = 0x2
	#1 wb_write(`GLITCH_QUEUE_0, `GLITCH_MODE_CLKGL);
	#1 wb_write(`GLITCH_QUEUE_1, 8'h2);
	#1 wb_write(`GLITCH_QUEUE_2, 8'h2);
	#1 wb_write(`GLITCH_QUEUE_3, 8'h0);

	#1 wb_write(`GLITCH_QUEUE_0, `GLITCH_MODE_CLKGL);
	#1 wb_write(`GLITCH_QUEUE_1, 8'h0);
	#1 wb_write(`GLITCH_QUEUE_2, 8'h0);
	#1 wb_write(`GLITCH_QUEUE_3, 8'h0);

	// Delay = 0x2, Width = 0x4
	#1 wb_write(`GLITCH_QUEUE_0, `GLITCH_MODE_CLKGL);
	#1 wb_write(`GLITCH_QUEUE_1, 8'h2);
	#1 wb_write(`GLITCH_QUEUE_2, 8'h4);
	#1 wb_write(`GLITCH_QUEUE_3, 8'h0);

	// Delay = 0x2, Width = 0x2
	#1 wb_write(`GLITCH_QUEUE_0, `GLITCH_MODE_CLKGL);
	#1 wb_write(`GLITCH_QUEUE_1, 8'h2);
	#1 wb_write(`GLITCH_QUEUE_2, 8'h2);
	#1 wb_write(`GLITCH_QUEUE_3, 8'h0);

	#1 wb_write(`GLITCH_QUEUE_0, `GLITCH_MODE_CLKGL);
	#1 wb_write(`GLITCH_QUEUE_1, 8'h0);
	#1 wb_write(`GLITCH_QUEUE_2, 8'h0);
	#1 wb_write(`GLITCH_QUEUE_3, 8'h0);


	// Delay = 0x2, Width = 0x4
	#1 wb_write(`GLITCH_QUEUE_0, `GLITCH_MODE_CLKGL);
	#1 wb_write(`GLITCH_QUEUE_1, 8'h2);
	#1 wb_write(`GLITCH_QUEUE_2, 8'h4);
	#1 wb_write(`GLITCH_QUEUE_3, 8'h0);

	// Fill the FIFO.
	repeat (249)
	begin
		// NOP
		#1 wb_write(`GLITCH_QUEUE_0, `GLITCH_MODE_BYPASS);
		#1 wb_write(`GLITCH_QUEUE_1, 8'h0);
		#1 wb_write(`GLITCH_QUEUE_2, 8'h0);
		#1 wb_write(`GLITCH_QUEUE_3, 8'h0);
	end

	// It should start by itself after the FIFO is full.
	#1 wb_read(`GLITCH_STATUS);
	#1 if(read_data != 8'b0) $stop;

	// After a while it should be ready again.
	#10000
	begin
	 	#1 wb_read(`GLITCH_STATUS);
		#1 if(read_data != 8'b1) $stop;
	end

	$display("Testbench completed successfully!");
	$stop;
end

// Create human-readable labels
reg [8*10 : 0] tb_adr_o_str;
always @ (tb_adr_o)
begin
	case (tb_adr_o)
		`GLITCH_STATUS:		tb_adr_o_str = "Status";
		`GLITCH_QUEUE_0:	tb_adr_o_str = "Queue 0";
		`GLITCH_QUEUE_1:	tb_adr_o_str = "Queue 1";
		`GLITCH_QUEUE_2:	tb_adr_o_str = "Queue 2";
		`GLITCH_QUEUE_3:	tb_adr_o_str = "Queue 3";
		default: 			tb_adr_o_str = "??";
	endcase
end

reg [8*6 : 0] tb_we_o_str;
always @ (tb_we_o)
begin
	case (tb_we_o)
		1'b0:			tb_we_o_str = "Read";
		1'b1:			tb_we_o_str = "Write";
		default: 		tb_adr_o_str = "??";
	endcase
end

reg [8*7 : 0] tb_mode_str;
always @ (gi.glitchi.glitch_mode)
begin
	case (gi.glitchi.glitch_mode)
		`GLITCH_MODE_BYPASS:	tb_mode_str = "Bypass";
		`GLITCH_MODE_ZERO: 		tb_mode_str = "Zero";
		`GLITCH_MODE_ONE:		tb_mode_str = "One";
		`GLITCH_MODE_NOT:		tb_mode_str = "NOT";
		`GLITCH_MODE_CLKGL:		tb_mode_str = "CLK GL";
		default:				tb_mode_str = "??";
	endcase
end

reg [8*5 : 0] tb_state_str;
always @ (gi.glitchi.state)
begin
    case (gi.glitchi.state)
        `GLITCH_STATE_IDLE:      tb_state_str = "Idle";
        `GLITCH_STATE_RESET:     tb_state_str = "Reset";
        `GLITCH_STATE_READ:		 tb_state_str = "Read";
        `GLITCH_STATE_DELAY:     tb_state_str = "Delay";
        `GLITCH_STATE_WIDTH:     tb_state_str = "Width";
        default:    tb_state_str = "??";
    endcase
end

endmodule
