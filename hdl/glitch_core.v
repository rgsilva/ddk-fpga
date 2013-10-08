`include "../hdl/glitch_defs.v"

module glitch_core(
	input wire clk,
    input wire clk_in,
    input wire en,
    input wire [7:0] mode,
    output reg clk_out
);

always @ (clk_in or en)
begin
	clk_out <= clk_in;

	if (en)
	begin
		if (mode[2] == 1'b1)
			clk_out <= ~clk_in;
		else if (mode[1] == 1'b1)
			clk_out <= 1'b1;
		else if (mode[0] == 1'b1)
			clk_out <= 1'b0;
	end
end

endmodule
