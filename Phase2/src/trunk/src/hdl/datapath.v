module datapath #(
    parameter WIDTH = 4,
    parameter SIZE_PSUM = 4,
    parameter SIZE_IFMAP = 4,
    parameter SIZE_FILTER_SRAM = 4,
    parameter ADDR_WIDTH_PSUM = $clog2(SIZE_PSUM),
    parameter ADDR_WIDTH_IFMAP = $clog2(SIZE_IFMAP),
    parameter ADDR_WIDTH_FILTER = $clog2(SIZE_FILTER_SRAM)
) (
    input clk,
    input rst,
    input rst_reg,
    input en_reg,
  
    input ifmap_read_en,
    input ifmap_write_en,
    input [ADDR_WIDTH_IFMAP-1:0] ifmap_address_read, 
    input [ADDR_WIDTH_IFMAP-1:0] ifmap_address_write,
    input [WIDTH-1:0] ifmap_in,

    input filter_read_en,
    input filter_write_en,
    input [ADDR_WIDTH_FILTER-1:0] filter_address_read, 
    input [ADDR_WIDTH_FILTER-1:0] filter_address_write,
    input [WIDTH-1:0] filter_in,

    input psum_en,
    input sel_mux_mid,
    input counter_write_en,
    input [WIDTH-1:0] psum_in,

    output co_write_counter,
    output  [WIDTH-1:0] out
);

    wire add_co;
    wire [WIDTH-1:0] ifmap_out, filter_out, mult_out, add_out, reg_out, mid_reg_out, mid_mux_out;

    wire [ADDR_WIDTH_PSUM-1:0] adr_psum, adr_write, final_adr;

    IFMapScratchPad #(
        .WIDTH(WIDTH),
        .SIZE(SIZE_IFMAP),
        .ADDR_WIDTH(ADDR_WIDTH_IFMAP)
    ) ifmap_reg (
        .clk(clk), 
        .read_en(ifmap_read_en), 
        .write_en(ifmap_write_en), 
        .address_read(ifmap_address_read), 
        .address_write(ifmap_address_write), 
        .data_in(ifmap_in),
        .data_out(ifmap_out)
    );

    FilterScratchPad #(
        .WIDTH(WIDTH),
        .SIZE(SIZE_FILTER_SRAM),
        .ADDR_WIDTH(ADDR_WIDTH_FILTER)
    ) filter_sram (
        .clk(clk), 
        .read_en(filter_read_en), 
        .write_en(filter_write_en), 
        .address_read(filter_address_read), 
        .address_write(filter_address_write), 
        .data_in(filter_in),
        .data_out(filter_out)
    );

    multiplier #(.WIDTH(WIDTH)) mult (.num1(filter_out), .num2(ifmap_out), .out(mult_out));
    
    final_register #(.WIDTH(WIDTH)) mid_reg (.clk(clk), .rst(rst | rst_reg),.en(en_reg),.pin(mult_out),.pout(mid_reg_out));


    // final_register #(
    //     .WIDTH(WIDTH)
    // ) final_reg(
    //     .clk(clk), 
    //     .rst(rst | rst_reg),
    //     .en(en_reg),
    //     .pin(add_out),
    //     .pout(reg_out)
    // );

    Mux2to1 #(.WIDTH(WIDTH)) mid_mux (.a(mult_out), .b(psum_in), .sel(sel_mux_mid), .c(mid_mux_out));

    psum_counter #(
        .SCRATCHPAD_SIZE(SIZE_PSUM),
        .PSUM_SIZE_BIT(ADDR_WIDTH_PSUM)
    ) counter_psum (
        .clk(clk), .rst(rst), .ld(), .en(psum_en),
        .pin(),
        .cout(),
        .pout(adr_psum)
    );

    psum_counter #(
        .SCRATCHPAD_SIZE(SIZE_PSUM),
        .PSUM_SIZE_BIT(ADDR_WIDTH_PSUM)
    ) counter_write (
        .clk(clk), .rst(rst), .ld(), .en(counter_write_en),
        .pin(adr_psum),
        .cout(co_write_counter),
        .pout(adr_write)
    );

    assign final_adr = (sel_mux_mid == 1'b0) ? adr_psum : adr_write;

    adder #(.WIDTH(WIDTH)) add (.num1(mid_mux_out), .num2(reg_out), .out(add_out), .co(add_co));

    PSumScratchPad #(
        .WIDTH(WIDTH),
        .SIZE(SIZE_PSUM),
        .ADDR_WIDTH(ADDR_WIDTH_PSUM)
    ) psum_reg (
        .clk(clk), 
        .rst(rst | rst_reg),
        .write_en(en_reg), 
        .address(final_adr), 
        .data_in(add_out),
        .data_out(reg_out)
    );


    assign out = reg_out;
endmodule