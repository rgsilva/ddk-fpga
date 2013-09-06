module glitch_xor(
    input wire clk,
    input wire clk_in,
    input wire glitch,
    output reg clk_out
);

always @ (clk_in or glitch)
begin
    clk_out <= clk_in ^ glitch;
end

endmodule
