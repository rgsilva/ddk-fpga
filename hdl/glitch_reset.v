`include "../hdl/glitch_defs.v"

module glitch_reset(
    input wire          clk_in,
    input wire          rst,
    input wire          en,
    output wire         rst_o
);

`define RESET_TIME 8'h09

// State and counters
reg state;
reg [7:0] clk_cnt;

// Reset output wire (active low)
assign rst_o = (state == `GLITCH_RESET_IDLE && !en);

always @ (posedge clk_in)
begin
    if (rst)
    begin
        state <= `GLITCH_RESET_IDLE;
        clk_cnt <= 8'b0;
    end
    else
    begin
        state <= state;

        case (state)
            `GLITCH_RESET_IDLE:
            begin
                if (en)
                begin
                    state <= `GLITCH_RESET_RESET;
                    clk_cnt <= 8'b0;
                end
            end

            `GLITCH_RESET_RESET:
            begin
                clk_cnt <= clk_cnt + 1;

                if (clk_cnt >= `RESET_TIME-1)
                begin
                    state <= `GLITCH_RESET_IDLE;
                end
            end
        endcase
    end
end

endmodule
