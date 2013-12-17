`include "../hdl/glitch_defs.v"

module glitch_reset(
    input wire          clk_in,
    input wire          rst,
    input wire          en,
    output wire         ready,
    output wire         rst_o
);

`define DELAY_TIME 8'h0A

// State and counters
reg state;
reg [7:0] clk_cnt;

// Ready and rst_o wires
assign ready = (state == `GLITCH_RESET_IDLE && !en);
assign rst_o = ready;

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

                if (clk_cnt >= `DELAY_TIME)
                begin
                    state <= `GLITCH_RESET_IDLE;
                end
            end
        endcase
    end
end

endmodule
