module datapath #(
    parameter WIDTH = 4,
    parameter SIZE_IFMAP = 4,
    parameter SIZE_FILTER_SRAM = 4,
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

    output  [WIDTH-1:0] out
);

    wire add_co;
    wire [WIDTH-1:0] ifmap_out, filter_out, mult_out, add_out, reg_out, mid_reg_out;

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

    adder #(.WIDTH(WIDTH)) add (.num1(mult_out), .num2(reg_out), .out(add_out), .co(add_co));

    final_register #(
        .WIDTH(WIDTH)
    ) final_reg(
        .clk(clk), 
        .rst(rst | rst_reg),
        .en(en_reg),
        .pin(add_out),
        .pout(reg_out)
    );

    assign out = reg_out;
endmodule