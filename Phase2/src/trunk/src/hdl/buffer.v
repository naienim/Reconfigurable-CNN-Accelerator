module buffer_fifo  #(parameter DATA_WIDTH = 8, parameter BUFFER_SIZE = 17, parameter W_PARAM = 4, parameter R_PARAM = 4)
                (input clk, rst, w_enable, r_enable, input [DATA_WIDTH*W_PARAM-1:0] inp, output can_write_out, can_read_out, 
                output [$clog2(BUFFER_SIZE)-1:0] write_ptr_out, read_ptr_out, output reg [DATA_WIDTH*R_PARAM-1:0] data_out);

    localparam ADDR_WIDTH = $clog2(BUFFER_SIZE);

    reg [DATA_WIDTH-1:0] buffer [0:BUFFER_SIZE-1]; 
    reg [ADDR_WIDTH-1:0] write_ptr = 0;            
    reg [ADDR_WIDTH-1:0] read_ptr = 0;
    reg [ADDR_WIDTH-1:0] read_ptr_index = 0;   
    reg can_write, can_read;

    integer i;

    always @(posedge clk) begin
        can_write = (write_ptr > read_ptr) ? (((BUFFER_SIZE - 1 - write_ptr) + read_ptr) >= W_PARAM) :
                    (write_ptr < read_ptr) ? ((read_ptr - write_ptr - 1) >= W_PARAM) : (W_PARAM <= BUFFER_SIZE-1);
        if (rst) begin
            write_ptr <= 0;
        end 
        else if (w_enable & can_write) begin
            for (i = W_PARAM; i > 0; i = i - 1) begin
                buffer[write_ptr] <= inp[((i*DATA_WIDTH)-1) -: DATA_WIDTH];
                write_ptr = ((write_ptr + 1) == BUFFER_SIZE) ? 0 : (write_ptr + 1);
            end
        end


        if (rst) begin
            read_ptr <= 0;
        end 
        else if (can_read & r_enable) begin
            for (i = R_PARAM; i > 0; i = i - 1) begin                                                                                                           
                data_out[((i*DATA_WIDTH)-1) -: DATA_WIDTH] <= buffer[read_ptr];
                read_ptr = ((read_ptr + 1) == BUFFER_SIZE) ? 0 : (read_ptr + 1);
            end
        end

        can_read =  (write_ptr > read_ptr) ? ((write_ptr - read_ptr) >= R_PARAM) :
            (write_ptr < read_ptr) ? (((BUFFER_SIZE - read_ptr) + write_ptr) >= R_PARAM) : 0;
    end

    assign read_ptr_out = read_ptr;
    assign write_ptr_out = write_ptr; 
    assign can_read_out = can_read;
    assign can_write_out = can_write;
endmodule
