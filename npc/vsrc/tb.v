`ifdef __ICARUS__
module top_tb;
    
    reg clock;
    reg reset;

    initial begin
        clock = 0;
        forever #1 clock = ~clock;
    end

    initial begin
        reset = 1;
        #20 reset = 0;
    end

    top top(
        .clock(clock),
        .reset(reset)
    );

endmodule

`endif