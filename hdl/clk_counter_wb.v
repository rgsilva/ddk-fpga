`include "../hdl/clk_counter_defs.v"

module clk_counter_wb(
    input wire          clk_i,
    input wire          rst_i,
    output reg          ack_o,
    input wire [7:0]    dat_i,
    input wire [3:0]    adr_i,
    output reg [7:0]    dat_o,
    input wire          stb_i,
    input wire          we_i,

    // Clock input (as baseline for the counter)
    input wire          clk_in,
    // Channel input (to read the signals from)
    input wire [5:0]    ch_in
);

wire ch_start, ch_stop;
assign ch_start = ch_in[0];
assign ch_stop = ch_in[1];

wire start, stop;

edge_detect startedge(
    .clk(clk_in),
    .async_sig(ch_start),
    .fall(start)
);

edge_detect stopedge(
    .clk(clk_in),
    .async_sig(ch_stop),
    .fall(stop)
);

wire [31:0] count;
wire state;

reg force_rst;
wire clk_counter_rst;
assign clk_counter_rst = (rst_i || force_rst);

clk_counter clk_counteri(
    .clk_in(clk_in),
    .rst(clk_counter_rst),
    .start(start),
    .stop(stop),
    .count(count),
    .state(state)
);

always @ (posedge clk_i)
begin
    if(rst_i)
    begin
        force_rst <= 1'b0;
    end
    else
    begin
        ack_o <= 1'b0;
        dat_o <= 8'b0;

        if (stb_i)
        begin
            case(adr_i)
                `COUNT_STATUS:
                begin
                    if (we_i)
                    begin
                        force_rst <= dat_i[0];
                        ack_o <= 1'b1;
                    end
                    else
                    begin
                        dat_o[0] <= clk_counter_rst;
                        ack_o <= 1'b1;
                    end
                end

                `COUNT_0:
                begin
                    begin
                        dat_o[7:0] <= count[07:00];
                        ack_o <= 1'b1;
                    end
                end

                `COUNT_1:
                begin
                    begin
                        dat_o[7:0] <= count[15:08];
                        ack_o <= 1'b1;
                    end
                end

                `COUNT_2:
                begin
                    begin
                        dat_o[7:0] <= count[23:16];
                        ack_o <= 1'b1;
                    end
                end

                `COUNT_3:
                begin
                    begin
                        dat_o[7:0] <= count[31:24];
                        ack_o <= 1'b1;
                    end
                end
            endcase
        end
    end
end

endmodule