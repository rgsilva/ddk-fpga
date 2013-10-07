`timescale 1 ns/1 ps
`include "../hdl/glitch_defs.v"

// --------------------------------------------------------------------
// Definitions

module glitch_wb_tb();

reg	tb_clk;
reg	tb_rst;

reg tb_clk_in;
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
	tb_rst <= 1'b0;
	#5 tb_rst <= 1'b1;
	#20 tb_rst <= 1'b0;
end

always
begin
	#10 tb_clk <= ~tb_clk;
end

always
begin
	#50 tb_clk_in <= ~tb_clk_in;
end

initial
begin
	// It should start as ready.
	#1 wb_read(`GLITCH_STATUS);
	#1 if(read_data != 8'b1) $stop;

	// It should start with delay and width as 0.
	#1 wb_read(`GLITCH_DELAY_0);
	#1 if(read_data != 8'b0) $stop;
	#1 wb_read(`GLITCH_DELAY_1);
	#1 if(read_data != 8'b0) $stop;
	#1 wb_read(`GLITCH_WIDTH);
	#1 if(read_data != 8'b0) $stop;

	// Test delay read/write.
	#1 wb_write(`GLITCH_DELAY_0, 8'hAB);
	#1 wb_read(`GLITCH_DELAY_0);
	#1 if(read_data != 8'hAB) $stop;
	#1 wb_write(`GLITCH_DELAY_1, 8'hCD);
	#1 wb_read(`GLITCH_DELAY_1);
	#1 if(read_data != 8'hCD) $stop;

	// Test width read/write.
	#1 wb_write(`GLITCH_WIDTH, 8'hAF);
	#1 wb_read(`GLITCH_WIDTH);
	#1 if(read_data != 8'hAF) $stop;

	// Test mode read/write.
	#1 wb_write(`GLITCH_MODE, 8'hDC);
	#1 wb_read(`GLITCH_MODE);
	#1 if(read_data != 8'hDC) $stop;
	#1 wb_write(`GLITCH_MODE, 8'h00);

	// Setup for small test.
	#1 wb_write(`GLITCH_DELAY_0, 8'h8);
	#1 wb_write(`GLITCH_DELAY_1, 8'h0);
	#1 wb_write(`GLITCH_WIDTH, 8'h4);

	// Enabling the glitcher should block it (rdy == zero).
	#1 wb_write(`GLITCH_STATUS, 8'b1);
	#1 wb_read(`GLITCH_STATUS);
	#1 if(read_data != 8'b0) $stop;

	// After a while it should be ready again.
	#500
	begin
	 	#1 wb_read(`GLITCH_STATUS);
		#1 if(read_data != 8'b1) $stop;
	end

	// Test the glitcher without delays.
	#1 wb_write(`GLITCH_DELAY_0, 8'h0);
	#1 wb_write(`GLITCH_DELAY_1, 8'h0);
	#1 wb_write(`GLITCH_WIDTH, 8'h8);
	#1 wb_write(`GLITCH_STATUS, 8'b1);
	#1 wb_read(`GLITCH_STATUS);
	#1 if(read_data != 8'b0) $stop;
	#1 wb_wait();

	// Test the glitcher without glitching (only the delay).
	#1 wb_write(`GLITCH_DELAY_0, 8'h8);
	#1 wb_write(`GLITCH_DELAY_1, 8'h0);
	#1 wb_write(`GLITCH_WIDTH, 8'h0);
	#1 wb_write(`GLITCH_STATUS, 8'b1);
	#1 wb_read(`GLITCH_STATUS);
	#1 if(read_data != 8'b0) $stop;
	#1 wb_wait();

	// Preparation for the mode testing.
	#1 wb_write(`GLITCH_DELAY_0, 8'h4);
	#1 wb_write(`GLITCH_DELAY_1, 8'h0);
	#1 wb_write(`GLITCH_WIDTH, 8'h4);

	// Testing gates.

	// Test mode = NOTHING
	#1 wb_write(`GLITCH_MODE, `GLITCH_MODE_NOTHING);
	#1 wb_write(`GLITCH_STATUS, 8'b1);
	#1 wb_wait();

	// Test mode = AND
	#1 wb_write(`GLITCH_MODE, `GLITCH_MODE_AND);
	#1 wb_write(`GLITCH_STATUS, 8'b1);
	#1 wb_wait();

	// Test mode = OR
	#1 wb_write(`GLITCH_MODE, `GLITCH_MODE_OR);
	#1 wb_write(`GLITCH_STATUS, 8'b1);
	#1 wb_wait();

	// Test mode = NAND
	#1 wb_write(`GLITCH_MODE, `GLITCH_MODE_NAND);
	#1 wb_write(`GLITCH_STATUS, 8'b1);
	#1 wb_wait();

	// Test mode = XOR
	#1 wb_write(`GLITCH_MODE, `GLITCH_MODE_XOR);
	#1 wb_write(`GLITCH_STATUS, 8'b1);
	#1 wb_wait();

	// Testing debug modes.

	// Test mode = ENABLE
	#1 wb_write(`GLITCH_MODE, `GLITCH_MODE_ENABLE);
	#1 wb_write(`GLITCH_STATUS, 8'b1);
	#1 wb_wait();

	$display("Testbench completed successfully!");
	$stop;
end

// Create human-readable labels
reg [8*6 : 0] tb_adr_o_str;
always @ (tb_adr_o)
begin
	case (tb_adr_o)
		`GLITCH_STATUS:		tb_adr_o_str = "Status";
		`GLITCH_WIDTH:		tb_adr_o_str = "Width";
		`GLITCH_DELAY_0:	tb_adr_o_str = "Delay 0";
		`GLITCH_DELAY_1:	tb_adr_o_str = "Delay 1";
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
always @ (gi.mode)
begin
	case (gi.mode)
		`GLITCH_MODE_NOTHING:	tb_mode_str = "Nothing";
		`GLITCH_MODE_AND:		tb_mode_str = "AND";
		`GLITCH_MODE_OR: 		tb_mode_str = "OR";
		`GLITCH_MODE_NAND:		tb_mode_str = "NAND";
		`GLITCH_MODE_XOR:		tb_mode_str = "XOR";
		`GLITCH_MODE_ENABLE:	tb_mode_str = "Enable";
		default:				tb_mode_str = "??";
	endcase
end

reg [8*5 : 0] tb_state_str;
always @ (gi.glitchi.state)
begin
    case (gi.glitchi.state)
        `IDLE:      tb_state_str = "Idle";
        `DELAY:     tb_state_str = "Delay";
        `WIDTH:     tb_state_str = "Width";
        default:    tb_state_str = "??";
    endcase
end

endmodule
