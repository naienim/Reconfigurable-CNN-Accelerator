module circular_buffer #(parameter DATA_WIDTH = 8, parameter BUFFER_SIZE = 16, parameter W_PARAM = 4, parameter R_PARAM = 4)
                        (input clk, rst, write_en, read_en, input [DATA_WIDTH*W_PARAM-1:0] inp, 
                        output full, empty, ready, valid, output [DATA_WIDTH*R_PARAM-1:0] data_out);

    wire can_write, can_read;
    wire [DATA_WIDTH-1:0] write_ptr, read_ptr;

    buffer_fifo #(.DATA_WIDTH(DATA_WIDTH), .BUFFER_SIZE(BUFFER_SIZE+1), .W_PARAM(W_PARAM), .R_PARAM(R_PARAM)) 
            fifo (.clk(clk), .rst(rst), .w_enable(write_en), .r_enable(read_en), .inp(inp), .can_write_out(can_write),
                 .can_read_out(can_read), .write_ptr_out(write_ptr), .read_ptr_out(read_ptr), .data_out(data_out));

    controller_buf #(.BUFFER_SIZE(BUFFER_SIZE+1)) 
                cont(.clk(clk), .rst(rst), .write_en(write_en), .read_en(read_en), .write_ptr(write_ptr), .read_ptr(read_ptr),
                .can_read(can_read), .can_write(can_write), .full(full), .empty(empty), .ready(ready), .valid(valid));

endmodule