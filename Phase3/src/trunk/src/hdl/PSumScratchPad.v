// `timescale 1ns/1ns
// module PSumScartchPad #(
//     parameter WIDTH = 4,
//     parameter SIZE = 4,
//     parameter ADDR_WIDTH = $clog2(SIZE)
// ) (
//     input clk, 
//     input rst,
//     input write_en, 
//     input [ADDR_WIDTH-1:0] address, 
//     input [WIDTH-1:0] data_in,
//     output reg [WIDTH-1:0] data_out
// );

//     reg [WIDTH-1:0] memory [0:SIZE-1];

//     // assign data_out =  memory[address];

//     always @(posedge clk) begin
//         data_out <= memory[address];
//         if (write_en)
//             memory[address] <= data_in;
//     end
// endmodule

// `timescale 1ns/1ns
// module PSumScratchPad #(
//     parameter WIDTH = 4,
//     parameter SIZE = 4,
//     parameter ADDR_WIDTH = $clog2(SIZE)
// ) (
//     input clk, 
//     input rst,
//     input write_en, 
//     input [ADDR_WIDTH-1:0] address, 
//     input [WIDTH-1:0] data_in,
//     output reg [WIDTH-1:0] data_out
// );

//     integer i;
//     reg [WIDTH-1:0] memory [0:SIZE-1];

//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             for (i = 0; i < SIZE; i = i + 1) begin
//                 memory[i] <= {WIDTH{1'b0}};
//             end
//             data_out <= {WIDTH{1'b0}};
//         end 
//         else begin
//             data_out <= memory[address];
//             if (write_en)
//                 memory[address] <= data_in;
//         end
//     end
// endmodule

`timescale 1ns/1ns
module PSumScratchPad #(
    parameter WIDTH = 4,
    parameter SIZE = 4,
    parameter ADDR_WIDTH = $clog2(SIZE)
) (
    input clk, 
    input rst,
    input write_en, 
    input [ADDR_WIDTH-1:0] address, 
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);

    reg [WIDTH-1:0] memory [0:SIZE-1];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            memory[address] <= {WIDTH{1'b0}};
            data_out <= {WIDTH{1'b0}};
        end 
        else begin
            data_out <= memory[address];
            if (write_en)
                memory[address] <= data_in;
        end
    end
endmodule