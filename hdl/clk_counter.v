`include "../hdl/clk_counter_defs.v"

module clk_counter(
    input wire          clk_in,
    input wire          rst,

    input wire          start,
    input wire          stop,

    output reg          state,
    output reg [31:0]   count
);

always @ (posedge clk_in)
begin
    if(rst)
    begin
        state <= `COUNTER_IDLE;
        count <= 32'b0;
    end
    else
    begin
        state <= state;
        count <= count;

        case (state)
            `COUNTER_IDLE:
            begin
                if (start)
                begin
                    count <= 32'b0;
                    state <= `COUNTER_COUNT;
                end
            end

            `COUNTER_COUNT:
            begin
                count <= count + 1;
                if (stop)
                begin
                    state <= `COUNTER_IDLE;
                end
            end
        endcase
    end
end

endmodule
