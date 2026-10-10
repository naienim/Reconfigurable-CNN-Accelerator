`define Idle 3'b000
`define Wait 3'b001
`define Valid 3'b010
`define Write 3'b011
`define Count 3'b100
`define Done 3'b101


module read_data_controller (clk, rst, begin_signal, end_signal, valid, done,
                    read_en, w_en, finish_inp, read_data_buf);

    input clk, rst, begin_signal, end_signal, valid, done;

    output read_en, w_en, finish_inp, read_data_buf;

    reg read_en, w_en, finish_inp, read_data_buf;

    reg [2:0] ps, ns;
    always @(posedge clk) begin
        if(rst)
            ps <= `Idle;
        else
            ps <= ns;
    end

    always @(ps, begin_signal, end_signal, valid, done) begin
        case(ps) 
            `Idle: ns = begin_signal ? `Wait : `Idle;
            `Wait: ns = valid ? `Valid : `Wait;
            `Valid: ns = `Write;
            `Write: ns = end_signal ? `Done : `Count;
            `Count: ns = `Wait;
            `Done: ns = done ? `Idle : `Done;
            default: ns = `Idle;
        endcase
    end     
    
    always @(ps) begin
        {read_en, w_en, finish_inp, read_data_buf} = 4'b0;
        case(ps) 
            `Idle: ;
            `Wait: ;
            `Valid: read_data_buf = 1'b1;
            `Write: w_en = 1'b1;
            `Count: read_en = 1'b1;
            `Done: finish_inp = 1'b1;
        endcase     
    end

endmodule



