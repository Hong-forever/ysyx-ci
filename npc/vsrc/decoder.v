`include "defines.v"

//------------------------------------------------------------------------
// 译码单元
//------------------------------------------------------------------------

module ysyx_25110270_decoder 
(
    input   wire                                    clk,
    input   wire                                    rst_n,

    input   wire    [31:0                       ]   I_inst,
    input   wire    [31:0                       ]   I_inst_addr,
    
    input   wire                                    I_valid,
    output  wire                                    O_ready,
    output  wire                                    O_valid,
    input   wire                                    I_ready,

    output  wire    [`yxyx_25110270_RegAddrBus  ]   O_rs1_raddr,        //regfiles读通用寄存器1地址
    output  wire    [`yxyx_25110270_RegAddrBus  ]   O_rs2_raddr,        //regfiles读通用寄存器2地址       
    output  wire    [11:0                       ]   O_csr_raddr,        //读CSR寄存器地址

    input   wire    [31:0                       ]   I_rs1_rdata,        //获取通用寄存器1地址指向的数据
    input   wire    [31:0                       ]   I_rs2_rdata,        //获取通用寄存器2地址指向的数据
    input   wire    [31:0                       ]   I_csr_rdata,        //CSR寄存器输入数据

    output  wire    [31:0                       ]   O_inst,             //指令内容
    output  wire    [31:0                       ]   O_inst_addr,        //指令地址

    output  wire    [31:0                       ]   O_rs1_rdata,        //通用寄存器1数据
    output  wire    [31:0                       ]   O_rs2_rdata,        //通用寄存器2数据
    output  wire    [31:0                       ]   O_imm,              //立即数
    output  wire                                    O_rd_we,            //写通用寄存器标志
    output  wire    [`yxyx_25110270_RegAddrBus  ]   O_rd_waddr,         //写通用寄存器地址
    output  wire                                    O_csr_we,           //写CSR寄存器标志
    output  wire    [11:0                       ]   O_csr_waddr,        //写CSR寄存器地址
    output  wire    [31:0                       ]   O_csr_rdata,        //CSR寄存器数据

    output  wire    [`yxyx_25110270_CSRCTL_BUS  ]   O_csr_ctrl,
    output  wire    [`yxyx_25110270_ALUCTL_BUS  ]   O_alu_ctrl,          //ALU控制信号
    output  wire    [`yxyx_25110270_BRUCTL_BUS  ]   O_bru_ctrl,          //BRU控制信号
    output  wire    [`yxyx_25110270_ALUSRCA_BUS ]   O_alu_srca_sel,
    output  wire    [`yxyx_25110270_ALUSRCB_BUS ]   O_alu_srcb_sel,
    output  wire    [`yxyx_25110270_AGUSRC_BUS  ]   O_agu_src_sel,
    output  wire    [`yxyx_25110270_CSRSRC_BUS  ]   O_csr_src_sel,
    
    //ls明辨
    output  wire                                    O_ls_valid,         //访存有效标志
    output  wire    [`yxyx_25110270_LSUCTL_BUS  ]   O_lsu_ctrl,         //访存类型

    //forward
    output  wire                                    O_rs1_re,
    output  wire                                    O_rs2_re,
    output  wire                                    O_csr_re,

    // 异常
    output  wire    [`yxyx_25110270_ExceptBus   ]   O_except
);
    
    //------------------------------------------------------------------------
    // 指令解码
    //------------------------------------------------------------------------
    wire [`ysyx_25110270_RV32_OP_WIDTH-1:0]  opcode;
    wire [`ysyx_25110270_RV32_F3_WIDTH-1:0]  funct3;
    wire [`ysyx_25110270_RV32_F7_WIDTH-1:0]  funct7;
    wire [`ysyx_25110270_RV32_RD_WIDTH-1:0]  rd;
    wire [`ysyx_25110270_RV32_RS1_WIDTH-1:0] rs1;
    wire [`ysyx_25110270_RV32_RS2_WIDTH-1:0] rs2;
    
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
    wire [31:0] rv32i_i_type_imm = {{20{I_inst[31]}}, I_inst[31:20]};
    wire [31:0] rv32i_s_type_imm = {{20{I_inst[31]}}, I_inst[31:25], I_inst[11:7]};
    wire [31:0] rv32i_u_type_imm = {I_inst[31:12], 12'b0};
    wire [31:0] rv32i_b_type_imm = {{20{I_inst[31]}}, I_inst[7], I_inst[30:25], I_inst[11:8], 1'b0};
    wire [31:0] rv32i_j_type_imm = {{12{I_inst[31]}}, I_inst[19:12], I_inst[20], I_inst[30:21], 1'b0};
    wire [31:0] rv_csr_type_imm  = {27'h0, I_inst[19:15]};

    reg [31:0] imm;
    always @(*) begin
        case(opcode)
            `ysyx_25110270_RV32I_OP_TYPE_IL,
            `ysyx_25110270_RV32I_OP_TYPE_I,
            `ysyx_25110270_RV32I_OP_JALR:       imm = rv32i_i_type_imm;

            `ysyx_25110270_RV32I_OP_TYPE_S:     imm = rv32i_s_type_imm;

            `ysyx_25110270_RV32I_OP_AUIPC,
            `ysyx_25110270_RV32I_OP_LUI:        imm = rv32i_u_type_imm;

            `ysyx_25110270_RV32I_OP_TYPE_B:     imm = rv32i_b_type_imm;
            `ysyx_25110270_RV32I_OP_TYPE_JAL:   imm = rv32i_j_type_imm;
            `ysyx_25110270_RV_OP_CSR:           imm = rv_csr_type_imm;
            default:                            imm = 0;
        endcase
    end

    //------------------------------------------------------------------------
    // 控制信号生成
    //------------------------------------------------------------------------

    // basic_ctrl[11:10]: alu_srca_sel
    // basic_ctrl[9:8]:   alu_srcb_sel  
    // basic_ctrl[7:6]:   agu_src_sel
    // basic_ctrl[5:4]:   csr_src_sel
    // basic_ctrl[3]:     rs1_re
    // basic_ctrl[2]:     rs2_re
    // basic_ctrl[1]:     rd_we
    // basic_ctrl[0]:     csr_en
    reg [15:0] basic_ctrl;
    reg ls_valid;



    always @(*) begin
        rs1_re   = 0;
        rs2_re   = 0;
        rd_we    = 0;
        csr_en   = 0;
        ls_valid = 0;
        lsu_ctrl  = 0;
        alu_ctrl = 0;
        bru_ctrl = 0;
        csr_ctrl = 0;
        alu_srca_sel = 0;
        alu_srcb_sel = 0;
        agu_src_sel  = 0;
        csr_src_sel  = 0;
        case(opcode)
            `ysyx_25110270_RV32I_OP_TYPE_IL: begin
                rs1_re   = 1;
                rd_we    = 1;
                ls_valid = 1;
                agu_src_sel = `ysyx_25110270_AGUSRC_RS1;
                case(funct3)
                    `ysyx_25110270_RV32I_F3_LB:  lsu_ctrl = `ysyx_25110270_LS_LB;
                    `ysyx_25110270_RV32I_F3_LH:  lsu_ctrl = `ysyx_25110270_LS_LH;
                    `ysyx_25110270_RV32I_F3_LW:  lsu_ctrl = `ysyx_25110270_LS_LW;
                    `ysyx_25110270_RV32I_F3_LBU: lsu_ctrl = `ysyx_25110270_LS_LBU;
                    `ysyx_25110270_RV32I_F3_LHU: lsu_ctrl = `ysyx_25110270_LS_LHU;
                    default: begin end
                endcase
            end
            `ysyx_25110270_RV32I_OP_TYPE_I: begin
                rs1_re = 1;
                rd_we  = 1;
                alu_srca_sel = `ysyx_25110270_ALUSRCA_RS1;
                alu_srcb_sel = `ysyx_25110270_ALUSRCB_IMM;
                case(funct3)
                    `ysyx_25110270_RV32I_F3_ADDI:  alu_ctrl = `ysyx_25110270_ALUCTL_ADD;
                    `ysyx_25110270_RV32I_F3_SLLI:  alu_ctrl = `ysyx_25110270_ALUCTL_SLL;
                    `ysyx_25110270_RV32I_F3_SLTI:  alu_ctrl = `ysyx_25110270_ALUCTL_SLT;
                    `ysyx_25110270_RV32I_F3_SLTIU: alu_ctrl = `ysyx_25110270_ALUCTL_SLTU;
                    `ysyx_25110270_RV32I_F3_XORI:  alu_ctrl = `ysyx_25110270_ALUCTL_XOR;
                    `ysyx_25110270_RV32I_F3_SRI:   alu_ctrl = I_inst[30]? `ysyx_25110270_ALUCTL_SRA : `ysyx_25110270_ALUCTL_SRL;
                    `ysyx_25110270_RV32I_F3_ORI:   alu_ctrl = `ysyx_25110270_ALUCTL_OR;
                    `ysyx_25110270_RV32I_F3_ANDI:  alu_ctrl = `ysyx_25110270_ALUCTL_AND;
                    default:         begin end
                endcase
            end
            `ysyx_25110270_RV32I_OP_AUIPC: begin
                rd_we    = 1'b1;
                alu_ctrl = `ysyx_25110270_ALUCTL_ADD;
                alu_srca_sel = `ysyx_25110270_ALUSRCA_PC;
                alu_srcb_sel = `ysyx_25110270_ALUSRCB_IMM;
            end
            `ysyx_25110270_RV32I_OP_LUI: begin
                rd_we    = 1'b1;
                alu_ctrl = `ysyx_25110270_ALUCTL_ADD;
                alu_srca_sel = `ysyx_25110270_ALUSRCA_0;
                alu_srcb_sel = `ysyx_25110270_ALUSRCB_IMM;
            end
            `ysyx_25110270_RV32I_OP_TYPE_S: begin
                rs1_re   = 1;
                rs2_re   = 1;
                ls_valid = 1;
                agu_src_sel = `ysyx_25110270_AGUSRC_RS1;
                case(funct3)
                    `ysyx_25110270_RV32I_F3_SB: lsu_ctrl = `ysyx_25110270_LS_SB;
                    `ysyx_25110270_RV32I_F3_SH: lsu_ctrl = `ysyx_25110270_LS_SH;
                    `ysyx_25110270_RV32I_F3_SW: lsu_ctrl = `ysyx_25110270_LS_SW;
                    default:      begin end
                endcase
            end
            `ysyx_25110270_RV32IM_OP_TYPE_R: begin
                rs1_re = 1;
                rs2_re = 1;
                rd_we  = 1;
                alu_srca_sel = `ysyx_25110270_ALUSRCA_RS1;
                alu_srcb_sel = `ysyx_25110270_ALUSRCB_RS2;
                case(funct3)
                    `ysyx_25110270_RV32I_F3_ADD_SUB: alu_ctrl = I_inst[30]? `ysyx_25110270_ALUCTL_SUB : `ysyx_25110270_ALUCTL_ADD;
                    `ysyx_25110270_RV32I_F3_SLL:     alu_ctrl = `ysyx_25110270_ALUCTL_SLL;
                    `ysyx_25110270_RV32I_F3_SLT:     alu_ctrl = `ysyx_25110270_ALUCTL_SLT;
                    `ysyx_25110270_RV32I_F3_SLTU:    alu_ctrl = `ysyx_25110270_ALUCTL_SLTU;
                    `ysyx_25110270_RV32I_F3_XOR:     alu_ctrl = `ysyx_25110270_ALUCTL_XOR;
                    `ysyx_25110270_RV32I_F3_SR:      alu_ctrl = I_inst[30]? `ysyx_25110270_ALUCTL_SRA : `ysyx_25110270_ALUCTL_SRL;
                    `ysyx_25110270_RV32I_F3_OR:      alu_ctrl = `ysyx_25110270_ALUCTL_OR;
                    `ysyx_25110270_RV32I_F3_AND:     alu_ctrl = `ysyx_25110270_ALUCTL_AND;
                    default:           begin end
                endcase
            end
            `ysyx_25110270_RV32I_OP_TYPE_B: begin
                rs1_re = 1;
                rs2_re = 1;
                alu_srca_sel = `ysyx_25110270_ALUSRCA_RS1;
                alu_srcb_sel = `ysyx_25110270_ALUSRCB_RS2;
                agu_src_sel  = `ysyx_25110270_AGUSRC_PC;
                case(funct3)
                    `ysyx_25110270_RV32I_F3_BEQ: begin
                        alu_ctrl = `ysyx_25110270_ALUCTL_SLT;
                        bru_ctrl = `ysyx_25110270_BRUCTL_BEQ;
                    end
                    `ysyx_25110270_RV32I_F3_BNE: begin
                        alu_ctrl = `ysyx_25110270_ALUCTL_SLT;
                        bru_ctrl = `ysyx_25110270_BRUCTL_BNE;
                    end
                    `ysyx_25110270_RV32I_F3_BLT: begin 
                        alu_ctrl = `ysyx_25110270_ALUCTL_SLT;
                        bru_ctrl = `ysyx_25110270_BRUCTL_BLT;
                    end
                    `ysyx_25110270_RV32I_F3_BGE: begin
                        alu_ctrl = `ysyx_25110270_ALUCTL_SLT;
                        bru_ctrl = `ysyx_25110270_BRUCTL_BGE;
                    end
                    `ysyx_25110270_RV32I_F3_BLTU: begin
                        alu_ctrl = `ysyx_25110270_ALUCTL_SLTU;
                        bru_ctrl = `ysyx_25110270_BRUCTL_BLTU;
                    end
                    `ysyx_25110270_RV32I_F3_BGEU: begin
                        alu_ctrl = `ysyx_25110270_ALUCTL_SLTU;
                        bru_ctrl = `ysyx_25110270_BRUCTL_BGEU;
                    end
                    default: begin end
                endcase
            end
            `ysyx_25110270_RV32I_OP_JALR: begin
                rs1_re   = 1;
                rd_we    = 1;
                alu_ctrl = `ysyx_25110270_ALUCTL_ADD;
                bru_ctrl = `ysyx_25110270_BRUCTL_JAL;
                alu_srca_sel = `ysyx_25110270_ALUSRCA_PC;
                alu_srcb_sel = `ysyx_25110270_ALUSRCB_4;
                agu_src_sel  = `ysyx_25110270_AGUSRC_RS1;
            end
            `ysyx_25110270_RV32I_OP_JAL: begin
                rs1_re   = 1;
                rd_we    = 1;
                alu_ctrl = `ysyx_25110270_ALUCTL_ADD;
                bru_ctrl = `ysyx_25110270_BRUCTL_JAL;
                imm      = rv32i_j_type_imm;
                alu_srca_sel = `ysyx_25110270_ALUSRCA_PC;
                alu_srcb_sel = `ysyx_25110270_ALUSRCB_4;
                agu_src_sel  = `ysyx_25110270_AGUSRC_PC;
            end
            `ysyx_25110270_RV_OP_CSR: begin
                rd_we  = 1;
                csr_en = 1;
                imm    = rv_csr_type_imm;
                case(funct3)
                    `ysyx_25110270_RV_F3_CSRRW: begin
                        rs1_re   = 1;
                        csr_ctrl = `ysyx_25110270_CSRCTL_WRI;
                        csr_src_sel = `ysyx_25110270_CSRSRC_RS1;
                    end
                    `ysyx_25110270_RV_F3_CSRRS: begin
                        rs1_re   = 1;
                        csr_ctrl = `ysyx_25110270_CSRCTL_SET;
                        csr_src_sel = `ysyx_25110270_CSRSRC_RS1;
                    end
                    `ysyx_25110270_RV_F3_CSRRC: begin
                        rs1_re   = 1;
                        csr_ctrl = `ysyx_25110270_CSRCTL_CLR;
                        csr_src_sel = `ysyx_25110270_CSRSRC_RS1;
                    end
                    `ysyx_25110270_RV_F3_CSRRWI: begin
                        csr_ctrl = `ysyx_25110270_CSRCTL_WRI;
                        csr_src_sel = `ysyx_25110270_CSRSRC_IMM;
                    end
                    `ysyx_25110270_RV_F3_CSRRSI: begin
                        csr_ctrl = `ysyx_25110270_CSRCTL_SET;
                        csr_src_sel = `ysyx_25110270_CSRSRC_IMM;
                    end
                    `ysyx_25110270_RV_F3_CSRRCI: begin
                        csr_ctrl = `ysyx_25110270_CSRCTL_CLR;
                        csr_src_sel = `ysyx_25110270_CSRSRC_IMM;
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
    wire [`yxyx_25110270_ExceptBus ] except;
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
    assign O_alu_ctrl = alu_ctrl;
    assign O_csr_ctrl = csr_ctrl;
    assign O_bru_ctrl = bru_ctrl;
    assign O_ls_valid = ls_valid;
    assign O_lsu_ctrl = lsu_ctrl;
    assign O_csr_raddr = I_inst[31:20];
    assign O_csr_rdata = I_csr_rdata;
    assign O_csr_we = csr_en;
    assign O_csr_waddr = I_inst[31:20];

    assign O_rs1_re = rs1_re;
    assign O_rs2_re = rs2_re;
    assign O_csr_re = csr_en;

    assign O_alu_srca_sel = alu_srca_sel;
    assign O_alu_srcb_sel = alu_srcb_sel;
    assign O_agu_src_sel  = agu_src_sel;
    assign O_csr_src_sel  = csr_src_sel;

`ifdef PERF
    import "DPI-C" function void decoder_inst_type_cal(input int inst_type, input int pc);

    wire inst_is_ls = (lsu_ctrl != 0);
    wire inst_is_br = (bru_ctrl != 0);
    wire inst_is_alu = (opcode == `ysyx_25110270_RV32I_OP_TYPE_I) | (opcode == `ysyx_25110270_RV32I_OP_AUIPC) | (opcode == `ysyx_25110270_RV32I_OP_LUI) | (opcode == `ysyx_25110270_RV32IM_OP_TYPE_R);
    wire inst_is_csr = (csr_en != 0);
    wire inst_is_fence_i = except[`_EXCPT_FENCE_I];

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
    input   wire    [31:0                       ]   I_inst,
    output  wire    [`yxyx_25110270_ExceptBus   ]   O_except
);

    // 异常指令
    assign O_except[`EXCPT_ECALL  ] = (I_inst == `ysyx_25110270_RV_ECALL  );
    assign O_except[`EXCPT_EBREAK ] = (I_inst == `ysyx_25110270_RV_EBREAK );
    assign O_except[`EXCPT_MRET   ] = (I_inst == `ysyx_25110270_RV_MRET   );
    assign O_except[`EXCPT_FENCE_I] = (I_inst == `ysyx_25110270_RV_FENCE_I);

endmodule

//------------------------------------------------------------------------
// 指令解包模块
//------------------------------------------------------------------------

module ysyx_25110270_RV32_Inst_Unpack
(
    input   wire    [31:0                               ] I_inst,
    output  wire    [`ysyx_25110270_RV32_OP_WIDTH-1:0   ] opcode,
    output  wire    [`ysyx_25110270_RV32_F3_WIDTH-1:0   ] funct3,
    output  wire    [`ysyx_25110270_RV32_F7_WIDTH-1:0   ] funct7,
    output  wire    [`ysyx_25110270_RV32_RD_WIDTH-1:0   ] rd,
    output  wire    [`ysyx_25110270_RV32_RS1_WIDTH-1:0  ] rs1,
    output  wire    [`ysyx_25110270_RV32_RS2_WIDTH-1:0  ] rs2
);

    assign opcode = I_inst[`ysyx_25110270_RV32_OP ];
    assign funct3 = I_inst[`ysyx_25110270_RV32_F3 ];
    assign funct7 = I_inst[`ysyx_25110270_RV32_F7 ];
    assign rd     = I_inst[`ysyx_25110270_RV32_RD ];
    assign rs1    = I_inst[`ysyx_25110270_RV32_RS1];
    assign rs2    = I_inst[`ysyx_25110270_RV32_RS2];

endmodule
