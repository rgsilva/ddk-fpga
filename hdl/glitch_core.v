`include "../hdl/glitch_defs.v"

module glitch_core(
    input wire clk_in,
	input wire clk_gla,
	input wire clk_glb,
    input wire en,
    input wire [7:0] mode,
    output reg clk_out
);

always @ (clk_in or clk_gla or clk_glb or en)
begin
	clk_out <= clk_in;

	if (en)
	begin
		if (mode[4] == 1'b1)
			clk_out <= clk_glb;
		else if (mode[3] == 1'b1)
			clk_out <= clk_gla;
		else if (mode[2] == 1'b1)
			clk_out <= ~clk_in;
		else if (mode[1] == 1'b1)
			clk_out <= 1'b1;
		else if (mode[0] == 1'b1)
			clk_out <= 1'b0;
	end
end

endmodule
