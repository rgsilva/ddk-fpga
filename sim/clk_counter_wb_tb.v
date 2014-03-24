`include "../hdl/clk_counter_defs.v"
`timescale 1 ns/1 ps

// --------------------------------------------------------------------
// Definitions

module clk_counter_wb_tb();

reg	tb_clk;
reg	tb_rst;

reg tb_clk_in;

reg start, stop;

reg 			tb_we_o;
reg		[7:0]	tb_dat_o;
reg		[5:2]	tb_adr_o;
reg 			tb_stb_o;
wire	[7:0]	tb_dat_i;
wire			tb_ack_i;

wire	[5:0]	tb_ch_in;
assign tb_ch_in = { 1'b0, 1'b0, 1'b0, 1'b0, stop, start };

clk_counter_wb ci(
	.clk_i(tb_clk),
	.rst_i(tb_rst),
	.dat_i(tb_dat_o),
	.adr_i(tb_adr_o),
	.dat_o(tb_dat_i),
	.stb_i(tb_stb_o),
	.we_i(tb_we_o),
	.ack_o(tb_ack_i),

	.clk_in(tb_clk_in),
	.ch_in(tb_ch_in)
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

	start <= 1'b1;
	stop <= 1'b1;

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

initial
begin
	// Wait for the reset to finish.
	#50
	begin
		
	end

	// It should start all empty.
	#1 wb_read(`COUNT_0);
	#1 if(read_data != 8'b0) $stop;
	#1 wb_read(`COUNT_1);
	#1 if(read_data != 8'b0) $stop;
	#1 wb_read(`COUNT_2);
	#1 if(read_data != 8'b0) $stop;
	#1 wb_read(`COUNT_3);
	#1 if(read_data != 8'b0) $stop;

	// Trigger the first signal.
	#1 start <= 1'b0;

	// Trigger the second signal.
	#500 stop <= 1'b0;

	// Let it run for a while.
	#500 begin

	end

	// Now reset it
	#1 wb_write(`COUNT_STATUS, 8'b1);
	#1 wb_read(`COUNT_STATUS);
	#1 if(read_data != 8'b1) $stop;

	#30 wb_write(`COUNT_STATUS, 8'b0);
	#1 wb_read(`COUNT_STATUS);
	#1 if(read_data != 8'b0) $stop;

	$display("Testbench completed successfully!");
	$stop;
end

endmodule
