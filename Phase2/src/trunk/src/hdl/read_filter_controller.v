`define Idle 3'b000
`define Wait 3'b001
`define Valid 3'b010
`define Write 3'b011
`define Count 3'b100
`define Done 3'b101


module read_filter_controller (clk, rst, begin_signal, co, valid, done,
                    read_en, w_en, finish_filter, read_filter_buf);

    input clk, rst, begin_signal, co, valid, done;

    output read_en, w_en, finish_filter, read_filter_buf;

    reg read_en, w_en, finish_filter, read_filter_buf;

    reg [2:0] ps, ns;
    always @(posedge clk) begin
        if(rst)
            ps <= `Idle;
        else
            ps <= ns;
    end

    always @(ps, begin_signal, co, valid, done, rst) begin
        case(ps) 
            `Idle: ns = begin_signal ? `Wait : `Idle;
            `Wait: ns = valid ? `Valid : `Wait;
            `Valid: ns = `Write;
            `Write: ns = co ? `Done : `Count;
            `Count: ns = `Wait;
            // `Done: ns = done ? `Idle : `Done;
            // `Done: ns = `Done;
            // `Done: ns = rst ? `Idle : `Done;
            `Done: ns = done ? `Idle : `Done;
            default: ns = `Idle;
        endcase
    end     
    
    always @(ps) begin
        {read_en, w_en, finish_filter, read_filter_buf} = 4'b0;
        case(ps) 
            `Idle: ;
            `Wait: ;
            `Valid: read_filter_buf = 1'b1;
            `Write: w_en = 1'b1;
            `Count: read_en = 1'b1;
            `Done: finish_filter = 1'b1;
        endcase     
    end

endmodule



