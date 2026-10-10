`timescale 1ns/1ns
module stride_counter #(
    parameter SCRATCH_DATA_WIDTH = 4,
    parameter SCRATCH_FILTER_WIDTH) (
    input clk, rst, ld, en, rst_stride, finish_inp,
    input [SCRATCH_DATA_WIDTH-1:0] pin, stride, inp_adr, pout_inp,
    input [SCRATCH_FILTER_WIDTH-1:0] filter_size,
    input [1:0] mode,
    output cout,
    output reg [SCRATCH_DATA_WIDTH-1:0] pout
);

    always @(posedge clk) begin
        if (rst || rst_stride)
            pout <= {SCRATCH_DATA_WIDTH{1'b0}}; 
        else begin
            if (ld)
                pout <= pin; 
            else if (en)
                pout <= pout + stride; 
        end            
    end

    wire [1:0] temp_co;
    wire [SCRATCH_DATA_WIDTH-1:0] temp_sum;
    wire [SCRATCH_DATA_WIDTH-1:0] temp_filter_size, temp_filter_size_final;
    assign temp_filter_size = {{(SCRATCH_DATA_WIDTH - SCRATCH_FILTER_WIDTH){1'b0}}, filter_size}; 
    assign temp_filter_size_final = (mode == 2'd2) ? {1'b0, temp_filter_size[SCRATCH_DATA_WIDTH-1:1]} : temp_filter_size; // ##mode2 : filter_size/2
    assign {temp_co, temp_sum} = pout + (stride - 1) + temp_filter_size_final; 
    assign cout = (((temp_co > 2'b00) || (temp_sum > pout_inp)) && finish_inp) ? 1'b1 : 1'b0; 
endmodule
