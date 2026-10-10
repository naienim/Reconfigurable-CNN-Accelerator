`timescale 1ns/1ns
module filter_offset_counter #(parameter SCRATCH_FILTER_WIDTH = 4) (
    input clk, rst, ld, en, rst_offset, plus1_flag,
    input [(2*SCRATCH_FILTER_WIDTH)-1:0] pin,
    input [SCRATCH_FILTER_WIDTH-1:0] filter_size,
    input [1:0] mode,
    output cout,
    output [(2*SCRATCH_FILTER_WIDTH)-1:0] pout
);

    reg [(2*SCRATCH_FILTER_WIDTH)-1:0] pout_temp, pout_temp_plus1;

    always @(posedge clk) begin
        if (rst || rst_offset)
            pout_temp <= {(2*SCRATCH_FILTER_WIDTH){1'b0}}; 
        else begin
            if (ld)
                pout_temp <= pin; 
            else if (en & (mode == 2'd2))
                pout_temp <= pout_temp + 2; // ##mode2 : +2
            else if (en)
                pout_temp <= pout_temp + 1;

            // if (plus1_flag) 
            //     pout <= pout_temp;
            // else 
            //     pout <= pout_temp;
        end            
    end

    wire [(2*SCRATCH_FILTER_WIDTH)-1:0] temp_filter_size;
    assign temp_filter_size = {{SCRATCH_FILTER_WIDTH{1'b0}}, filter_size};
    assign cout = (pout_temp >= temp_filter_size) ? 1'b1 : 1'b0;

    assign pout = (plus1_flag) ? pout_temp : pout_temp;
endmodule
