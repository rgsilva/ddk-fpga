`include "../hdl/glitch_defs.v"

module glitch(
    input wire          clk,
    input wire          rst,
    input wire [7:0]    width,
    input wire [15:0]   delay,
    input wire          en,
    output reg          ready,
    input wire          clk_in,
    output wire         clk_out,
	output reg			glitch_en
);

// Buffers and counters
reg [7:0]   glitch_width;
reg [7:0]   width_cnt;
reg [15:0]  glitch_delay;
reg [15:0]  delay_cnt;

// Enable and state
reg [1:0] state;

glitch_xor glitch_xori(
    .clk(clk),
    .clk_in(clk_in),
    .glitch(glitch_en),
    .clk_out(clk_out)
);

always @ (posedge clk)
begin
    if(rst)
    begin
        state <= `IDLE;
        ready <= 1'b1;
        glitch_en <= 1'b0;
        glitch_width <= 8'b0;
        width_cnt <= 8'b0;
        glitch_delay <= 16'b0;
        delay_cnt <= 16'b0;
    end
    else
    begin
        ready <= ready;
        glitch_en <= glitch_en;
        glitch_width <= glitch_width;
        width_cnt <= width_cnt;
        glitch_delay <= glitch_delay;
        delay_cnt <= delay_cnt;

        case (state)
            `IDLE:
            begin
                if (en)
                begin
                    // Prepare and go to DELAY.
                    state <= `DELAY;
                    ready <= 1'b0;

                    // Copy everything into buffers and reset counters.
                    glitch_width <= width;
                    width_cnt <= 8'b0;
                    glitch_delay <= delay;
                    delay_cnt <= 16'b0;
                end
            end

            `DELAY:
            begin
                delay_cnt <= delay_cnt + 1;

                if (delay_cnt == glitch_delay)
                begin
                    // This is the end of the delay. Go to WIDTH, enabling the
                    // glitcher in the process.
                    state <= `WIDTH;
                    glitch_en <= 1'b1;
                end
            end

            `WIDTH:
            begin
                width_cnt <= width_cnt + 1;

                if (width_cnt == glitch_width)
                begin
                    // This is the end of the glitching. Go back to IDLE while
                    // releasing the module.
                    state <= `IDLE;
                    glitch_en <= 1'b0;
                    ready <= 1'b1;
                end
            end
        endcase
    end
end

endmodule
