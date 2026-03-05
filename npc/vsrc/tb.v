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

`ifdef ysyx_25110270_WAVE
    initial begin
        $dumpfile("build/waveform.vcd");
        $dumpvars(0,top_tb);
    end
`endif

    initial begin
        // #1000 $finish;
    end

endmodule

`endif
