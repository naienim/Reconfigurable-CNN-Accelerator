`timescale 1ns/1ns

module tb_read_filter_counter;

    parameter SCRATCHPAD_SIZE = 16; 
    parameter FILTER_SIZE_BIT = $clog2(SCRATCHPAD_SIZE);

    reg clk, rst, ld, en;
    reg [FILTER_SIZE_BIT-1:0] pin;
    reg [FILTER_SIZE_BIT-1:0] size_total;
    reg [FILTER_SIZE_BIT-1:0] size_filter;

    wire cout;
    wire [FILTER_SIZE_BIT-1:0] pout;

    read_filter_counter #(
        .SCRATCHPAD_SIZE(SCRATCHPAD_SIZE)
    ) uut (
        .clk(clk),
        .rst(rst),
        .ld(ld),
        .en(en),
        .pin(pin),
        .size_total(size_total),
        .size_filter(size_filter),
        .cout(cout),
        .pout(pout)
    );

    always #5 clk = ~clk; 

    initial begin
        clk = 0;
        rst = 0;
        ld = 0;
        en = 0;
        pin = 0;
        size_total = 5'd16;
        size_filter = 5'd5;

        rst = 1;
        #10;
        rst = 0;
        #10;
        pin = 4'd0; 
        ld = 1;
        #10;
        ld = 0;
        en = 1;
        #300



        $stop; 
    end

endmodule
