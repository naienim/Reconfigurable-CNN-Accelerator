module top #(
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

    // main controller
    wire beginop_filter, beginop_input, done, cant_read, rst_controller, rst_filter, psum_en, co_write_counter, finish_write, sel_mux_mid, counter_write_en, rst_inp;
    

    wire rst_add_reg, en_final_reg, ifmap_read_en, ifmap_write_en, filter_read_en, filter_write_en, plus1_flag;


    wire [ADDR_WIDTH_IFMAP-1:0] ifmap_address_read, ifmap_address_write;

    wire [ADDR_WIDTH_FILTER-1:0] filter_address_read, filter_address_write;



    // read_cnt_filter
    wire read_cnt_filter_en, ld_read_cnt_filter, cout_read_cnt_filter;
    wire [ADDR_WIDTH_FILTER-1:0] pout_read_cnt_filter;

    // read_cnt_controller
    wire co_read_filter_cont, finish_filter;

    read_filter_counter #(
        .SCRATCHPAD_SIZE(SIZE_FILTER_SRAM),
        .FILTER_SIZE_BIT(ADDR_WIDTH_FILTER)
    ) read_filter_cnt (
        .clk(clk),
        .rst(rst | rst_filter),
        .ld(1'b0),
        .en(read_cnt_filter_en),
        .pin(),
        .size_total(),
        .size_filter(filter_size),
        .cout(cout_read_cnt_filter),
        .pout(pout_read_cnt_filter)
    );

    read_filter_controller read_filter_cont(
        .clk(clk),
        .rst(rst | rst_filter),
        .begin_signal(beginop_filter),
        .co(cout_read_cnt_filter),
        .valid(valid_filter),
        .done(finish_write),
        .read_en(read_cnt_filter_en),
        .w_en(filter_write_en),
        .finish_filter(finish_filter),
        .read_filter_buf(read_en_filter_buf)
    );

    // read_cnt_data
    wire read_cnt_data_en, ld_read_cnt_data, cout_read_cnt_data;
    wire [ADDR_WIDTH_IFMAP-1:0] pout_read_cnt_data;

    // read_cnt_controller
    wire co_read_data_cont, finish_inp;


    read_data_counter #(
        .SCRATCH_DATA_WIDTH(ADDR_WIDTH_IFMAP)
    ) read_data_cnt(
        .clk(clk),
        .rst(rst | rst_controller),
        .ld(1'b0),
        .en(read_cnt_data_en),
        .pin(),
        .cout(cout_read_cnt_data),
        .pout(pout_read_cnt_data)
    );

    read_data_controller read_data_cont(
        .clk(clk),
        .rst(rst | rst_controller),
        .begin_signal(beginop_input),
        .end_signal(end_signal),
        .valid(valid_ifmap),
        .done(finish_write),
        .read_en(read_cnt_data_en),
        .w_en(ifmap_write_en),
        .finish_inp(finish_inp),
        .read_data_buf(read_en_ifmap_buf)
    );

    // write_counter
    wire write_cnt_en, cout_write_cnt_data;
    wire [ADDR_WIDTH_FILTER-1:0] pout_write_cnt;

    write_counter #(
        .SCRATCH_FILTER_WIDTH(ADDR_WIDTH_FILTER),
        .SCRATCH_FILTER_SIZE(SIZE_FILTER_SRAM)
    ) write_cnt (
        .clk(clk),
        .rst(rst | rst_controller),
        .ld(1'b0),
        .en(write_cnt_en),
        .finish_filter(finish_filter),
        .pin(),
        .filter_size(filter_size),
        .cout(cout_write_cnt_data),
        .pout(pout_write_cnt)
    );

    // filter_offset_cnt
    wire en_offset, rst_offset, co_offset;
    wire [ADDR_WIDTH_FILTER-1:0] pout_offset_filter;
    wire [(2*ADDR_WIDTH_FILTER)-1:0] pout_offset_filter_temp;
    filter_offset_counter #(
        .SCRATCH_FILTER_WIDTH(ADDR_WIDTH_FILTER)
    ) filter_offset_cnt(
        .clk(clk),
        .rst(rst | rst_controller),
        .ld(1'b0),
        .en(en_offset),
        .rst_offset(rst_offset),
        .plus1_flag(plus1_flag),
        .filter_size(filter_size),
        .pin(),
        .mode(mode),
        .cout(co_offset),
        .pout(pout_offset_filter_temp)
    );

    wire co_plus1;
    wire [(2*ADDR_WIDTH_FILTER)-1:0] pout_offset_plus1;
    assign {co_plus1, pout_offset_plus1} = pout_offset_filter_temp + 1;
    assign pout_offset_filter = (plus1_flag) ? pout_offset_plus1[ADDR_WIDTH_FILTER-1:0] : pout_offset_filter_temp[ADDR_WIDTH_FILTER-1:0];

    // data_offset_cnt
    wire [ADDR_WIDTH_IFMAP-1:0] pout_offset_data;
    wire [(2*ADDR_WIDTH_IFMAP)-1:0] pout_offset_data_temp;
    filter_offset_counter #(
        .SCRATCH_FILTER_WIDTH(ADDR_WIDTH_IFMAP)
    ) data_offset_cnt(
        .clk(clk),
        .rst(rst | rst_controller),
        .ld(1'b0),
        .en(en_offset),
        .rst_offset(rst_offset),
        .filter_size(filter_size),
        .pin(),
        .cout(),
        .pout(pout_offset_data_temp)
    );
    assign pout_offset_data = pout_offset_data_temp[ADDR_WIDTH_IFMAP-1:0];

    // filter_base_cnt
    wire en_base_filter, co_base;
    wire [ADDR_WIDTH_FILTER-1:0] pout_base_filter;
    filter_base_counter #(
      .SCRATCH_FILTER_WIDTH(ADDR_WIDTH_FILTER)  
    ) filter_base_cnt(
        .clk(clk),
        .rst(rst | rst_controller),
        .ld(1'b0),
        .en(en_base_filter),
        .pin(),
        .filter_size(filter_size),
        .cout(co_base),
        .pout(pout_base_filter)
    );

    wire co_fake1, co_fake2;
    assign {co_fake1, filter_address_read} = pout_base_filter + pout_offset_filter;
    
    // stride counter
    wire en_stride, rst_stride, co_stride;
    wire [ADDR_WIDTH_IFMAP-1:0] pout_stride;
    stride_counter #(
      .SCRATCH_DATA_WIDTH(ADDR_WIDTH_IFMAP),
      .SCRATCH_FILTER_WIDTH(ADDR_WIDTH_FILTER) 
    ) ifmap_base_cnt(
        .clk(clk),
        .rst(rst | rst_controller),
        .ld(1'b0),
        .en(en_stride),
        .rst_stride(rst_stride),
        .finish_inp(finish_inp),
        .pin(),
        .stride(stride),
        .filter_size(filter_size),
        .inp_adr(),
        .pout_inp(pout_read_cnt_data),
        .mode(mode),
        .cout(co_stride),
        .pout(pout_stride)
    );
    assign {co_fake2, ifmap_address_read} = pout_stride + pout_offset_data;

    
    assign cant_read = ((filter_address_read >= pout_read_cnt_filter) && (~finish_filter)) || ((ifmap_address_read >= pout_read_cnt_data) && (~finish_inp));

    main_controller main_cont(
        .clk(clk),
        .rst(rst),
        .start(start),
        .cant_read(cant_read),
        .mode(mode),
        .ready(),
        .co_offset(co_offset),
        .co_stride(co_stride),
        .co_write(cout_write_cnt_data),
        .beginop_filter(beginop_filter),
        .beginop_input(beginop_input),
        .rst_controller(rst_controller),
        .rst_add_reg(rst_add_reg),
        .read_data(ifmap_read_en),
        .read_filter(filter_read_en),
        .en_offset(en_offset),
        .en_final_reg(en_final_reg),
        .en_stride(en_stride),
        .stall(),
        .rst_stride(rst_stride),
        .rst_offset(rst_offset),
        .write_buffer(),
        .en_write(write_cnt_en),
        .en_base_filter(en_base_filter),
        .done(done),
        .rst_filter(rst_filter),
        .psum_en(psum_en),
        .finish_write(finish_write),
        .sel_mux_mid0(sel_mux_mid0),
        .rst_input(rst_inp),
        .plus1_flag(plus1_flag)
    );

    write_controller write_cont (
        .clk(clk),
        .rst(rst), 
        .done(done), 
        .ready(ready), 
        .valid(valid_psum), 
        .co_write(co_write_counter),
        .write_buf(write_en_buf), 
        .en_w(counter_write_en), 
        .finish_write(finish_write), 
        .read_psum_buf(read_en_psum_buf),
        .stall(stall)
    );

    // -----------------------------------
    // localparam CONSTANT_WIDTH = WIDTH;
    wire [width-1:0] out_buf_temp;
    wire out_buf_temp_co;

    datapath #(
        .WIDTH(width),
        .SIZE_PSUM(SIZE_PSUM),
        .SIZE_IFMAP(SIZE_IFMAP),
        .ADDR_WIDTH_PSUM(ADDR_WIDTH_PSUM),
        .SIZE_FILTER_SRAM(SIZE_FILTER_SRAM),
        .ADDR_WIDTH_IFMAP(ADDR_WIDTH_IFMAP),
        .ADDR_WIDTH_FILTER(ADDR_WIDTH_FILTER)
    ) dp (
        .clk(clk),
        .rst(rst),
        .rst_reg(rst_add_reg),
        .en_reg(en_final_reg),
    
        .ifmap_read_en(ifmap_read_en),
        .ifmap_write_en(ifmap_write_en),

        .ifmap_address_read(ifmap_address_read), 
        .ifmap_address_write(pout_read_cnt_data),
        .ifmap_in(inp_buf_ifmap),

        .filter_read_en(filter_read_en),
        .filter_write_en(filter_write_en),
        .filter_address_read(filter_address_read), 
        .filter_address_write(pout_read_cnt_filter),
        .filter_in(inp_buf_filter),

        .psum_en(psum_en),
        .sel_mux_mid(sel_mux_mid0),
        .counter_write_en(counter_write_en),
        .psum_in(inp_buf_psum),

        .co_write_counter(co_write_counter),
        .out(out_buf_temp)
    );
    
    assign done_out = finish_write;

    assign {out_buf_temp_co, out_buf} =  out_buf_temp + inp_buf_psum;
    
endmodule