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

reg [31:0] fifo_in;
reg fifo_we;
wire fifo_full;

wire [31:0] fifo_out;
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

glitch glitchi(
    .clk_in(clk_in),
    .clk_gl(clk_gl),
    .rst(rst_i),
    .fifo_in(fifo_out),
    .fifo_empty(fifo_empty),
    .fifo_re(fifo_re),
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
        fifo_in <= 32'b0;
    end
    else
    begin
        en <= 1'b0;
        ack_o <= 1'b0;
        dat_o <= 8'b0;

        fifo_we <= 1'b0;
        fifo_in <= fifo_in;

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
                        // Read the settings [31:24]
                        dat_o <= fifo_in[31:24];
                        ack_o <= 1'b1;
                    end
                end

            endcase
        end
    end
end

endmodule