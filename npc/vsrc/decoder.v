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
    
    input   wire                                    I_ready,
    output  wire                                    O_ready,
    output  wire                                    O_valid,

    input   wire                                    perf_valid,

    output  wire    [`ysyx_25110270_RegAddrBus  ]   O_rs1_raddr,        //regfiles读通用寄存器1地址
    output  wire    [`ysyx_25110270_RegAddrBus  ]   O_rs2_raddr,        //regfiles读通用寄存器2地址       
    output  wire    [11:0                       ]   O_csr_addr,         //CSR寄存器地址

    output  wire    [31:0                       ]   O_inst,             //指令内容
    output  wire    [31:0                       ]   O_inst_addr,        //指令地址

    output  wire    [31:0                       ]   O_imm,              //立即数
    output  wire                                    O_rd_we,            //写通用寄存器标志
    output  wire    [`ysyx_25110270_RegAddrBus  ]   O_rd_waddr,         //写通用寄存器地址
    output  wire    [2:0                        ]   O_op,

    output  wire    [1:0                        ]   O_alu_srca_sel,
    output  wire    [1:0                        ]   O_alu_srcb_sel,
    output  wire    [1:0                        ]   O_agu_src_sel,
    output  wire                                    O_csr_src_sel,
    
    output  wire                                    O_ld_valid,         //访存有效标志
    output  wire                                    O_st_valid,         //访存有效标志
    output  wire                                    O_br_valid,         //跳转有效标志
    output  wire                                    O_csr_valid,        //CSR指令有效标志
    output  wire                                    O_f7b5_en,          //funct7[5]使能，针对srai, sub, sra指令
    output  wire                                    O_sign,             //有符号位
    output  wire    [`ysyx_25110270_ExceptBus   ]   O_except,

    //forward
    output  wire                                    O_rs1_re,
    output  wire                                    O_rs2_re
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
            `ysyx_25110270_RV32I_OP_JAL:        imm = rv32i_j_type_imm;
            `ysyx_25110270_RV_OP_CSR:           imm = rv_csr_type_imm;
            default:                            imm = 0;
        endcase
    end

    //------------------------------------------------------------------------
    // 控制信号生成
    //------------------------------------------------------------------------

    /*=======================================================================
        [18:16]:    op
        [15   ]:    csr_src_sel
        [14:13]:    agu_src_sel  
        [12:11]:    alu_srcb_sel
        [10:9 ]:    alu_srca_sel
        [8    ]:    f7b5_en    ---> srai, sub, sra
        [7    ]:    csr_valid
        [6    ]:    br_valid
        [5    ]:    st_valid
        [4    ]:    ld_valid
        [3    ]:    sign
        [2    ]:    rs2_re
        [1    ]:    rs1_re
        [0    ]:    rd_we
    ========================================================================*/
    
    localparam bit_rd_we     = 0;
    localparam bit_rs1_re    = 1;
    localparam bit_rs2_re    = 2;
    localparam bit_sign      = 3;
    localparam bit_ld_valid  = 4;
    localparam bit_st_valid  = 5;
    localparam bit_br_valid  = 6;
    localparam bit_csr_valid = 7;
    localparam bit_f7b5_en   = 8;
    localparam bit_alu_srca  = 9;
    localparam bit_alu_srcb  = 11;
    localparam bit_agu_src   = 13;
    localparam bit_csr_src   = 15;
    localparam bit_op        = 16;

    reg [18:0] basic_ctrl;

    always @(*) begin
        basic_ctrl = 0;
        case(opcode)
            `ysyx_25110270_RV32I_OP_TYPE_IL: begin
                basic_ctrl[bit_rd_we        ] = 1'b1;
                basic_ctrl[bit_rs1_re       ] = 1'b1;
                basic_ctrl[bit_ld_valid     ] = 1'b1;
                basic_ctrl[bit_agu_src +: 2 ] = `ysyx_25110270_AGUSRC_RS1;
                basic_ctrl[bit_op +: 3      ] = funct3;
            end
            `ysyx_25110270_RV32I_OP_TYPE_I: begin
                basic_ctrl[bit_rd_we        ] = 1'b1;
                basic_ctrl[bit_rs1_re       ] = 1'b1;
                basic_ctrl[bit_sign         ] = (funct3 != `ysyx_25110270_RV32I_F3_SLTIU);  // no sltiu
                basic_ctrl[bit_f7b5_en      ] = I_inst[30] & (funct3 == `ysyx_25110270_RV32I_F3_SRI);  // only srai has funct7[5] = 1
                basic_ctrl[bit_alu_srca +: 2] = `ysyx_25110270_ALUSRCA_RS1;
                basic_ctrl[bit_alu_srcb +: 2] = `ysyx_25110270_ALUSRCB_IMM;
                basic_ctrl[bit_op +: 3      ] = funct3;
            end
            `ysyx_25110270_RV32I_OP_AUIPC: begin
                basic_ctrl[bit_rd_we        ] = 1'b1;
                basic_ctrl[bit_sign         ] = 1'b1;
                basic_ctrl[bit_alu_srca +: 2] = `ysyx_25110270_ALUSRCA_PC;
                basic_ctrl[bit_alu_srcb +: 2] = `ysyx_25110270_ALUSRCB_IMM;
                basic_ctrl[bit_op +: 3      ] = `ysyx_25110270_RV32I_F3_ADD_SUB;
            end
            `ysyx_25110270_RV32I_OP_LUI: begin
                basic_ctrl[bit_rd_we        ] = 1'b1;
                basic_ctrl[bit_sign         ] = 1'b1;
                basic_ctrl[bit_alu_srca +: 2] = `ysyx_25110270_ALUSRCA_0;
                basic_ctrl[bit_alu_srcb +: 2] = `ysyx_25110270_ALUSRCB_IMM;
                basic_ctrl[bit_op +: 3      ] = `ysyx_25110270_RV32I_F3_ADD_SUB;
            end
            `ysyx_25110270_RV32I_OP_TYPE_S: begin
                basic_ctrl[bit_rs1_re       ] = 1'b1;
                basic_ctrl[bit_rs2_re       ] = 1'b1;
                basic_ctrl[bit_st_valid     ] = 1'b1;
                basic_ctrl[bit_agu_src +: 2 ] = `ysyx_25110270_AGUSRC_RS1;
                basic_ctrl[bit_op +: 3      ] = funct3;
            end
            `ysyx_25110270_RV32IM_OP_TYPE_R: begin
                basic_ctrl[bit_rd_we        ] = 1'b1;
                basic_ctrl[bit_rs1_re       ] = 1'b1;
                basic_ctrl[bit_rs2_re       ] = 1'b1;
                basic_ctrl[bit_sign         ] = (funct3 != `ysyx_25110270_RV32I_F3_SLTU);  // no sltu
                basic_ctrl[bit_f7b5_en      ] = I_inst[30];
                basic_ctrl[bit_alu_srca +: 2] = `ysyx_25110270_ALUSRCA_RS1;
                basic_ctrl[bit_alu_srcb +: 2] = `ysyx_25110270_ALUSRCB_RS2;
                basic_ctrl[bit_op +: 3      ] = funct3;
            end
            `ysyx_25110270_RV32I_OP_TYPE_B: begin
                basic_ctrl[bit_rs1_re       ] = 1'b1;
                basic_ctrl[bit_rs2_re       ] = 1'b1;
                basic_ctrl[bit_sign         ] = ~(funct3[2] & funct3[1]);   // no bltu, bgeu
                basic_ctrl[bit_br_valid     ] = 1'b1;
                basic_ctrl[bit_alu_srca +: 2] = `ysyx_25110270_ALUSRCA_RS1;
                basic_ctrl[bit_alu_srcb +: 2] = `ysyx_25110270_ALUSRCB_RS2;
                basic_ctrl[bit_agu_src +: 2 ] = `ysyx_25110270_AGUSRC_PC;
                basic_ctrl[bit_op +: 3      ] = funct3;
            end
            `ysyx_25110270_RV32I_OP_JALR: begin
                basic_ctrl[bit_rd_we        ] = 1'b1;
                basic_ctrl[bit_rs1_re       ] = 1'b1;
                basic_ctrl[bit_sign         ] = 1'b1;
                basic_ctrl[bit_br_valid     ] = 1'b1;
                basic_ctrl[bit_alu_srca +: 2] = `ysyx_25110270_ALUSRCA_PC;
                basic_ctrl[bit_alu_srcb +: 2] = `ysyx_25110270_ALUSRCB_4;
                basic_ctrl[bit_agu_src +: 2 ] = `ysyx_25110270_AGUSRC_RS1;
                basic_ctrl[bit_op +: 3      ] = 3'b011;                      // for jalr, jal, remap funct3 to 3'b011 to simplify control logic
            end
            `ysyx_25110270_RV32I_OP_JAL: begin
                basic_ctrl[bit_rd_we        ] = 1'b1;
                basic_ctrl[bit_rs1_re       ] = 1'b1;
                basic_ctrl[bit_sign         ] = 1'b1;
                basic_ctrl[bit_br_valid     ] = 1'b1;                        // br_valid + funct3 == 011 ---->  alu_add
                basic_ctrl[bit_alu_srca +: 2] = `ysyx_25110270_ALUSRCA_PC;
                basic_ctrl[bit_alu_srcb +: 2] = `ysyx_25110270_ALUSRCB_4;
                basic_ctrl[bit_agu_src +: 2 ] = `ysyx_25110270_AGUSRC_PC;
                basic_ctrl[bit_op +: 3      ] = 3'b011;                      // for jalr, jal, remap funct3 to 3'b011 to simplify control logic
            end
            `ysyx_25110270_RV_OP_CSR: begin
                basic_ctrl[bit_rd_we        ] = 1'b1;
                basic_ctrl[bit_rs1_re       ] = ~funct3[2];  // no csrrwi, csrrsi, csrrci
                basic_ctrl[bit_csr_valid    ] = 1'b1;
                basic_ctrl[bit_csr_src      ] = funct3[2];   // 1 for imm, 0 for rs1
                basic_ctrl[bit_op +: 3      ] = funct3;
            end
            default: begin end
        endcase
    end

    //------------------------------------------------------------------------
    // 异常解码
    //------------------------------------------------------------------------
    wire [`ysyx_25110270_ExceptBus ] except;
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
    
    assign O_ready = I_ready;
    assign O_valid = O_ready;

    assign O_rs1_raddr = rs1;
    assign O_rs2_raddr = rs2;
    assign O_rd_waddr = rd;

    assign O_imm = imm;
    assign O_rd_we = basic_ctrl[bit_rd_we];

    assign O_op = basic_ctrl[bit_op +: 3];

    assign O_ld_valid = basic_ctrl[bit_ld_valid];
    assign O_st_valid = basic_ctrl[bit_st_valid];
    assign O_csr_valid = basic_ctrl[bit_csr_valid];
    assign O_br_valid = basic_ctrl[bit_br_valid];
    assign O_f7b5_en = basic_ctrl[bit_f7b5_en];
    assign O_sign = basic_ctrl[bit_sign];

    assign O_csr_addr  = I_inst[31:20];

    assign O_rs1_re = basic_ctrl[bit_rs1_re];
    assign O_rs2_re = basic_ctrl[bit_rs2_re];

    assign O_alu_srca_sel = basic_ctrl[bit_alu_srca +: 2];
    assign O_alu_srcb_sel = basic_ctrl[bit_alu_srcb +: 2];
    assign O_agu_src_sel  = basic_ctrl[bit_agu_src +: 2];
    assign O_csr_src_sel  = basic_ctrl[bit_csr_src];

`ifdef PERF
    import "DPI-C" function void decoder_inst_type_cal(input int inst_type, input int pc);

    wire inst_is_ls = basic_ctrl[bit_ld_valid] | basic_ctrl[bit_st_valid];
    wire inst_is_br = basic_ctrl[bit_br_valid];
    wire inst_is_alu = (opcode == `ysyx_25110270_RV32I_OP_TYPE_I) | (opcode == `ysyx_25110270_RV32I_OP_AUIPC) | (opcode == `ysyx_25110270_RV32I_OP_LUI) | (opcode == `ysyx_25110270_RV32IM_OP_TYPE_R);
    wire inst_is_csr = basic_ctrl[bit_csr_valid];
    wire inst_is_fence_i = except[`ysyx_25110270_EXCPT_FENCE_I];

    wire [4:0] inst_type = {inst_is_fence_i, inst_is_csr, inst_is_br, inst_is_ls, inst_is_alu};
    
    reg valid;
    always @(posedge clk) begin
        if(!rst_n) begin
            valid <= 1'b0;
        end else begin
            valid <= perf_valid;
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
    output  wire    [`ysyx_25110270_ExceptBus   ]   O_except
);

    // 异常指令
    assign O_except[`ysyx_25110270_EXCPT_ECALL  ] = (I_inst == `ysyx_25110270_RV_ECALL  );
    assign O_except[`ysyx_25110270_EXCPT_EBREAK ] = (I_inst == `ysyx_25110270_RV_EBREAK );
    assign O_except[`ysyx_25110270_EXCPT_MRET   ] = (I_inst == `ysyx_25110270_RV_MRET   );
    assign O_except[`ysyx_25110270_EXCPT_FENCE_I] = (I_inst == `ysyx_25110270_RV_FENCE_I);

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
