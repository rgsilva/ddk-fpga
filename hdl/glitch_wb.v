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
    output wire [5:0]	ch1_out,
    input wire [5:0]    ch2_in,
    output wire [5:0]   ch2_out
);

// --------------------------------------------
// Channel 1 output pinout:

// 0 clk_out        -- glitch_core.clk_out
// 1 clk_in         -- glitch_core.clk_in
// 2 en             -- glitch.en
// 3 ready          -- glitch.ready
// 4 glitch_en      -- glitch_core.en
// 5 delay_en       -- glitch.delay_en

assign ch1_out[0] = clk_out;
assign ch1_out[1] = clk_in;

wire en;
assign ch1_out[2] = en;

wire ready;
assign ch1_out[3] = ready;

wire glitch_en;
assign ch1_out[4] = glitch_en;

wire delay_en;
assign delay_en = (!ready && !glitch_en);
assign ch1_out[5] = delay_en;

// --------------------------------------------
// Channel 2 output pinout:

// 0 rst_o          -- glitch.rst_o             OUT
// 1 en_i           -- glitch.en_i              IN
// 2 board_ready    -- glitch_wb.board_ready    OUT
// 3 not used
// 4 not used
// 5 not used

wire rst_o;
assign ch2_out[0] = rst_o;

wire board_ready;
assign ch2_out[2] = board_ready;

// --------------------------------------------

reg [47:0] fifo_in;
reg fifo_we;
wire fifo_full;

wire [47:0] fifo_out;
wire fifo_re;
wire fifo_empty;

glitch_fifo fifoi(
    .WCLOCK(clk_i),
    .RCLOCK(clk_in),
    .RESET(rst_i),
    .DATA(fifo_in),
    .WE(fifo_we),
    .Q(fifo_out),
    .RE(fifo_re),
    .EMPTY(fifo_empty),
    .FULL(fifo_full)
);

edge_detect edge_detecti(
    .clk(clk_in),
    .async_sig(ch2_in[1]),
    .fall(board_ready)
);

glitch glitchi(
    .clk_in(clk_in),
    .clk_gl(clk_gl),
    .rst(rst_i),
    .fifo_in(fifo_out),
    .fifo_empty(fifo_empty),
    .fifo_full(fifo_full),
    .fifo_re(fifo_re),
    .ready(ready),
    .clk_out(clk_out),
    .rst_o(rst_o),
    .board_ready(board_ready),
    .glitch_en(glitch_en)
);

always @ (posedge clk_i)
begin
    if(rst_i)
    begin
        fifo_in <= 48'b0;
    end
    else
    begin
        ack_o <= 1'b0;
        dat_o <= 8'b0;

        fifo_we <= 1'b0;
        fifo_in <= fifo_in;

        if (stb_i)
        begin
            case(adr_i)
                `GLITCH_STATUS:
                begin
                    begin
                        // Read the status
                        dat_o[0] <= ready;
                        ack_o <= 1'b1;
                    end
                end

                `GLITCH_QUEUE_0:
                begin
                    if (we_i)
                    begin
                        // Write the settings [7:0]
                        fifo_in[7:0] <= dat_i;
                        ack_o <= 1'b1;
                    end
                    else
                    begin
                        // Read the settings [7:0]
                        dat_o <= fifo_in[7:0];
                        ack_o <= 1'b1;
                    end
                end

                `GLITCH_QUEUE_1:
                begin
                    if (we_i)
                    begin
                        // Write the settings [15:8]
                        fifo_in[15:8] <= dat_i;
                        ack_o <= 1'b1;
                    end
                    else
                    begin
                        // Read the settings [15:8]
                        dat_o <= fifo_in[15:8];
                        ack_o <= 1'b1;
                    end
                end

                `GLITCH_QUEUE_2:
                begin
                    if (we_i)
                    begin
                        // Write the settings [23:16]
                        fifo_in[23:16] <= dat_i;
                        ack_o <= 1'b1;
                    end
                    else
                    begin
                        // Read the settings [23:16]
                        dat_o <= fifo_in[23:16];
                        ack_o <= 1'b1;
                    end
                end

                `GLITCH_QUEUE_3:
                begin
                    if (we_i)
                    begin
                        // Write the settings [31:24]
                        fifo_in[31:24] <= dat_i;
                        ack_o <= 1'b1;
                    end
                    else
                    begin
                        // Read the settings [31:24]
                        dat_o <= fifo_in[31:24];
                        ack_o <= 1'b1;
                    end
                end

                `GLITCH_QUEUE_4:
                begin
                    if (we_i)
                    begin
                        // Write the settings [39:32]
                        fifo_in[39:32] <= dat_i;
                        ack_o <= 1'b1;
                    end
                    else
                    begin
                        // Read the settings [39:32]
                        dat_o <= fifo_in[39:32];
                        ack_o <= 1'b1;
                    end
                end

                `GLITCH_QUEUE_5:
                begin
                    if (we_i)
                    begin
                        // Write the settings [47:40]
                        fifo_in[47:40] <= dat_i;

                        if (!fifo_full)
                        begin
                            fifo_we <= 1'b1;
                            ack_o <= 1'b1;
                        end
                        else
                        begin
                            ack_o <= 1'b0;
                        end
                    end
                    else
                    begin
                        // Read the settings [47:40]
                        dat_o <= fifo_in[47:40];
                        ack_o <= 1'b1;
                    end
                end

                `GLITCH_FIFO_EMPTY:
                begin
                    if (!we_i)
                    begin
                        dat_o[0] <= fifo_empty;
                        ack_o <= 1'b1;
                    end
                end

                `GLITCH_FIFO_FULL:
                begin
                    if (!we_i)
                    begin
                        dat_o[0] <= fifo_full;
                        ack_o <= 1'b1;
                    end
                end
            endcase
        end
    end
end

endmodule