`include "../hdl/glitch_defs.v"

module glitch(
    input wire          clk,
    input wire          rst,
    input wire [7:0]    width,
    input wire [15:0]   delay,
    input wire [3:0]    mode,
    input wire          en,
    output wire         ready,
    input wire          clk_in,
    output wire         clk_out,
	output reg			glitch_en
);

// Buffers and counters
reg [7:0]   glitch_width;
reg [7:0]   width_cnt;
reg [15:0]  glitch_delay;
reg [15:0]  delay_cnt;
reg [3:0]   glitch_mode;

// Enable and state
reg [1:0] state;

// Ready wire
assign ready = (state == `IDLE && !en);

glitch_core glitch_corei(
    .clk(clk),
    .clk_in(clk_in),
    .en(glitch_en),
    .mode(glitch_mode),
    .clk_out(clk_out)
);

always @ (posedge clk)
begin
    if(rst)
    begin
        state <= `IDLE;
        glitch_en <= 1'b0;
        glitch_width <= 8'b0;
        width_cnt <= 8'b0;
        glitch_delay <= 16'b0;
        delay_cnt <= 16'b0;
        glitch_mode <= 4'b0;
    end
    else
    begin
        glitch_en <= glitch_en;
        glitch_width <= glitch_width;
        width_cnt <= width_cnt;
        glitch_delay <= glitch_delay;
        delay_cnt <= delay_cnt;
        glitch_mode <= glitch_mode;

        case (state)
            `IDLE:
            begin
                if (en)
                begin
                    // Copy everything into buffers and reset counters.
                    glitch_width <= width;
                    width_cnt <= 8'b0;
                    glitch_delay <= delay;
                    delay_cnt <= 16'b0;
                    glitch_mode <= mode;

                    // Change the state.
                    if (delay == 16'b0 && width == 8'b0)
                    begin
                        state <= `IDLE;
                    end
                    else if (delay == 16'b0)
                    begin
                        glitch_en <= 1'b1;
                        state <= `WIDTH;
                    end
                    else
                    begin
                        state <= `DELAY;
                    end
                end
            end

            `DELAY:
            begin
                delay_cnt <= delay_cnt + 1;

                if (delay_cnt >= glitch_delay-1)
                begin
                    // This is the end of the delay. Go to WIDTH, enabling the
                    // glitcher in the process, but only if there's something
                    // to glitch.
                    if (width == 8'b0)
                    begin
                        state <= `IDLE;
                    end
                    else
                    begin
                        state <= `WIDTH;
                        glitch_en <= 1'b1;
                    end                    
                end
            end

            `WIDTH:
            begin
                width_cnt <= width_cnt + 1;

                if (width_cnt >= glitch_width-1)
                begin
                    // This is the end of the glitching. Go back to IDLE while
                    // releasing the module.
                    state <= `IDLE;
                    glitch_en <= 1'b0;
                end
            end
        endcase
    end
end

endmodule
