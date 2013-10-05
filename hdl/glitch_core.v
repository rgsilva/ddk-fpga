`include "../hdl/glitch_defs.v"

module glitch_core(
    input wire clk,
    input wire clk_in,
    input wire en,
    input wire [7:0] mode,
    output reg clk_out
);

wire g_and 	= (clk_in & en);
wire g_or  	= (clk_in | en);
wire g_nand	= ~(clk_in & en);
wire g_xor 	= (clk_in ^ en);

always @ (clk_in or en)
begin
	clk_out <= clk_in;

	if (en)
	begin
		// Debug modes
		if (mode[7] == 1'b1)
			clk_out <= en;

		// Gates
		else if (mode[3] == 1'b1)
			clk_out <= g_nand;
		else if (mode[2] == 1'b1)
			clk_out <= g_xor;
		else if (mode[1] == 1'b1)
			clk_out <= g_or;
		else if (mode[0] == 1'b1)
			clk_out <= g_and;
	end
end

endmodule
