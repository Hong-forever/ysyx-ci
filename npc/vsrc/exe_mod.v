`include "defines.v"

//------------------------------------------------------------------------
// ALU模块
//------------------------------------------------------------------------
module ysyx_25110270_alu
(
    input   wire                                    clk,
    input   wire                                    rst_n,

    input   wire    [31:0                       ]   I_alu_srca,
    input   wire    [31:0                       ]   I_alu_srcb,
    input   wire    [`ysyx_25110270_ALUCTL_BUS  ]   I_alu_ctrl,
    output  wire    [31:0                       ]   O_alu_result,

    output  wire                                    O_eq,
    output  wire                                    O_lt
);

    wire adder_sign = (I_alu_ctrl != `ysyx_25110270_ALUCTL_SLTU);
    wire adder_sub = (I_alu_ctrl != `ysyx_25110270_ALUCTL_ADD);

    wire [32:0] adder_s1 = {adder_sign & I_alu_srca[31], I_alu_srca};
    wire [32:0] adder_s2 = {adder_sign & I_alu_srcb[31], I_alu_srcb} ^ {{33{adder_sub}}};

    wire [31:0] rv32i_add_res;
    wire adder_cout;

    assign {adder_cout, rv32i_add_res} = adder_s1 + adder_s2 + {{32{1'b0}}, adder_sub};

    wire [31:0] rv32i_shift_res;
    wire [31:0] rv32i_xor_res     = I_alu_srca ^ I_alu_srcb;
    wire [31:0] rv32i_or_res      = I_alu_srca | I_alu_srcb;
    wire [31:0] rv32i_and_res     = I_alu_srca & I_alu_srcb;
    wire [31:0] rv32i_lui_res     = I_alu_srcb;
    wire [31:0] rv32i_auipc_res   = I_alu_srcb + I_alu_srca;


    reg [31:0] res; 
    always @(*) begin
        case(I_alu_ctrl)
            `ysyx_25110270_ALUCTL_ADD, `ysyx_25110270_ALUCTL_SUB:
                res = rv32i_add_res;
            `ysyx_25110270_ALUCTL_SLL, `ysyx_25110270_ALUCTL_SRL, `ysyx_25110270_ALUCTL_SRA:
                res = rv32i_shift_res;
            `ysyx_25110270_ALUCTL_SLT, `ysyx_25110270_ALUCTL_SLTU:
                res = {{32-1{1'b0}}, adder_cout};
            `ysyx_25110270_ALUCTL_XOR:
                res = rv32i_xor_res;
            `ysyx_25110270_ALUCTL_OR: 
                res = rv32i_or_res;
            `ysyx_25110270_ALUCTL_AND:
                res = rv32i_and_res;
            default:
                res = 0;
        endcase
    end

    ysyx_25110270_barrel_shift
    #(
        .WIDTH                  (32                                     )
    ) barrel_shift
    (
        .I_shift_src            (I_alu_srca                             ),
        .I_shift_amt            (I_alu_srcb[4:0]                        ),
        .I_shift_left           (I_alu_ctrl == `ysyx_25110270_ALUCTL_SLL),
        .I_shift_arith          (I_alu_ctrl == `ysyx_25110270_ALUCTL_SRA),

        .O_shift_result         (rv32i_shift_res                        )
    );

    assign O_alu_result = res;
    assign O_eq = (I_alu_srca == I_alu_srcb);
    assign O_lt = adder_cout;
    
endmodule
    
//------------------------------------------------------------------------
// 分支判断模块
//------------------------------------------------------------------------

module ysyx_25110270_bru
(
    input   wire                                    I_src_eq,
    input   wire                                    I_src_lt,
    input   wire    [`ysyx_25110270_BRUCTL_BUS  ]   I_bru_ctrl,
    
    output  wire                                    O_bru_taken
);
    reg bru_taken;

    always @(*) begin
        case(I_bru_ctrl)
            `ysyx_25110270_BRUCTL_JAL:  bru_taken = 1'b1;
            `ysyx_25110270_BRUCTL_BEQ:  bru_taken = I_src_eq;
            `ysyx_25110270_BRUCTL_BNE:  bru_taken = ~I_src_eq;
            `ysyx_25110270_BRUCTL_BLT:  bru_taken = I_src_lt;
            `ysyx_25110270_BRUCTL_BLTU: bru_taken = I_src_lt;
            `ysyx_25110270_BRUCTL_BGE:  bru_taken = ~I_src_lt;
            `ysyx_25110270_BRUCTL_BGEU: bru_taken = ~I_src_lt;
            default:                    bru_taken = 1'b0;
        endcase
    end

    assign O_bru_taken = bru_taken;


endmodule

//------------------------------------------------------------------------
// 桶式移位模块
//------------------------------------------------------------------------
module ysyx_25110270_barrel_shift 
#(
    parameter WIDTH = 32
)(
    input   wire    [WIDTH-1:0      ]   I_shift_src,
    input   wire    [4:0            ]   I_shift_amt,
    input   wire                        I_shift_left,      // 1: left shift   0: right shift
    input   wire                        I_shift_arith,     // 1: arithmetic    0: logical

    output  wire    [WIDTH-1:0      ]   O_shift_result
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

//------------------------------------------------------------------------
// 执行CSR模块
//------------------------------------------------------------------------

module ysyx_25110270_csr
(
    input   wire    [31:0                           ]   I_csr_src,
    input   wire    [31:0                           ]   I_csr_rdata,
    input   wire    [`ysyx_25110270_CSRCTL_BUS      ]   I_csr_ctrl,

    output  wire    [31:0                           ]   O_csr_wdata
);
    wire [31:0] rv_csrrw_res = I_csr_src;
    wire [31:0] rv_csrrs_res = I_csr_rdata | I_csr_src;
    wire [31:0] rv_csrrc_res = I_csr_rdata & (~I_csr_src);

    reg [31:0] csr_wdata;
    always @(*) begin
        case(I_csr_ctrl)
            `ysyx_25110270_CSRCTL_WRI:   csr_wdata = rv_csrrw_res;
            `ysyx_25110270_CSRCTL_SET:   csr_wdata = rv_csrrs_res;
            `ysyx_25110270_CSRCTL_CLR:   csr_wdata = rv_csrrc_res;
            default:                    csr_wdata = 0;
        endcase
    end

    assign O_csr_wdata = csr_wdata;

endmodule
