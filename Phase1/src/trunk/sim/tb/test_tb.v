`timescale 1ns/1ns

module tb_read_filter_counter;

    parameter TOTAL_WIDTH = 8;           
    parameter FILTER_SIZE_WIDTH = 4;     
    reg clk, rst, ld, en;
    reg [TOTAL_WIDTH-1:0] pin;
    reg [TOTAL_WIDTH-1:0] size_total;
    reg [FILTER_SIZE_WIDTH-1:0] size_filter;
    wire cout;
    wire [TOTAL_WIDTH-1:0] pout;

    read_filter_counter #(
        .TOTAL_WIDTH(TOTAL_WIDTH),
        .FILTER_SIZE_WIDTH(FILTER_SIZE_WIDTH)
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

    always begin
        #5 clk = ~clk;  
    end

    initial begin
        clk = 0;
        rst = 0;
        ld = 0;
        en = 0;
        pin = 8'b0;

        size_total = 8'd64;   
        size_filter = 4'd10;     
        $display("Applying reset...");
        rst = 1; #10;         
        rst = 0; #10;          
        $display("pout after reset = %d", pout);

        $display("Loading initial value...");
        pin = 8'b0;           
        ld = 1; #10;
        ld = 0; #10;
        $display("pout after load = %d", pout);

        $display("Counting...");
        en = 1;
        while (cout == 0) #10;
        en = 0;
        $display("pout = %d, cout = %b", pout, cout);

        $display("Expected result = %d", (size_total / size_filter) * size_filter);
        if (pout == (size_total / size_filter) * size_filter)
            $display("Test PASSED: Counter reached the expected maximum value.");
        else
            $display("Test FAILED: Counter did not reach the expected maximum value.");

        $stop; 
    end

endmodule
