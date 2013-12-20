`include "../hdl/glitch_defs.v"

module glitch(
    input wire          clk_in,
    input wire          clk_gl,
    input wire          rst,
    input wire [31:0]   fifo_in,
    input wire          fifo_empty,
    input wire          fifo_full,
    output reg          fifo_re,
    output wire         ready,
    output wire         clk_out,
    output wire         rst_o,
    output reg          glitch_en
);

// Buffers and counters
reg [7:0]   glitch_width;
reg [7:0]   width_cnt;
reg [15:0]  glitch_delay;
reg [15:0]  delay_cnt;
reg [7:0]   glitch_mode;

// State
reg [1:0]   state;

// Ready wire
assign ready = (state == `GLITCH_STATE_IDLE);

// Some wires to make it easier to read/understand
wire [15:0] delay;
assign delay = fifo_in[31:16];
wire [7:0] width;
assign width = fifo_in[15:8];
wire [7:0] mode;
assign mode = fifo_in[7:0];

// Control registers for the reset module.
reg reset_en;

glitch_reset glitch_reseti(
    .clk_in(clk_in),
    .rst(rst),
    .en(reset_en),
    .rst_o(rst_o)
);

glitch_core glitch_corei(
    .clk_in(clk_in),
    .clk_gl(clk_gl),
    .en(glitch_en),
    .mode(glitch_mode),
    .clk_out(clk_out)
);

always @ (posedge clk_in)
begin
    if(rst)
    begin
        state <= `GLITCH_STATE_IDLE;
        glitch_en <= 1'b0;
        glitch_width <= 8'b0;
        width_cnt <= 8'b0;
        glitch_delay <= 16'b0;
        delay_cnt <= 16'b0;
        glitch_mode <= 8'b0;
    end
    else
    begin
        fifo_re <= 1'b0;
        reset_en <= 1'b0;
        glitch_en <= glitch_en;
        glitch_width <= glitch_width;
        width_cnt <= width_cnt;
        glitch_delay <= glitch_delay;
        delay_cnt <= delay_cnt;
        glitch_mode <= glitch_mode;

        case (state)
            `GLITCH_STATE_IDLE:
            begin
                if (fifo_full)
                begin
                    // Resets the external device.
                    reset_en <= 1'b1;

                    // Start reading the FIFO already.
                    fifo_re <= 1'b1;
                    state <= `GLITCH_STATE_READ;
                end
            end

            `GLITCH_STATE_READ:
            begin
                // Copy everything from the wires into buffers.
                glitch_delay <= delay;
                glitch_width <= width;
                glitch_mode <= mode;

                // Reset the counters.
                delay_cnt <= 16'b0;
                width_cnt <= 8'b0;

                // Change the state.
                if (delay == 16'b0 && width == 8'b0)
                begin
                    // There's nothing to do.

                    // If there's still something to read, go back to READ. Otherwise,
                    // go back to IDLE.
                    if (!fifo_empty)
                    begin
                        fifo_re <= 1'b1;
                        state <= `GLITCH_STATE_READ;
                    end
                    else
                    begin
                        state <= `GLITCH_STATE_IDLE;
                    end
                end
                else if (delay == 16'b0)
                begin
                    // There's no delay.
                    glitch_en <= 1'b1;
                    state <= `GLITCH_STATE_WIDTH;
                end
                else
                begin
                    state <= `GLITCH_STATE_DELAY;
                end
            end

            `GLITCH_STATE_DELAY:
            begin
                delay_cnt <= delay_cnt + 1;

                if (delay_cnt >= glitch_delay-1)
                begin
                    // This is the end of the delay. Go to WIDTH, enabling the
                    // glitcher in the process, but only if there's something
                    // to glitch.
                    if (width != 8'b0)
                    begin
                        glitch_en <= 1'b1;
                        state <= `GLITCH_STATE_WIDTH;
                    end
                    else
                    begin
                        // There's no glitch to do.

                        // If there's still something to read, go back to READ. Otherwise,
                        // go back to IDLE.
                        if (!fifo_empty)
                        begin
                            fifo_re <= 1'b1;
                            state <= `GLITCH_STATE_READ;
                        end
                        else
                        begin
                            state <= `GLITCH_STATE_IDLE;
                        end
                    end                    
                end
            end

            `GLITCH_STATE_WIDTH:
            begin
                width_cnt <= width_cnt + 1;

                if (width_cnt >= glitch_width-1)
                begin
                    // This is the end of the glitching. Release the core module.
                    glitch_en <= 1'b0;

                    // If there's still something to read, go back to READ. Otherwise,
                    // go back to IDLE.
                    if (!fifo_empty)
                    begin
                        fifo_re <= 1'b1;
                        state <= `GLITCH_STATE_READ;
                    end
                    else
                    begin
                        state <= `GLITCH_STATE_IDLE;
                    end
                end
            end
        endcase
    end
end

endmodule
