`include "defines.v"

//------------------------------------------------------------------------
// ALU模块
//------------------------------------------------------------------------

module ysyx_25110270_alu
(
    input   wire                                    clk,
    input   wire                                    rst,

    input   wire    [31:0                       ]   I_alu_srca,
    input   wire    [31:0                       ]   I_alu_srcb,
    input   wire                                    I_sign,             // 有符号位
    input   wire                                    I_f7b5_en,          // 指令funct7[5] = 1
    input   wire    [3:0                        ]   I_alu_ctrl,
    output  wire    [31:0                       ]   O_alu_result,

    input   wire                                    I_mul_start,
    output  wire                                    O_mul_ready,

    input   wire                                    I_div_start,
    output  wire                                    O_div_ready,

    output  wire                                    O_eq,
    output  wire                                    O_lt
);

    wire adder_sign = I_sign;
    wire adder_sub = I_f7b5_en | (I_alu_ctrl[2:0] != 3'b000); // no add

    wire [32:0] adder_s1 = {adder_sign & I_alu_srca[31], I_alu_srca};
    wire [32:0] adder_s2 = {adder_sign & I_alu_srcb[31], I_alu_srcb} ^ {{33{adder_sub}}};

    wire [31:0] rv32i_add_res;
    wire adder_cout;

    assign {adder_cout, rv32i_add_res} = adder_s1 + adder_s2 + {{32{1'b0}}, adder_sub};

    wire [31:0] rv32i_shift_res;
    wire [31:0] rv32i_xor_res     = I_alu_srca ^ I_alu_srcb;
    wire [31:0] rv32i_or_res      = I_alu_srca | I_alu_srcb;
    wire [31:0] rv32i_and_res     = I_alu_srca & I_alu_srcb;

    wire mul_ready;
    wire div_ready;

    wire [63:0] mul_res;
    wire [63:0] div_res;

    wire [63:0] mulhsu_res_inv = ~mul_res + 1;    // mulhsu结果取反加一得到正确结果
    wire mul_unsigned = I_alu_ctrl[1:0] != 2'b01;       // !mulh

    wire is_mulhsu_neg = I_alu_ctrl[1:0] == 2'b10 && I_alu_srca[31];
    wire [31:0] mul_op1 = (I_alu_srca ^ {32{is_mulhsu_neg}}) + is_mulhsu_neg;
    wire [31:0] mul_op2 = I_alu_srcb;

    wire [31:0] rv32m_mul_res = mul_res[31:0];
    wire [31:0] rv32m_mulh_res = mul_res[63:32];
    wire [31:0] rv32m_mulhsu_res = (I_alu_srca[31]) ? mulhsu_res_inv[63:32] : mul_res[63:32];

    wire [31:0] rv32m_div_res = div_res[31:0];
    wire [31:0] rv32m_rem_res = div_res[63:32];

    reg [31:0] mul_op1_r, mul_op2_r;
    reg mul_unsigned_r, mul_start_r;

    always @(posedge clk) begin
        if(rst) begin
            mul_start_r    <= 0;
        end else begin
            mul_op1_r      <= mul_op1;
            mul_op2_r      <= mul_op2;
            mul_unsigned_r <= mul_unsigned;
            mul_start_r    <= I_mul_start;
        end
    end

    reg [31:0] res; 
    always @(*) begin
        case(I_alu_ctrl)
            4'b0000:                                // add, sub, addi, jal, jalr, lui, auipc
                res = rv32i_add_res;
            4'b0001, 4'b0101:                       // sll, srl, sra, slli, srli, srai
                res = rv32i_shift_res;
            4'b0010, 4'b0011:                       // slt, sltu, slti, sltiu
                res = {31'b0, adder_cout};
            4'b0100:                                // xor, xori
                res = rv32i_xor_res;
            4'b0110:                                // or, ori
                res = rv32i_or_res;
            4'b0111:                                // and, andi
                res = rv32i_and_res;
            4'b1000:                                // mul
                res = rv32m_mul_res;
            4'b1001, 4'b1011:                       // mulh, mulhu
                res = rv32m_mulh_res;
            4'b1010:                                // mulhsu
                res = rv32m_mulhsu_res;
            4'b1100, 4'b1101:                       // div, divu
                res = rv32m_div_res;
            4'b1110, 4'b1111:                       // rem, remu
                res = rv32m_rem_res;
            default:
                res = 0;
        endcase
    end

    ysyx_25110270_barrel_shift
    #(
        .WIDTH                  (32                                         )
    ) barrel_shift
    (
        .I_shift_src            (I_alu_srca                                 ),
        .I_shift_amt            (I_alu_srcb[4:0]                            ),
        .I_shift_right          (I_alu_ctrl[2]                              ),  // srl, srli指令右移
        .I_shift_arith          (I_f7b5_en                                  ),

        .O_shift_result         (rv32i_shift_res                            )
    );

    ysyx_25110270_Booth_Mul
    #(
        .LENGTH                 (32                                         )
    ) booth_mul
    (
        .clk                    (clk                                        ),
        .rst                    (rst                                        ),

        .start                  (mul_start_r                                ),  // mul指令开始乘法运算
        .A                      (mul_op1_r                                  ),
        .B                      (mul_op2_r                                  ),
        .U                      (mul_unsigned_r                             ),

        .P                      (mul_res                                    ),
        .done                   (mul_ready                                  )
    );

    ysyx_25110270_div div    // 除法类型，00:除法，01:无符号除法，10:取余，11:无符号取余
    (
        .clk                    (clk                                        ),
        .rst                    (rst                                        ),
        .I_op_div               (I_alu_ctrl[1:0]                            ),
        .I_opdata1              (I_alu_srca                                 ),
        .I_opdata2              (I_alu_srcb                                 ),
        .I_start                (I_div_start                                ),
        .O_result               (div_res                                    ),
        .O_ready                (div_ready                                  )
    );

    assign O_alu_result = res;
    assign O_eq = (I_alu_srca == I_alu_srcb);
    assign O_lt = adder_cout;
    assign O_mul_ready = mul_ready;
    assign O_div_ready = div_ready;
    
endmodule
    
//------------------------------------------------------------------------
// 分支判断模块
//------------------------------------------------------------------------

module ysyx_25110270_bru
(
    input   wire                                    I_src_eq,
    input   wire                                    I_src_lt,
    input   wire    [2:0]                           I_bru_ctrl,
    
    output  wire                                    O_bru_taken
);
    reg bru_taken;

    wire eq = I_src_eq;
    wire neq = ~I_src_eq;
    wire lt = I_src_lt;
    wire ge = ~I_src_lt;

    always @(*) begin
        case(I_bru_ctrl)
            `ysyx_25110270_RV32I_F3_BEQ:  bru_taken = eq;
            `ysyx_25110270_RV32I_F3_BNE:  bru_taken = neq;
            3'b011                     :  bru_taken = 1'b1;         // jal, jalr指令无条件跳转
            `ysyx_25110270_RV32I_F3_BLT:  bru_taken = lt;
            `ysyx_25110270_RV32I_F3_BLTU: bru_taken = lt;
            `ysyx_25110270_RV32I_F3_BGE:  bru_taken = ge;
            `ysyx_25110270_RV32I_F3_BGEU: bru_taken = ge;
            default:                      bru_taken = 1'b0;
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
    input   wire                        I_shift_right,     // 1: right shift   0: left shift
    input   wire                        I_shift_arith,     // 1: arithmetic    0: logical

    output  wire    [WIDTH-1:0      ]   O_shift_result
);

    wire [WIDTH-1:0] stage0, stage1, stage2, stage3, stage4;
    wire [WIDTH-1:0] data_reversed;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: reverse_gen
            assign data_reversed[i] = I_shift_src[WIDTH-1-i];
        end
    endgenerate

    wire [WIDTH-1:0] shift_src = I_shift_right ? I_shift_src : data_reversed;
    wire fill_bit = I_shift_arith ? I_shift_src[WIDTH-1] : 1'b0;

    assign stage0 = I_shift_amt[0] ? {fill_bit, shift_src[WIDTH-1:1]}     : shift_src;
    assign stage1 = I_shift_amt[1] ? {{2{fill_bit}}, stage0[WIDTH-1:2]}   : stage0;
    assign stage2 = I_shift_amt[2] ? {{4{fill_bit}}, stage1[WIDTH-1:4]}   : stage1;
    assign stage3 = I_shift_amt[3] ? {{8{fill_bit}}, stage2[WIDTH-1:8]}   : stage2;
    assign stage4 = I_shift_amt[4] ? {{16{fill_bit}}, stage3[WIDTH-1:16]} : stage3;

    wire [WIDTH-1:0] shift_result = stage4;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: output_gen
            assign O_shift_result[i] = I_shift_right ? shift_result[i] : shift_result[WIDTH-1-i];
        end
    endgenerate


    // wire [WIDTH-1:0] lstage0, lstage1, lstage2, lstage3, lstage4;
    // wire [WIDTH-1:0] rstage0, rstage1, rstage2, rstage3, rstage4;

    // assign lstage0 = I_shift_amt[0] ? {I_shift_src[WIDTH-2:0], 1'b0} : I_shift_src;
    // assign lstage1 = I_shift_amt[1] ? {lstage0[WIDTH-3:0], 2'b0}     : lstage0;
    // assign lstage2 = I_shift_amt[2] ? {lstage1[WIDTH-5:0], 4'b0}     : lstage1;
    // assign lstage3 = I_shift_amt[3] ? {lstage2[WIDTH-9:0], 8'b0}     : lstage2;
    // assign lstage4 = I_shift_amt[4] ? {lstage3[WIDTH-17:0], 16'b0}   : lstage3;

    
    // wire fill_bit = I_shift_arith ? I_shift_src[WIDTH-1] : 1'b0;
    
    // assign rstage0 = I_shift_amt[0] ? {fill_bit, I_shift_src[WIDTH-1:1]}    : I_shift_src;
    // assign rstage1 = I_shift_amt[1] ? {{2{fill_bit}}, rstage0[WIDTH-1:2]}   : rstage0;
    // assign rstage2 = I_shift_amt[2] ? {{4{fill_bit}}, rstage1[WIDTH-1:4]}   : rstage1;
    // assign rstage3 = I_shift_amt[3] ? {{8{fill_bit}}, rstage2[WIDTH-1:8]}   : rstage2;
    // assign rstage4 = I_shift_amt[4] ? {{16{fill_bit}}, rstage3[WIDTH-1:16]} : rstage3;
    
    // assign O_shift_result  = I_shift_right ? rstage4 : lstage4;

endmodule

//------------------------------------------------------------------------
// 执行CSR模块
//------------------------------------------------------------------------

module ysyx_25110270_csr_exe
(
    input   wire    [31:0                           ]   I_csr_src,
    input   wire    [31:0                           ]   I_csr_rdata,
    input   wire    [1:0                            ]   I_csr_ctrl,

    output  wire    [31:0                           ]   O_csr_wdata
);
    wire [31:0] rv_csrrw_res = I_csr_src;
    wire [31:0] rv_csrrs_res = I_csr_rdata | I_csr_src;
    wire [31:0] rv_csrrc_res = I_csr_rdata & (~I_csr_src);

    reg [31:0] csr_wdata;
    always @(*) begin
        case(I_csr_ctrl)
            2'b01:      csr_wdata = rv_csrrw_res;   // rw, rwi
            2'b10:      csr_wdata = rv_csrrs_res;   // rs, rsi
            2'b11:      csr_wdata = rv_csrrc_res;   // rc, rci
            default:    csr_wdata = 0;
        endcase
    end

    assign O_csr_wdata = csr_wdata;

endmodule