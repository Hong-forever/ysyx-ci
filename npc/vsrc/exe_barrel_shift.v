
//------------------------------------------------------------------------
// 桶式移位模块
//------------------------------------------------------------------------

module ysyx_25110270_exe_barrel_shift 
#(
    parameter WIDTH = 32
)(
    input   wire    [WIDTH-1:0]         I_shift_src,
    input   wire    [4:0]               I_shift_amt,
    input   wire                        I_shift_left,      // 1: left shift   0: right shift
    input   wire                        I_shift_arith,     // 1: arithmetic    0: logical

    output  wire    [WIDTH-1:0]         O_shift_result
);

    wire [WIDTH-1:0] lstage0, lstage1, lstage2, lstage3, lstage4;
    wire [WIDTH-1:0] rstage0, rstage1, rstage2, rstage3, rstage4;

    assign lstage0 = I_shift_amt[0] ? {I_shift_src[WIDTH-2:0], 1'b0} : I_shift_src;
    assign lstage1 = I_shift_amt[1] ? {lstage0[WIDTH-3:0], 2'b0}     : lstage0;
    assign lstage2 = I_shift_amt[2] ? {lstage1[WIDTH-5:0], 4'b0}     : lstage1;
    assign lstage3 = I_shift_amt[3] ? {lstage2[WIDTH-9:0], 8'b0}     : lstage2;
    assign lstage4 = I_shift_amt[4] ? {lstage3[WIDTH-17:0], 16'b0}   : lstage3;

    
    // 选择输入数据
    wire fill_bit = I_shift_arith ? I_shift_src[WIDTH-1] : 1'b0;
    
    assign rstage0 = I_shift_amt[0] ? {fill_bit, I_shift_src[WIDTH-1:1]}    : I_shift_src;
    assign rstage1 = I_shift_amt[1] ? {{2{fill_bit}}, rstage0[WIDTH-1:2]}   : rstage0;
    assign rstage2 = I_shift_amt[2] ? {{4{fill_bit}}, rstage1[WIDTH-1:4]}   : rstage1;
    assign rstage3 = I_shift_amt[3] ? {{8{fill_bit}}, rstage2[WIDTH-1:8]}   : rstage2;
    assign rstage4 = I_shift_amt[4] ? {{16{fill_bit}}, rstage3[WIDTH-1:16]} : rstage3;
    
    // 输出处理
    assign O_shift_result  = I_shift_left ? lstage4 : rstage4;

endmodule
