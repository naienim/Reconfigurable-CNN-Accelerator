`timescale 1ns/1ns
module psum_counter #(
    parameter SCRATCHPAD_SIZE = 4,
    parameter PSUM_SIZE_BIT = $clog2(SCRATCHPAD_SIZE)
    )(
    input clk, rst, ld, en,
    input [PSUM_SIZE_BIT-1:0] pin,
    output cout,
    output reg [PSUM_SIZE_BIT-1:0] pout
);

    always @(posedge clk) begin
        if (rst)
            pout <= {PSUM_SIZE_BIT{1'b0}}; 
        else begin
            if (ld)
                pout <= pin; 
            else if (en)
                pout <= pout + 1; 
        end            
    end
    assign cout = (pout == pin-1) ? 1'b1 : 1'b0; 
endmodule
