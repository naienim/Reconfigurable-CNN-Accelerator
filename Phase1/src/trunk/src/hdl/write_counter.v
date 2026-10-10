`timescale 1ns/1ns
module write_counter #(
    parameter SCRATCH_FILTER_SIZE = 4,
    parameter SCRATCH_FILTER_WIDTH = 4) 
    (
    input clk, rst, ld, en, finish_filter,
    input [SCRATCH_FILTER_WIDTH-1:0] pin, filter_size,
    output cout,
    output reg [SCRATCH_FILTER_WIDTH-1:0] pout
);

    always @(posedge clk) begin
        if (rst)
            pout <= {SCRATCH_FILTER_WIDTH{1'b0}}; 
        else begin
            if (ld)
                pout <= pin; 
            else if (en)
                pout <= pout + 1; 
        end            
    end
    reg [SCRATCH_FILTER_WIDTH-1:0] result;
    always @(*) begin
        if (filter_size != 0) begin
            result = (SCRATCH_FILTER_SIZE / filter_size);
        end
    end
    assign cout = ((pout == result) && finish_filter) ? 1'b1 : 1'b0; 
endmodule
