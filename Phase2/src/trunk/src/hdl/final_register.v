`timescale 1ns/1ns
module final_register #(
    parameter WIDTH = 8
) (
    input clk, 
    input rst,
    input en,
    input [WIDTH-1:0] pin,
    output reg [WIDTH-1:0] pout
);

    always @(posedge clk) begin
        if (rst)
            pout <= {WIDTH{1'b0}}; 
        else begin
            if (en)
                pout <= pin; 
        end            
    end

endmodule
