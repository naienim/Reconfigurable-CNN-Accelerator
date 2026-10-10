`define Check 2'b00
`define Write 2'b01

module controller_buf #(parameter BUFFER_SIZE = 17) (input clk, rst, write_en, read_en, can_read, can_write, input [$clog2(BUFFER_SIZE)-1:0] write_ptr, read_ptr, output reg full, empty, ready, valid);

    reg [1:0] ps=`Check, ns;
    always @(posedge clk) begin
        if(rst)
            ps <= `Check;
        else
            ps <= ns;
    end

    always @(posedge clk) begin
        // ready <= can_write;
        valid <= can_read;
        empty <= ~can_read;
    end

    always @(ps, write_en) begin
        case(ps) 
            `Check: ns = write_en ? `Write : `Check;
            `Write: ns = write_en ? `Write : `Check;
            default: ns = `Check;
        endcase
    end  

    always @(ps, can_read, can_write, write_ptr, read_ptr) begin
        {full, ready} = 3'b0;
        case(ps) 
            `Check: begin
                full = ~can_write;
                ready = can_write;
                // empty = ~can_read;
                // valid = can_read;
            end
            `Write: begin
                full = ~can_write;
                ready = can_write;
                // empty = ~can_read;
                // valid = can_read;
            end
        endcase     
    end

endmodule