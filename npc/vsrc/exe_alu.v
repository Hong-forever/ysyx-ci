`include "defines.v"

//------------------------------------------------------------------------
// 执行ALU模块
//------------------------------------------------------------------------

module ysyx_25110270_exe_alu
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire    [`RegDataBus    ]   I_alu_srca,
    input   wire    [`RegDataBus    ]   I_alu_srcb,
    input   wire    [`ALUCTL_WIDTH-1:0] I_alu_ctrl,
    output  wire    [`RegDataBus    ]   O_alu_result,

    output  wire                        O_eq,
    output  wire                        O_lt,

    input   wire                        I_mul_start,        // 开始乘法
    output  wire                        O_mul_ready,        // 乘法运算是否结束

    input   wire                        I_signed_div,       // 是否是有符号除法
    input   wire                        I_div_start,            // 开始除法
    input   wire                        I_annul,            // 是否取消
    output  wire                        O_div_ready         // 除法运算是否结束

);
    localparam MUL_CYCLE = 3'd6;


    wire adder_sign = (I_alu_ctrl != `ALUCTL_SLTU);
    wire adder_sub = (I_alu_ctrl != `ALUCTL_ADD);

    wire [`RegDataWidth:0] adder_s1 = {adder_sign & I_alu_srca[`RegDataWidth-1], I_alu_srca};
    wire [`RegDataWidth:0] adder_s2 = {adder_sign & I_alu_srcb[`RegDataWidth-1], I_alu_srcb} ^ {{`RegDataWidth+1{adder_sub}}};

    wire [`RegDataBus] rv32i_add_res;
    wire adder_cout;

    assign {adder_cout, rv32i_add_res} = adder_s1 + adder_s2 + {{`RegDataWidth{1'b0}}, adder_sub};

    wire [`RegDataBus] rv32i_shift_res;
    wire [`RegDataBus] rv32i_xor_res     = I_alu_srca ^ I_alu_srcb;
    wire [`RegDataBus] rv32i_or_res      = I_alu_srca | I_alu_srcb;
    wire [`RegDataBus] rv32i_and_res     = I_alu_srca & I_alu_srcb;
    wire [`RegDataBus] rv32i_lui_res     = I_alu_srcb;
    wire [`RegDataBus] rv32i_auipc_res   = I_alu_srcb + I_alu_srca;

    wire [`DoubleRegDataBus] mul_res;
    wire [`DoubleRegDataBus] mulh_res;
    wire [`DoubleRegDataBus] mulhsu_res;

    wire [`RegDataBus] rv32m_mul_res;
    wire [`RegDataBus] rv32m_mulhu_res;
    wire [`RegDataBus] rv32m_mulh_res;
    wire [`RegDataBus] rv32m_mulhsu_res;


    wire [`DoubleRegDataBus] div_res;
    wire [`RegDataBus] rv32m_rem_res  = div_res[`HRegDataBus];
    wire [`RegDataBus] rv32m_div_res  = div_res[`LRegDataBus];

    reg [`RegDataBus] res; 
    always @(*) begin
        case(I_alu_ctrl)
            `ALUCTL_ADD, `ALUCTL_SUB:               res = rv32i_add_res;
            `ALUCTL_SLL, `ALUCTL_SRL, `ALUCTL_SRA:  res = rv32i_shift_res;
            `ALUCTL_SLT, `ALUCTL_SLTU:              res = {{`RegDataWidth-1{1'b0}}, adder_cout};
            `ALUCTL_XOR:                            res = rv32i_xor_res;
            `ALUCTL_OR:                             res = rv32i_or_res;
            `ALUCTL_AND:                            res = rv32i_and_res;
            `ALUCTL_MUL:                            res = rv32m_mul_res;
            `ALUCTL_MULH:                           res = rv32m_mulh_res;
            `ALUCTL_MULHSU:                         res = rv32m_mulhsu_res;
            `ALUCTL_MULHU:                          res = rv32m_mulhu_res;
            `ALUCTL_DIV, `ALUCTL_DIVU:              res = rv32m_div_res;
            `ALUCTL_REM, `ALUCTL_REMU:              res = rv32m_rem_res;
            default:                                res = 0;
        endcase
    end

    ysyx_25110270_exe_barrel_shift
    #(
        .WIDTH                  (`RegDataWidth              )
    ) u_exe_barrel_shift
    (
        .I_shift_src            (I_alu_srca                 ),
        .I_shift_amt            (I_alu_srcb[4:0]            ),
        .I_shift_left           (I_alu_ctrl == `ALUCTL_SLL  ),
        .I_shift_arith          (I_alu_ctrl == `ALUCTL_SRA  ),

        .O_shift_result         (rv32i_shift_res            )
    );


    wire div_ready;
    wire mul_ready;

    wire [`DoubleRegDataBus] mulhsu_res_inverted = ~mulhsu_res + 1;

    wire [`RegDataBus] mulhsu_op1 = (I_alu_srca[`RegDataWidth-1])? ~I_alu_srca + 1 : I_alu_srca;
    wire [`RegDataBus] mulhsu_op2 = I_alu_srcb;

    assign rv32m_mul_res    = mul_res[`LRegDataBus];
    assign rv32m_mulhu_res  = mul_res[`HRegDataBus];
    assign rv32m_mulh_res   = mulh_res[`HRegDataBus];
    assign rv32m_mulhsu_res = (I_alu_srca[`RegDataWidth-1])? mulhsu_res_inverted[`HRegDataBus] : mulhsu_res[`HRegDataBus];

    ysyx_25110270_Booth_mul 
    #(
        .LENGTH                 (`RegDataWidth              ),
        .UNSINGED_BOOTH         (1'b1                       )
    ) mul_inst (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .A                      (I_alu_srca                 ),
        .B                      (I_alu_srcb                 ),
        .P                      (mul_res                    ),
        .start                  (I_mul_start                ),
        .done                   (mul_ready                  )
    );

    ysyx_25110270_Booth_mul 
    #(
        .LENGTH                 (`RegDataWidth              ),
        .UNSINGED_BOOTH         (1'b0                       )
    ) mulh_inst (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .A                      (I_alu_srca                 ),
        .B                      (I_alu_srcb                 ),
        .P                      (mulh_res                   ),
        .start                  (I_mul_start                ),
        .done                   (                           )
    );

    ysyx_25110270_Booth_mul 
    #(
        .LENGTH                 (`RegDataWidth              ),
        .UNSINGED_BOOTH         (1'b1                       )
    ) mulhsu_inst (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .A                      (mulhsu_op1                 ),
        .B                      (mulhsu_op2                 ),
        .P                      (mulhsu_res                 ),
        .start                  (I_mul_start                ),
        .done                   (                           )
    );

    ysyx_25110270_exe_div div_inst    // 除法类型，00:除法，01:无符号除法，10:取余，11:无符号取余
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .I_signed_div           (I_signed_div               ),
        .I_op_div               (I_alu_ctrl[1:0]            ),
        .I_opdata1              (I_alu_srca                 ),
        .I_opdata2              (I_alu_srcb                 ),
        .I_start                (I_div_start                ),
        .I_annul                (I_annul                    ),
        .O_result               (div_res                    ),
        .O_ready                (div_ready                  )
    );

    assign O_alu_result = res;
    assign O_eq = (I_alu_srca == I_alu_srcb);
    assign O_lt = adder_cout;
    assign O_div_ready = div_ready;
    assign O_mul_ready = mul_ready;
    
endmodule
    


