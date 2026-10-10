`timescale 1ns/1ns
module filter_base_counter #(parameter SCRATCH_FILTER_WIDTH = 4) (
    input clk, rst, ld, en,
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
                pout <= pout + filter_size; 
        end            
    end

    assign cout = &pout; 
endmodule
