`define Idle 4'b0000
`define Wait 4'b0001
`define BeginOp 4'b0010
`define Check1 4'b0011
`define Check2 4'b0100
`define Check3 4'b0101
`define Check4 4'b0110
`define Stall 4'b0111 
`define Write 4'b1000
`define Next 4'b1001
`define EndOp 4'b1010
`define Done 4'b1011 

module main_controller (clk, rst, start, cant_read, ready, co_offset, co_stride, co_write,
                    beginop, rst_controller, rst_add_reg, read_data, read_filter , en_offset, en_final_reg, en_stride, stall, rst_stride, rst_offset, write_buffer, en_write, en_base_filter, done, rst_filter);

    input clk, rst, start, cant_read, ready, co_offset, co_stride, co_write;

    output beginop, rst_controller, rst_add_reg, read_data, read_filter, en_offset, en_final_reg, en_stride, stall, rst_stride, rst_offset, write_buffer, en_write, en_base_filter, done, rst_filter;

    reg beginop, rst_controller, rst_add_reg, read_data, read_filter , en_offset, en_final_reg, en_stride, stall, rst_stride, rst_offset, write_buffer, en_write, en_base_filter, done, rst_filter;

    reg [3:0] ps, ns;
    always @(posedge clk) begin
        if(rst)
            ps <= `Idle;
        else
            ps <= ns;
    end

    always @(ps, start, cant_read, ready, co_offset, co_stride, co_write) begin
        case(ps) 
            `Idle: ns = start ? `Wait : `Idle;
            `Wait: ns = start ? `Wait : `BeginOp;
            `BeginOp: ns = `Check1;
            `Check1: ns = co_write ? `Done :
                          cant_read ? `Check3 :
                          `Check2;
            `Check2: ns = (co_offset == 1'b1 && ~ready) ? `Stall : 
                          (co_offset == 1'b1 && ready) ? `Write :
                          cant_read ? `Check3 :
                          `Check4;
            `Check3: ns = ~cant_read ? `Check2 : `Check3;
            `Check4: ns = `Check2;
            `Stall: ns = ready ? `Write : `Stall;
            `Write: ns = co_stride ? `EndOp : `Next;
            `Next: ns = `Check1;
            `EndOp: ns = `Check1;
            `Done: ns = `BeginOp;
            default: ns = `Idle;
        endcase
    end     
    
    always @(ps) begin
        {beginop, rst_controller, rst_filter, rst_add_reg, read_data, read_filter , en_offset, en_final_reg, en_stride, stall, rst_stride, rst_offset, write_buffer, en_write, en_base_filter, done} = 16'b0;
        case(ps) 
            `Idle: ;
            `Wait: {rst_controller, rst_filter} = 2'b11;
            `BeginOp: {beginop} = 1'b1;
            `Check1: {rst_add_reg} = 1'b1;
            `Check2: {read_data, read_filter} = 2'b11;
            `Check3: ;
            `Check4: {en_offset, en_final_reg} = 2'b11;
            `Stall: {stall} = 1'b1;
            `Write: {rst_offset, write_buffer} = 2'b11;
            `Next: {en_stride} = 1'b1;
            `EndOp: {en_write, en_base_filter, rst_stride} = 3'b111;
            `Done: {done, rst_controller} = 2'b11;
        endcase     
    end

endmodule