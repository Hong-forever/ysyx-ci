`include "defines.v"

//------------------------------------------------------------------------
// 译码单元
//------------------------------------------------------------------------

module ysyx_25110270_decoder 
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire    [`InstBus       ]   I_inst,
    input   wire    [`InstAddrBus   ]   I_inst_addr,
    
    input   wire                        I_valid,
    output  wire                        O_ready,
    output  wire                        O_valid,
    input   wire                        I_ready,

    output  wire    [`RegAddrBus    ]   O_rs1_raddr,        //regfiles读通用寄存器1地址
    output  wire    [`RegAddrBus    ]   O_rs2_raddr,        //regfiles读通用寄存器2地址       
    output  wire    [`CSRAddrBus    ]   O_csr_raddr,        //读CSR寄存器地址

    input   wire    [`RegDataBus    ]   I_rs1_rdata,        //获取通用寄存器1地址指向的数据
    input   wire    [`RegDataBus    ]   I_rs2_rdata,        //获取通用寄存器2地址指向的数据
    input   wire    [`CSRDataBus    ]   I_csr_rdata,        //CSR寄存器输入数据

    output  wire    [`InstBus       ]   O_inst,             //指令内容
    output  wire    [`InstAddrBus   ]   O_inst_addr,        //指令地址

    output  wire    [`RegDataBus    ]   O_rs1_rdata,        //通用寄存器1数据
    output  wire    [`RegDataBus    ]   O_rs2_rdata,        //通用寄存器2数据
    output  wire    [`RegDataBus    ]   O_imm,              //立即数
    output  wire                        O_rd_we,            //写通用寄存器标志
    output  wire    [`RegAddrBus    ]   O_rd_waddr,         //写通用寄存器地址
    output  wire                        O_csr_we,           //写CSR寄存器标志
    output  wire    [`CSRAddrBus    ]   O_csr_waddr,        //写CSR寄存器地址
    output  wire    [`CSRDataBus    ]   O_csr_rdata,        //CSR寄存器数据

    output  wire    [`CSRCTL_WIDTH-1:0] O_CSRCtrl,
    output  wire    [`ALUCTL_WIDTH-1:0] O_ALUCtrl,          //ALU控制信号
    output  wire    [`BRUCTL_WIDTH-1:0] O_BRUCtrl,          //BRU控制信号
    output  wire    [`ALUSrcA_sel_width-1:0] O_ALUSrcA_sel,
    output  wire    [`ALUSrcB_sel_width-1:0] O_ALUSrcB_sel,
    output  wire    [`AGUSrc_sel_width-1:0]  O_AGUSrc_sel,
    output  wire    [`CSRSrc_sel_width-1:0]  O_CSRSrc_sel,
    
    //ls明辨
    output  wire                        O_ls_valid,         //访存有效标志
    output  wire    [`ls_diff_bus   ]   O_ls_type,          //访存类型

    //forward
    output  wire                        O_rs1_re,
    output  wire                        O_rs2_re,
    output  wire                        O_csr_re,

    // 异常
    output  wire    [`ExceptBus     ]   O_except
);
    
    //------------------------------------------------------------------------
    // 指令解码
    //------------------------------------------------------------------------
    wire [`RV32_OP_WIDTH-1:0]  opcode;
    wire [`RV32_F3_WIDTH-1:0]  funct3;
    wire [`RV32_F7_WIDTH-1:0]  funct7;
    wire [`RV32_RD_WIDTH-1:0]  rd;
    wire [`RV32_RS1_WIDTH-1:0] rs1;
    wire [`RV32_RS2_WIDTH-1:0] rs2;
    
    ysyx_25110270_RV32_Inst_Unpack inst_unpack
    (
        .I_inst                 (I_inst                     ),
        .opcode                 (opcode                     ),
        .funct3                 (funct3                     ),
        .funct7                 (funct7                     ),
        .rd                     (rd                         ),
        .rs1                    (rs1                        ),
        .rs2                    (rs2                        )
    );

    //------------------------------------------------------------------------
    // 立即数生成
    //------------------------------------------------------------------------
    wire [`RegDataBus] rv32i_i_type_imm = {{20{I_inst[31]}}, I_inst[31:20]};
    wire [`RegDataBus] rv32i_s_type_imm = {{20{I_inst[31]}}, I_inst[31:25], I_inst[11:7]};
    wire [`RegDataBus] rv32i_u_type_imm = {I_inst[31:12], 12'b0};
    wire [`RegDataBus] rv32i_b_type_imm = {{20{I_inst[31]}}, I_inst[7], I_inst[30:25], I_inst[11:8], 1'b0};
    wire [`RegDataBus] rv32i_j_type_imm = {{12{I_inst[31]}}, I_inst[19:12], I_inst[20], I_inst[30:21], 1'b0};
    wire [`RegDataBus] rv_csr_type_imm  = {27'h0, I_inst[19:15]};

    //------------------------------------------------------------------------
    // 控制信号生成
    //------------------------------------------------------------------------
    reg [`ALUSrcA_sel_width-1:0] ALUSrcA_sel;
    reg [`ALUSrcB_sel_width-1:0] ALUSrcB_sel;
    reg [`AGUSrc_sel_width-1:0 ] AGUSrc_sel;
    reg [`CSRSrc_sel_width-1:0 ] CSRSrc_sel;

    reg rs1_re, rs2_re, rd_we, csr_en, ls_valid;

    reg [`RegDataBus] imm;

    reg [`ls_diff_bus     ] ls_type;
    reg [`ALUCTL_WIDTH-1:0] alu_ctrl;
    reg [`CSRCTL_WIDTH-1:0] csr_ctrl;
    reg [`BRUCTL_WIDTH-1:0] bru_ctrl;

    always @(*) begin
        rs1_re   = 0;
        rs2_re   = 0;
        rd_we    = 0;
        csr_en   = 0;
        ls_valid = 0;
        imm      = 0;
        ls_type  = 0;
        alu_ctrl = 0;
        bru_ctrl = 0;
        csr_ctrl = 0;
        ALUSrcA_sel = 0;
        ALUSrcB_sel = 0;
        AGUSrc_sel  = 0;
        CSRSrc_sel  = 0;
        case(opcode)
            `RV32I_OP_TYPE_IL: begin
                rs1_re   = 1;
                rd_we    = 1;
                ls_valid = 1;
                imm      = rv32i_i_type_imm;
                AGUSrc_sel = `AGUSrc_rs1;
                case(funct3)
                    `RV32I_F3_LB:  ls_type = `ls_lb;
                    `RV32I_F3_LH:  ls_type = `ls_lh;
                    `RV32I_F3_LW:  ls_type = `ls_lw;
                    `RV32I_F3_LBU: ls_type = `ls_lbu;
                    `RV32I_F3_LHU: ls_type = `ls_lhu;
                    default:       begin end
                endcase
            end
            `RV32I_OP_TYPE_I: begin
                rs1_re = 1;
                rd_we  = 1;
                imm    = rv32i_i_type_imm;
                ALUSrcA_sel = `ALUSrcA_rs1;
                ALUSrcB_sel = `ALUSrcB_imm;
                case(funct3)
                    `RV32I_F3_ADDI:  alu_ctrl = `ALUCTL_ADD;
                    `RV32I_F3_SLLI:  alu_ctrl = `ALUCTL_SLL;
                    `RV32I_F3_SLTI:  alu_ctrl = `ALUCTL_SLT;
                    `RV32I_F3_SLTIU: alu_ctrl = `ALUCTL_SLTU;
                    `RV32I_F3_XORI:  alu_ctrl = `ALUCTL_XOR;
                    `RV32I_F3_SRI:   alu_ctrl = I_inst[30]? `ALUCTL_SRA : `ALUCTL_SRL;
                    `RV32I_F3_ORI:   alu_ctrl = `ALUCTL_OR;
                    `RV32I_F3_ANDI:  alu_ctrl = `ALUCTL_AND;
                    default:         begin end
                endcase
            end
            `RV32I_OP_AUIPC: begin
                rd_we    = 1'b1;
                alu_ctrl = `ALUCTL_ADD;
                imm      = rv32i_u_type_imm;
                ALUSrcA_sel = `ALUSrcA_pc;
                ALUSrcB_sel = `ALUSrcB_imm;
            end
            `RV32I_OP_LUI: begin
                rd_we    = 1'b1;
                alu_ctrl = `ALUCTL_ADD;
                imm      = rv32i_u_type_imm;
                ALUSrcA_sel = `ALUSrcA_0;
                ALUSrcB_sel = `ALUSrcB_imm;
            end
            `RV32I_OP_TYPE_S: begin
                rs1_re   = 1;
                rs2_re   = 1;
                ls_valid = 1;
                imm      = rv32i_s_type_imm;
                AGUSrc_sel = `AGUSrc_rs1;
                case(funct3)
                    `RV32I_F3_SB: ls_type = `ls_sb;
                    `RV32I_F3_SH: ls_type = `ls_sh;
                    `RV32I_F3_SW: ls_type = `ls_sw;
                    default:      begin end
                endcase
            end
            `RV32IM_OP_TYPE_R: begin
                rs1_re = 1;
                rs2_re = 1;
                rd_we  = 1;
                ALUSrcA_sel = `ALUSrcA_rs1;
                ALUSrcB_sel = `ALUSrcB_rs2;
                case(funct3)
                    `RV32I_F3_ADD_SUB: alu_ctrl = I_inst[30]? `ALUCTL_SUB : `ALUCTL_ADD;
                    `RV32I_F3_SLL:     alu_ctrl = `ALUCTL_SLL;
                    `RV32I_F3_SLT:     alu_ctrl = `ALUCTL_SLT;
                    `RV32I_F3_SLTU:    alu_ctrl = `ALUCTL_SLTU;
                    `RV32I_F3_XOR:     alu_ctrl = `ALUCTL_XOR;
                    `RV32I_F3_SR:      alu_ctrl = I_inst[30]? `ALUCTL_SRA : `ALUCTL_SRL;
                    `RV32I_F3_OR:      alu_ctrl = `ALUCTL_OR;
                    `RV32I_F3_AND:     alu_ctrl = `ALUCTL_AND;
                    default:           begin end
                endcase
            end
            `RV32I_OP_TYPE_B: begin
                rs1_re = 1;
                rs2_re = 1;
                imm    = rv32i_b_type_imm;
                ALUSrcA_sel = `ALUSrcA_rs1;
                ALUSrcB_sel = `ALUSrcB_rs2;
                AGUSrc_sel  = `AGUSrc_pc;
                case(funct3)
                    `RV32I_F3_BEQ: begin
                        alu_ctrl = `ALUCTL_SLT;
                        bru_ctrl = `BRUCTL_BEQ;
                    end
                    `RV32I_F3_BNE: begin
                        alu_ctrl = `ALUCTL_SLT;
                        bru_ctrl = `BRUCTL_BNE;
                    end
                    `RV32I_F3_BLT: begin 
                        alu_ctrl = `ALUCTL_SLT;
                        bru_ctrl = `BRUCTL_BLT;
                    end
                    `RV32I_F3_BGE: begin
                        alu_ctrl = `ALUCTL_SLT;
                        bru_ctrl = `BRUCTL_BGE;
                    end
                    `RV32I_F3_BLTU: begin
                        alu_ctrl = `ALUCTL_SLTU;
                        bru_ctrl = `BRUCTL_BLTU;
                    end
                    `RV32I_F3_BGEU: begin
                        alu_ctrl = `ALUCTL_SLTU;
                        bru_ctrl = `BRUCTL_BGEU;
                    end
                    default: begin end
                endcase
            end
            `RV32I_OP_JALR: begin
                rs1_re   = 1;
                rd_we    = 1;
                alu_ctrl = `ALUCTL_ADD;
                bru_ctrl = `BRUCTL_JAL;
                imm      = rv32i_i_type_imm;
                ALUSrcA_sel = `ALUSrcA_pc;
                ALUSrcB_sel = `ALUSrcB_4;
                AGUSrc_sel  = `AGUSrc_rs1;
            end
            `RV32I_OP_JAL: begin
                rs1_re   = 1;
                rd_we    = 1;
                alu_ctrl = `ALUCTL_ADD;
                bru_ctrl = `BRUCTL_JAL;
                imm      = rv32i_j_type_imm;
                ALUSrcA_sel = `ALUSrcA_pc;
                ALUSrcB_sel = `ALUSrcB_4;
                AGUSrc_sel  = `AGUSrc_pc;
            end
            `RV_OP_CSR: begin
                rd_we  = 1;
                csr_en = 1;
                imm    = rv_csr_type_imm;
                case(funct3)
                    `RV_F3_CSRRW: begin
                        rs1_re   = 1;
                        csr_ctrl = `CSRCTL_WRI;
                        CSRSrc_sel = `CSRSrc_rs1;
                    end
                    `RV_F3_CSRRS: begin
                        rs1_re   = 1;
                        csr_ctrl = `CSRCTL_SET;
                        CSRSrc_sel = `CSRSrc_rs1;
                    end
                    `RV_F3_CSRRC: begin
                        rs1_re   = 1;
                        csr_ctrl = `CSRCTL_CLR;
                        CSRSrc_sel = `CSRSrc_rs1;
                    end
                    `RV_F3_CSRRWI: begin
                        csr_ctrl = `CSRCTL_WRI;
                        CSRSrc_sel = `CSRSrc_imm;
                    end
                    `RV_F3_CSRRSI: begin
                        csr_ctrl = `CSRCTL_SET;
                        CSRSrc_sel = `CSRSrc_imm;
                    end
                    `RV_F3_CSRRCI: begin
                        csr_ctrl = `CSRCTL_CLR;
                        CSRSrc_sel = `CSRSrc_imm;
                    end
                    default:       begin end
                endcase
            end
            default: begin end
        endcase
    end

    reg inst_valid;
    reg ready;

    always @(posedge clk) begin
        if(!rst_n) begin
            inst_valid <= 1'b0;
        end else if(I_ready & inst_valid) begin
            inst_valid <= 1'b0;
        end else if(I_valid) begin
            inst_valid <= 1'b1;
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            ready <= 1'b1;
        end else if(I_valid) begin
            ready <= 1'b0;
        end else begin
            ready <= 1'b1;
        end
    end

    //------------------------------------------------------------------------
    // 异常解码
    //------------------------------------------------------------------------
    wire [`ExceptBus ] except;
    ysyx_25110270_dec_except dec_except
    (
        .I_inst                 (I_inst                     ),
        .O_except               (except                     )
    );

    assign O_except = except;

    //------------------------------------------------------------------------
    // 输出
    //------------------------------------------------------------------------
    assign O_inst = I_inst;
    assign O_inst_addr = I_inst_addr;
    
    assign O_ready = ready;
    assign O_valid = inst_valid;

    assign O_rs1_raddr = rs1;
    assign O_rs2_raddr = rs2;
    assign O_rs1_rdata = I_rs1_rdata;
    assign O_rs2_rdata = I_rs2_rdata;
    assign O_imm = imm;
    assign O_rd_we = rd_we;
    assign O_rd_waddr = rd;
    assign O_ALUCtrl = alu_ctrl;
    assign O_CSRCtrl = csr_ctrl;
    assign O_BRUCtrl = bru_ctrl;
    assign O_ls_valid = ls_valid;
    assign O_ls_type = ls_type;
    assign O_csr_raddr = I_inst[31:20];
    assign O_csr_rdata = I_csr_rdata;
    assign O_csr_we = csr_en;
    assign O_csr_waddr = I_inst[31:20];

    assign O_rs1_re = rs1_re;
    assign O_rs2_re = rs2_re;
    assign O_csr_re = csr_en;

    assign O_ALUSrcA_sel = ALUSrcA_sel;
    assign O_ALUSrcB_sel = ALUSrcB_sel;
    assign O_AGUSrc_sel  = AGUSrc_sel;
    assign O_CSRSrc_sel  = CSRSrc_sel;

`ifdef PERF
    import "DPI-C" function void decoder_inst_type_cal(input int inst_type, input int pc);

    wire inst_is_ls = (ls_type != 0);
    wire inst_is_br = (bru_ctrl != 0);
    wire inst_is_alu = (opcode == `RV32I_OP_TYPE_I) | (opcode == `RV32I_OP_AUIPC) | (opcode == `RV32I_OP_LUI) | (opcode == `RV32IM_OP_TYPE_R);
    wire inst_is_csr = (csr_en != 0);
    wire inst_is_fence_i = except[`EXCPT_FENCE_I];

    wire [4:0] inst_type = {inst_is_fence_i, inst_is_csr, inst_is_br, inst_is_ls, inst_is_alu};
    
    reg valid;
    always @(posedge clk) begin
        if(!rst_n) begin
            valid <= 1'b0;
        end else begin
            valid <= I_valid;
        end
    end

    always @(posedge clk) begin
        if(valid && (|inst_type)) begin
            decoder_inst_type_cal(inst_type, I_inst_addr);
        end
    end
`endif

endmodule

//------------------------------------------------------------------------
// 异常指令译码单元
//------------------------------------------------------------------------
module ysyx_25110270_dec_except
(
    input   wire    [`InstBus       ]   I_inst,
    output  wire    [`ExceptBus     ]   O_except
);

    // 异常指令
    assign O_except[`EXCPT_ECALL  ] = (I_inst == `RV_ECALL  );
    assign O_except[`EXCPT_EBREAK ] = (I_inst == `RV_EBREAK );
    assign O_except[`EXCPT_MRET   ] = (I_inst == `RV_MRET   );
    assign O_except[`EXCPT_FENCE_I] = (I_inst == `RV_FENCE_I);

endmodule

//------------------------------------------------------------------------
// 指令解包模块
//------------------------------------------------------------------------

module ysyx_25110270_RV32_Inst_Unpack
(
    input   wire    [`InstBus           ] I_inst,
    output  wire    [`RV32_OP_WIDTH-1:0 ] opcode,
    output  wire    [`RV32_F3_WIDTH-1:0 ] funct3,
    output  wire    [`RV32_F7_WIDTH-1:0 ] funct7,
    output  wire    [`RV32_RD_WIDTH-1:0 ] rd,
    output  wire    [`RV32_RS1_WIDTH-1:0] rs1,
    output  wire    [`RV32_RS2_WIDTH-1:0] rs2
);

    assign opcode = I_inst[`RV32_OP ];
    assign funct3 = I_inst[`RV32_F3 ];
    assign funct7 = I_inst[`RV32_F7 ];
    assign rd     = I_inst[`RV32_RD ];
    assign rs1    = I_inst[`RV32_RS1];
    assign rs2    = I_inst[`RV32_RS2];

endmodule
