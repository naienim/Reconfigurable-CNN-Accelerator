module adder #(parameter WIDTH = 4) (input [WIDTH-1:0] num1, num2, output [WIDTH-1:0] out, output co);
    assign {co, out} = num1 + num2;
endmodule
