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
`define RstInp 4'b1100 
`define NewBegin 4'b1101 
`define SetFlag2 4'b1110

module main_controller (clk, rst, start, cant_read, ready, co_offset, co_stride, co_write, finish_write, mode,
                        beginop_filter, beginop_input, rst_controller, rst_add_reg, read_data, read_filter , en_offset, en_final_reg, en_stride, stall, rst_stride, rst_offset, write_buffer, en_write, en_base_filter, done, rst_filter, psum_en, sel_mux_mid0, rst_input, plus1_flag);

    input clk, rst, start, cant_read, ready, co_offset, co_stride, co_write, finish_write;

    input [1:0] mode;

    output beginop_filter, beginop_input, rst_controller, rst_add_reg, read_data, read_filter, en_offset, en_final_reg, en_stride, stall, rst_stride, rst_offset, write_buffer, en_write, en_base_filter, done, rst_filter, psum_en, sel_mux_mid0, rst_input, plus1_flag;

    reg beginop_filter, beginop_input, rst_controller, rst_add_reg, read_data, read_filter , en_offset, en_final_reg, en_stride, stall, rst_stride, rst_offset, write_buffer, en_write, en_base_filter, done, rst_filter, psum_en, sel_mux_mid0, rst_input;

    reg flag_mode1;
    reg flag_mode2;

    reg [3:0] ps, ns;
    always @(posedge clk) begin
        if(rst)
            ps <= `Idle;
        else
            ps <= ns;
    end

    always @(ps, start, cant_read, co_offset, co_stride, co_write, finish_write) begin
        case(ps) 
            `Idle: ns = start ? `Wait : `Idle;
            `Wait: ns = start ? `Wait : `BeginOp;
            `BeginOp: ns = `Check1;
            `Check1: ns = (co_write & (mode == 2'd1)  & flag_mode1) ? `RstInp :
                          co_write ? `Done :
                          cant_read ? `Check3 :
                          `Check2;
            `Check2: ns = (co_offset == 1'b1) ? `Write : 
                          (co_offset == 1'b1) ? `Write :
                          cant_read ? `Check3 :
                          `Check4;
            `Check3: ns = ~cant_read ? `Check2 : `Check3;
            `Check4: ns = `Check2;
            `Write: ns = (co_stride & mode == 2'd2 & flag_mode2) ? `SetFlag2 :
                         (co_stride) ? `EndOp :
                         (mode == 2'd2 & flag_mode2) ? `SetFlag2 : `Next;
            `SetFlag2: ns = `Check1;
            `Next: ns = `Check1;
            `EndOp: ns = `Check1;
            `RstInp: ns = `NewBegin;
            `NewBegin: ns = `Check1;
            `Done: ns = finish_write ? `Idle : `Done;
            default: ns = `Idle;
        endcase
    end     
    
    always @(ps) begin
        {beginop_filter, beginop_input, rst_controller, rst_filter, rst_add_reg, read_data, read_filter , en_offset, en_final_reg, en_stride, stall, rst_stride, rst_offset, write_buffer, en_write, en_base_filter, done, psum_en, sel_mux_mid0, rst_input} = 20'b0;
        case(ps) 
            `Idle: {flag_mode2} = 1'b1;
            `Wait: {rst_controller, rst_filter, flag_mode1, flag_mode2} = 4'b1111;
            `BeginOp: {beginop_filter, beginop_input} = 2'b11;
            `Check1: {rst_add_reg} = 1'b1;
            `Check2: {read_data, read_filter} = 2'b11;
            `Check3: ;
            `Check4: {en_offset, en_final_reg} = 2'b11;
            `Stall: {stall} = 1'b1;
            `Write: {rst_offset} = 1'b1;
            `SetFlag2: {psum_en, flag_mode2} = 2'b10;
            `Next: {en_stride, psum_en, flag_mode2} = 3'b111;
            `EndOp: {en_write, en_base_filter, rst_stride, psum_en, flag_mode2} = 5'b11111;
            `RstInp: {rst_controller} = 1'b1;
            `NewBegin: {flag_mode1, beginop_input} = 2'b01;
            `Done: {done, rst_controller, sel_mux_mid0} = 3'b111;
        endcase     
    end

    assign plus1_flag = (mode == 2'd2 & flag_mode2 == 1'b0) ? 1'b1 : 1'b0;

endmodule