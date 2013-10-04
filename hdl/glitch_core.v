`include "../hdl/glitch_defs.v"

module glitch_core(
    input wire clk,
    input wire clk_in,
    input wire en,
    input wire [3:0] mode,
    output reg clk_out
);

wire g_xor = (clk_in ^ en);
wire g_and = (clk_in & en);
wire g_or  = (clk_in | en);

always @ (clk_in or en)
begin
	if (mode[3] == 1'b1)
		clk_out <= en;
	else if (mode[2] == 1'b1)
		clk_out <= g_xor;
	else if (mode[1] == 1'b1)
		clk_out <= g_or;
	else if (mode[0] == 1'b1)
		clk_out <= g_and;
	else
		clk_out <= 1'b0;
end

endmodule
