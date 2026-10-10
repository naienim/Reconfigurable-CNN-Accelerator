`timescale 1ns/1ns
module filter_offset_counter #(parameter SCRATCH_FILTER_WIDTH = 4) (
    input clk, rst, ld, en, rst_offset,
    input [(2*SCRATCH_FILTER_WIDTH)-1:0] pin,
    input [SCRATCH_FILTER_WIDTH-1:0] filter_size,
    output cout,
    output reg [(2*SCRATCH_FILTER_WIDTH)-1:0] pout
);

    always @(posedge clk) begin
        if (rst || rst_offset)
            pout <= {(2*SCRATCH_FILTER_WIDTH){1'b0}}; 
        else begin
            if (ld)
                pout <= pin; 
            else if (en)
                pout <= pout + 1; 
        end            
    end

    wire [(2*SCRATCH_FILTER_WIDTH)-1:0] temp_filter_size;
    assign temp_filter_size = {{SCRATCH_FILTER_WIDTH{1'b0}}, filter_size};
    assign cout = (pout == temp_filter_size) ? 1'b1 : 1'b0; // pout == SCRATCH_FILTER_SIZE ya == filter_size ?!?!?!?!??!!
endmodule
