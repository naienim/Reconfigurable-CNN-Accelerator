`timescale 1ns/1ns

module testbench_mode3();

    parameter DATA_WIDTH = 16, BUFFER_SIZE= 16, W_PARAM=1 , R_PARAM=1, SIZE_IFMAP= 16, SIZE_FILTER_SRAM = 16, SIZE_PSUM= 32; 
    parameter ADDR_WIDTH_FILTER = $clog2(SIZE_FILTER_SRAM);
    parameter ADDR_WIDTH_IFMAP = $clog2(SIZE_IFMAP);
    parameter N = 3;


    reg clk=0,rst=1,start=0, write_en_ifmap=0, write_en_filter=0, write_en_psum=0;
    reg [1:0] mode = 2'b11;


    wire write_en_out, ready, done;

    wire [DATA_WIDTH-1:0] out_top;
    reg [DATA_WIDTH-1:0] inp_buf_psum1;

    reg[N*(DATA_WIDTH) - 1:0] inp_buf_filter;
    
    reg [N*(DATA_WIDTH+2) - 1:0] inp_buf_ifmap;

    reg [ADDR_WIDTH_FILTER-1:0] filter_size;

    reg [ADDR_WIDTH_IFMAP-1:0] stride;

    reg [DATA_WIDTH-1:0] filter_mem[1:18];
    reg [DATA_WIDTH-1:0] ifmap_mem[19:48];

    final_top #(
        .N(N),
        .width(DATA_WIDTH),
        .W_PARAM(W_PARAM),
        .R_PARAM(R_PARAM),
        .SIZE_PSUM(SIZE_PSUM),
        .SIZE_IFMAP(SIZE_IFMAP),
        .BUFFER_SIZE(BUFFER_SIZE),
        .SIZE_FILTER_SRAM(SIZE_FILTER_SRAM)

    ) my_final_top (
        .clk(clk), .rst(rst), .start(start), .write_en_psum1(write_en_psum),
        .write_en_ifmap({N{write_en_ifmap}}), .write_en_filter({N{write_en_filter}}),
        .mode(mode),
        .filter_size(filter_size),
        .inp_buf_ifmap(inp_buf_ifmap),
        .inp_buf_filter(inp_buf_filter),
        .inp_buf_psum1(inp_buf_psum1),
        .stride(stride),
        .done_out(done)
    );

    wire [N*(DATA_WIDTH+2) - 1:0] temp_global_buffer_in;
    wire [N*(DATA_WIDTH+2) - 1:0] temp_global_buffer_out;

    circular_buffer #(.DATA_WIDTH(N * (DATA_WIDTH + 2)), .BUFFER_SIZE(1000), .W_PARAM(W_PARAM), .R_PARAM(R_PARAM)) global_buffer
                        (.clk(clk), .rst(rst), .write_en((write_en_ifmap | write_en_filter)), .read_en(), .inp(temp_global_buffer_in), 
                        .full(), .empty(), .ready(), .valid(), .data_out(temp_global_buffer_out));

    assign temp_global_buffer_in = write_en_ifmap ? inp_buf_ifmap : 
                                    write_en_filter ? {{(N*2){1'b0}} , inp_buf_filter} :
                                    {{(N*(DATA_WIDTH + 2)){1'b0}}};

    integer i;
    integer file;
    integer char;
    reg [DATA_WIDTH-1:0] temp;


    always begin #10;clk=~clk; end

    initial begin
        #20 start=0; rst=0; write_en_ifmap=0; write_en_filter=0; write_en_psum=0;
        filter_size = 3;
        stride = 1;
        #20

        file = $fopen("mode3.txt", "r");
        if (file == 0) begin
            $display("Error opening file");
            $stop;
        end

        char = $fgetc(file);
        while (char != "\n" && char != -1) begin
            char = $fgetc(file);
        end

        // Read filter lines (1-18)
        for (i = 1; i <= 18; i = i + 1) begin
            $fscanf(file, "%h\n", temp);
            filter_mem[i] = temp;
        end

        // Read ifmap lines (19-48)
        for (i = 19; i <= 48; i = i + 1) begin
            $fscanf(file, "%h\n", temp);
            ifmap_mem[i] = temp;
        end

        $fclose(file);

        for (i = 1; i <= 12; i = i + 1) begin
            write_en_psum=1;
            inp_buf_psum1 = {DATA_WIDTH{1'b0}};
            #20;
        end
        write_en_psum=0;

        start = 1;
        #20
        start = 0;
        
        for (i = 1; i <= 6; i = i + 1) begin
            write_en_filter = 1;
            write_en_ifmap = 0;
            inp_buf_filter = {filter_mem[i+12], filter_mem[i+6], filter_mem[i]};
            #20;
        end

        for (i = 19; i <= 27; i = i + 1) begin
            write_en_filter = 0;
            write_en_ifmap = 1;
            inp_buf_ifmap = {2'b00, ifmap_mem[i+20], 2'b00, ifmap_mem[i+10], 2'b00, ifmap_mem[i]};
            #20;
        end

        write_en_filter = 0;
        write_en_ifmap = 1;
        inp_buf_ifmap = {2'b01, ifmap_mem[48], 2'b01, ifmap_mem[38], 2'b01, ifmap_mem[28]};
        #20;
        
        write_en_filter = 0;
        write_en_ifmap = 0;

        #8000
        $stop;
    end

endmodule 