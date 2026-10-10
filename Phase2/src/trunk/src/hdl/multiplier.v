module multiplier #(parameter WIDTH = 4) (input [WIDTH-1:0] num1, num2, output [WIDTH-1:0] out);
    wire [(2*WIDTH)-1:0] temp;
    assign temp = num1 * num2;
    // assign out = temp[(2*WIDTH)-1:WIDTH];
    assign out = temp[WIDTH-1:0];
endmodule
