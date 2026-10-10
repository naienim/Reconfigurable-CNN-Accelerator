`define DONE_CHECK 3'b000
`define VALID_CHECK 3'b001
`define READY_CHECK 3'b010
`define WRITE 3'b011
`define FINISH 3'b100


module write_controller (clk, rst, done, ready, valid, co_write,
                        write_buf, en_w, finish_write, read_psum_buf, stall);

    input clk, rst, done, ready, valid, co_write;

    output write_buf, en_w, finish_write, read_psum_buf, stall;

    reg write_buf, en_w, finish_write, read_psum_buf, stall;

    reg [2:0] ps, ns;
    always @(posedge clk) begin
        if(rst)
            ps <= `DONE_CHECK;
        else
            ps <= ns;
    end

    always @(ps, done, ready, valid, co_write) begin
        case(ps) 
            `DONE_CHECK: ns = done ? `VALID_CHECK : `DONE_CHECK;
            `VALID_CHECK: ns = valid ? `READY_CHECK : `VALID_CHECK;
            `READY_CHECK: ns = ready ? `WRITE : `READY_CHECK;
            `WRITE: ns = co_write ? `FINISH : `VALID_CHECK;
            `FINISH: ns = done ? `FINISH : `DONE_CHECK;
            default: ns = `DONE_CHECK;
        endcase
    end     
    
    always @(ps) begin
        {write_buf, en_w, finish_write, read_psum_buf, stall} = 5'b0;
        case(ps) 
            `DONE_CHECK: ;
            `VALID_CHECK: {stall} = 1'b1;
            `READY_CHECK: {read_psum_buf, stall} = 2'b11;
            `WRITE: {en_w, write_buf} = 2'b11;
            `FINISH: finish_write = 1'b1;
        endcase     
    end

endmodule



