`timescale 1ns/1ns

module IFMapScratchPad #(
    parameter WIDTH = 4,
    parameter SIZE = 4,
    parameter ADDR_WIDTH = $clog2(SIZE)
) (
    input clk, 
    input read_en, 
    input write_en, 
    input [ADDR_WIDTH-1:0] address_read, 
    input [ADDR_WIDTH-1:0] address_write, 
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);

    reg [WIDTH-1:0] memory [0:SIZE-1];

    // assign data_out = (read_en) ? memory[address_read] : WIDTH'bz;

    always @(posedge clk) begin
        if (write_en)
            memory[address_write] <= data_in;

        if (read_en)
            data_out <= memory[address_read];
    end
endmodule