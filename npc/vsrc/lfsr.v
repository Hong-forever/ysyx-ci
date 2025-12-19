`include "defines.v"

//------------------------------------------------------------------------
// 线性反馈移位寄存器
//------------------------------------------------------------------------

module lfsr
#(
    parameter WIDTH = 8
)(
    input   wire                    clk,
    input   wire                    rst_n,
    input   wire    [WIDTH-1:0]     I_seed,
    output  wire    [WIDTH-1:0]     O_random
);

    reg [WIDTH-1:0] lfsr_reg;
    wire feedback;

    assign feedback = lfsr_reg[4] ^ lfsr_reg[3] ^ lfsr_reg[2] ^ lfsr_reg[0];
    assign O_random = lfsr_reg;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            lfsr_reg <= I_seed;
        end else begin
            lfsr_reg <= {feedback, lfsr_reg[WIDTH-1:1]};
        end
    end
endmodule