`ifdef __ICARUS__
module top_tb;
    
    reg clock;
    reg reset;

    initial begin
        clock = 0;
        forever #1 clock = ~clock;

        #10000 $finish;
    end

    initial begin
        reset = 1;
        #20 reset = 0;
    end

    top top(
        .clock(clock),
        .reset(reset)
    );


    initial
    begin
        $dumpfile("test.vcd");
        $dumpvars(0,top_tb);
    end

endmodule

`endif