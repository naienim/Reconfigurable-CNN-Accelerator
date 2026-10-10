`timescale 1ns/1ns

module tb_filter_base_counter;

    parameter WIDTH = 4;

    reg clk, rst, ld, en;
    reg [WIDTH-1:0] pin;
    reg [WIDTH-1:0] filter_size;

    wire cout;
    wire [WIDTH-1:0] pout;

    filter_base_counter #(
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .ld(ld),
        .en(en),
        .filter_size(filter_size),
        .pin(pin),
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

        $display("Test 1: Apply reset");
        rst = 1;
        #10;
        rst = 0;
        #10;
        $display("pout after reset: %d", pout);
        filter_size = 4'd2;
        en = 1;


        #10;

        #300
        $stop; 
    end

endmodule
