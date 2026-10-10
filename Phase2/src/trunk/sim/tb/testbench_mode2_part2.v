`timescale 1ns/1ns

module testbench_mode2_part2();

    parameter DATA_WIDTH = 16, BUFFER_SIZE= 16, W_PARAM=1 , R_PARAM=1, SIZE_IFMAP= 16, SIZE_FILTER_SRAM = 16, SIZE_PSUM= 16; 
    parameter ADDR_WIDTH_FILTER = $clog2(SIZE_FILTER_SRAM);
    parameter ADDR_WIDTH_IFMAP = $clog2(SIZE_IFMAP);


    reg clk=0,rst=1,start=0, write_en_ifmap=0, write_en_filter=0, write_en_psum=0;
    reg [1:0] mode = 2'b10;


    wire read_en_ifmap, read_en_filter, read_en_psum, valid_ifmap, valid_filter, valid_psum, write_en_out, ready, stall, done;

    wire [DATA_WIDTH-1:0] inp_ifmap, inp_filter, inp_psum, out_top;
    reg [DATA_WIDTH-1:0] inp_buf_filter, inp_buf_psum;

    reg [DATA_WIDTH+1:0] inp_buf_ifmap;
    wire [DATA_WIDTH+1:0] inp_ifmap_temp;

    reg [ADDR_WIDTH_FILTER-1:0] filter_size;

    reg [ADDR_WIDTH_IFMAP-1:0] stride;

    reg [2*DATA_WIDTH-1:0] mult;
    reg [DATA_WIDTH-1:0] mult_lsb;


    circular_buffer #(.DATA_WIDTH(DATA_WIDTH + 2), .BUFFER_SIZE(BUFFER_SIZE), .W_PARAM(W_PARAM), .R_PARAM(R_PARAM)) cb_ifmap
                        (.clk(clk), .rst(rst), .write_en(write_en_ifmap), .read_en(read_en_ifmap), .inp(inp_buf_ifmap), 
                        .full(), .empty(), .ready(), .valid(valid_ifmap), .data_out(inp_ifmap_temp));

    circular_buffer #(.DATA_WIDTH(DATA_WIDTH), .BUFFER_SIZE(BUFFER_SIZE), .W_PARAM(W_PARAM), .R_PARAM(R_PARAM)) cb_filter
                        (.clk(clk), .rst(rst), .write_en(write_en_filter), .read_en(read_en_filter), .inp(inp_buf_filter), 
                        .full(), .empty(), .ready(), .valid(valid_filter), .data_out(inp_filter));

    circular_buffer #(.DATA_WIDTH(DATA_WIDTH), .BUFFER_SIZE(BUFFER_SIZE), .W_PARAM(W_PARAM), .R_PARAM(R_PARAM)) cb_psum
                        (.clk(clk), .rst(rst), .write_en(write_en_psum), .read_en(read_en_psum), .inp(inp_buf_psum), 
                        .full(), .empty(), .ready(), .valid(valid_psum), .data_out(inp_psum));

    circular_buffer #(.DATA_WIDTH(DATA_WIDTH), .BUFFER_SIZE(BUFFER_SIZE), .W_PARAM(W_PARAM), .R_PARAM(R_PARAM)) cb_out
                        (.clk(clk), .rst(rst), .write_en(write_en_out), .read_en(), .inp(out_top), 
                        .full(), .empty(), .ready(ready), .valid(), .data_out());

    wire end_signal, start_signal;

    assign {start_signal, end_signal, inp_ifmap} = inp_ifmap_temp;

    top_wrapper #(
        .width(DATA_WIDTH),
        .SIZE_PSUM(SIZE_PSUM),
        .SIZE_IFMAP(SIZE_IFMAP),
        .SIZE_FILTER_SRAM(SIZE_FILTER_SRAM)
    ) my_top (
        .clk(clk), .rst(rst), .start(start), .ready(ready), .valid_ifmap(valid_ifmap), .valid_filter(valid_filter), .valid_psum(valid_psum), .end_signal(end_signal),
        .mode(mode),
        .filter_size(filter_size),
        .inp_buf_ifmap(inp_ifmap),
        .inp_buf_filter(inp_filter),
        .inp_buf_psum(inp_psum),
        .stride(stride),
        .out_buf(out_top),
        .read_en_filter_buf(read_en_filter), .read_en_psum_buf(read_en_psum), .read_en_ifmap_buf(read_en_ifmap), .write_en_buf(write_en_out), .stall(stall), .done_out(done)
    );

    always begin #10;clk=~clk; end

    initial begin
        #20 start=0; rst=0; write_en_ifmap=0; write_en_filter=0; write_en_psum=0;
        filter_size = 5;
        stride = 1;
        #20

        write_en_psum=1;
        inp_buf_psum = {DATA_WIDTH{1'b0}};
        #20
        inp_buf_psum = {DATA_WIDTH{1'b0}};
        #20
        inp_buf_psum = {DATA_WIDTH{1'b0}};
        #20
        inp_buf_psum = {DATA_WIDTH{1'b0}};
        #20
        inp_buf_psum = {DATA_WIDTH{1'b0}};
        #20
        inp_buf_psum = {DATA_WIDTH{1'b0}};
        #20
        inp_buf_psum = {DATA_WIDTH{1'b0}};
        #20
        inp_buf_psum = {DATA_WIDTH{1'b0}};
        #20
        inp_buf_psum = {DATA_WIDTH{1'b0}};
        #20
        inp_buf_psum = {DATA_WIDTH{1'b0}};
        #20
        inp_buf_psum = {DATA_WIDTH{1'b0}};
        #20
        inp_buf_psum = {DATA_WIDTH{1'b0}};
        #20
        write_en_psum=0;

        start = 1;
        #20
        start = 0;

        write_en_ifmap = 1;
        write_en_filter = 1;
        inp_buf_filter = 16'b1111111111010001;
        inp_buf_ifmap =  18'b100000000001011000;
        #20

        write_en_ifmap = 1;
        write_en_filter = 1;
        inp_buf_filter = 16'b0000000000001000;
        inp_buf_ifmap =  18'b000000000010010010;
        #20

        write_en_ifmap = 1;
        write_en_filter = 1;
        inp_buf_filter = 16'b1111111111010010;
        inp_buf_ifmap =  18'b000000000001001110;
        #20

        write_en_ifmap = 1;
        write_en_filter = 1;
        inp_buf_filter = 16'b1111111111100011;
        inp_buf_ifmap =  18'b001111111101111111;
        #20

        write_en_ifmap = 1;
        write_en_filter = 1;
        inp_buf_filter = 16'b0000000000000101;
        inp_buf_ifmap =  18'b001111111110000101;
        #20

        /////////////

        write_en_ifmap = 1;
        write_en_filter = 1;
        inp_buf_filter = 16'b0000000000100000;
        inp_buf_ifmap =  18'b001111111111100010;
        #20

        write_en_ifmap = 1;
        write_en_filter = 1;
        inp_buf_filter = 16'b0000000000010011;
        inp_buf_ifmap =  18'b000000000001000100;
        #20

        write_en_ifmap = 1;
        write_en_filter = 1;
        inp_buf_filter = 16'b0000000000101110;
        inp_buf_ifmap =  18'b001111111111000011;
        #20

        write_en_ifmap = 1;
        write_en_filter = 1;
        inp_buf_filter = 16'b0000000000010101;
        inp_buf_ifmap =  18'b000000000000011100;
        #20

        write_en_ifmap = 1;
        write_en_filter = 1;
        inp_buf_filter = 16'b1111111111111010;
        inp_buf_ifmap =  18'b011111111101110111;
        #20

        write_en_ifmap = 0;
        write_en_filter = 0;

        #5000
        $stop;
    end

endmodule 