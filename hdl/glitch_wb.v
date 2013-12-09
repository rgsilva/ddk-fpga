`include "../hdl/glitch_defs.v"

module glitch_wb(
    input wire          clk_i,
    input wire          rst_i,
    output reg          ack_o,
    input wire [7:0]    dat_i,
    input wire [3:0]    adr_i,
    output reg [7:0]    dat_o,
    input wire          stb_i,
    input wire          we_i,
    input wire          clk_in,
    input wire          clk_gl,
    output wire         clk_out,
    output wire [5:0]	ch_out
);

// --------------------------------------------
// Channel pinout:

// 0 clk_out        -- glitch_core.clk_out
// 1 clk_in         -- glitch_core.clk_in
// 2 en             -- glitch.en
// 3 ready          -- glitch.ready
// 4 glitch_en      -- glitch_core.en
// 5 delay_en       -- glitch.delay_en

assign ch_out[0] = clk_out;
assign ch_out[1] = clk_in;

reg en;
assign ch_out[2] = en;

wire ready;
assign ch_out[3] = ready;

wire glitch_en;
assign ch_out[4] = glitch_en;

wire delay_en;
assign delay_en = (!ready && !glitch_en);
assign ch_out[5] = delay_en;

// --------------------------------------------

reg [7:0] width;
reg [15:0] delay;
reg [7:0] mode;

glitch glitchi(
    .clk_in(clk_in),
    .clk_gl(clk_gl),
    .rst(rst_i),
    .width(width),
    .delay(delay),
    .mode(mode),
    .en(en),
    .ready(ready),
    .clk_out(clk_out),
    .glitch_en(glitch_en)
);

always @ (posedge clk_i)
begin
    if(rst_i)
    begin
        en <= 1'b0;
        width <= 8'b0;
        delay <= 16'b0;
        mode <= 8'b0;
    end
    else
    begin
        en <= 1'b0;
        width <= width;
        delay <= delay;
        mode <= mode;
        ack_o <= 1'b0;
        dat_o <= 8'b0;

        if (stb_i)
        begin
            case(adr_i)
                `GLITCH_STATUS:
                begin
                    if (we_i)
                    begin
                        // Write the status
                        en <= dat_i[0];
                        ack_o <= 1'b1;
                    end
                    else
                    begin
                        // Read the status
                        dat_o[0] <= ready;
                        ack_o <= 1'b1;
                    end
                end

                `GLITCH_WIDTH:
                begin
                    if (we_i)
                    begin
                        // Write the width
                        width <= dat_i;
                        ack_o <= 1'b1;
                    end
                    else
                    begin
                        // Read the status
                        dat_o <= width;
                        ack_o <= 1'b1;
                    end
                end

                `GLITCH_DELAY_0:
                begin
                    if (we_i)
                    begin
                        // Write the delay[7:0]
                        delay[7:0] <= dat_i;
                        ack_o <= 1'b1;
                    end
                    else
                    begin
                        // Read the delay[7:0]
                        dat_o <= delay[7:0];
                        ack_o <= 1'b1;
                    end
                end

                `GLITCH_DELAY_1:
                begin
                    if (we_i)
                    begin
                        // Write the delay[15:8]
                        delay[15:8] <= dat_i;
                        ack_o <= 1'b1;
                    end
                    else
                    begin
                        // Read the delay[15:8]
                        dat_o <= delay[15:8];
                        ack_o <= 1'b1;
                    end
                end

                `GLITCH_MODE:
                begin
                    if (we_i)
                    begin
                        // Write the mode
                        mode <= dat_i;
                        ack_o <= 1'b1;
                    end
                    else
                    begin
                        // Read the mode
                        dat_o <= mode;
                        ack_o <= 1'b1;
                    end
                end
            endcase
        end
    end
end

endmodule