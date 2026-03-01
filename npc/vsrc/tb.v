`ifdef __ICARUS__
`timescale 1ns / 1ps
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


    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0,top_tb);
    end

    initial begin
        #100 $finish;
    end

endmodule

`endif