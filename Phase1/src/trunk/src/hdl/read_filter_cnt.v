`timescale 1ns/1ns
module read_filter_counter #(
    parameter SCRATCHPAD_SIZE = 4,
    parameter FILTER_SIZE_BIT = $clog2(SCRATCHPAD_SIZE)
    ) 
    (
    input clk, rst, ld, en,
    input [FILTER_SIZE_BIT-1:0] pin,
    input [FILTER_SIZE_BIT-1:0] size_total,
    input [FILTER_SIZE_BIT-1:0] size_filter,
    output cout,
    output reg [FILTER_SIZE_BIT-1:0] pout
);

    always @(posedge clk) begin
        if (rst)
            pout <= {FILTER_SIZE_BIT{1'b0}}; 
        else begin
            if (ld)
                pout <= pin; 
            else if (en)
                pout <= pout + 1; 
        end            
    end

    reg [FILTER_SIZE_BIT-1:0] result, temp;
    always @(*) begin
        if (size_filter != 0) begin
            temp = ((SCRATCHPAD_SIZE / size_filter) * size_filter);
            result = (temp != 0) ?  temp - 1 : {FILTER_SIZE_BIT{1'b1}}; 
        end
        else
            result =  {FILTER_SIZE_BIT{1'b1}}; 
    end

    assign cout = (pout == result) ? 1 : 0; 
endmodule
