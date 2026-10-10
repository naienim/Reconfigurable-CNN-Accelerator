module top_wrapper #(
    parameter width = 4,
    parameter SIZE_PSUM = 4,
    parameter SIZE_IFMAP = 4,
    parameter SIZE_FILTER_SRAM = 4,
    parameter ADDR_WIDTH_PSUM = $clog2(SIZE_PSUM),
    parameter ADDR_WIDTH_IFMAP = $clog2(SIZE_IFMAP),
    parameter ADDR_WIDTH_FILTER = $clog2(SIZE_FILTER_SRAM),
    parameter filter_width = $clog2(SIZE_FILTER_SRAM)
) (
    input clk, rst, start, ready, valid_ifmap, valid_filter, valid_psum, end_signal,
    input [1:0] mode,
    input [filter_width-1:0] filter_size,
    input [width-1:0] inp_buf_ifmap,
    input [width-1:0] inp_buf_filter,
    input [width-1:0] inp_buf_psum,
    input [ADDR_WIDTH_IFMAP-1:0] stride,
    output [width-1:0] out_buf,
    output read_en_filter_buf, read_en_psum_buf, read_en_ifmap_buf, write_en_buf, stall, done_out
);

    wire [filter_width-1:0] new_filter_size;
    assign new_filter_size = (mode == 2'd3 | mode == 2'd2) ? {filter_size[filter_width-2:0], 1'b0} : filter_size; // ##mode2: filter_size*2

    top #(
        .width(width),
        .SIZE_PSUM(SIZE_PSUM),
        .SIZE_IFMAP(SIZE_IFMAP),
        .SIZE_FILTER_SRAM(SIZE_FILTER_SRAM),
        .ADDR_WIDTH_PSUM(ADDR_WIDTH_PSUM),
        .ADDR_WIDTH_IFMAP(ADDR_WIDTH_IFMAP),
        .ADDR_WIDTH_FILTER(ADDR_WIDTH_FILTER),
        .filter_width(filter_width)
    ) my_top (
        .clk(clk), .rst(rst), .start(start), .ready(ready), .valid_ifmap(valid_ifmap), .valid_filter(valid_filter), .valid_psum(valid_psum), .end_signal(end_signal),
        .mode(mode),
        .filter_size(new_filter_size),
        .inp_buf_ifmap(inp_buf_ifmap),
        .inp_buf_filter(inp_buf_filter),
        .inp_buf_psum(inp_buf_psum),
        .stride(stride),
        .out_buf(out_buf),
        .read_en_filter_buf(read_en_filter_buf), 
        .read_en_psum_buf(read_en_psum_buf),
        .read_en_ifmap_buf(read_en_ifmap_buf), 
        .write_en_buf(write_en_buf), 
        .stall(stall), 
        .done_out(done_out)
    );


endmodule