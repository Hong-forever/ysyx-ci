`include "defines.v"

//------------------------------------------------------------------------
// 取指译码流水线单元
//------------------------------------------------------------------------

module ysyx_25110270_pipeline_if_dec
(
    input   wire                        clk,
    input   wire                        rst,

    input   wire    [31:0           ]   I_inst,             // 指令内容
    input   wire    [31:0           ]   I_inst_addr,        // 指令地址

    output  reg     [31:0           ]   O_inst,             // 指令内容
    output  reg     [31:0           ]   O_inst_addr,        // 指令地址

    input   wire                        I_enable,
    input   wire                        I_flush

);
    always @(posedge clk) begin
        if(rst | I_flush) begin
            O_inst          <= 0                        ;
            O_inst_addr     <= 0                        ;
        end else if(I_enable) begin
            O_inst          <= I_inst                   ;
            O_inst_addr     <= I_inst_addr              ;
        end
    end

endmodule



//------------------------------------------------------------------------
// 译码执行流水线单元
//------------------------------------------------------------------------

module ysyx_25110270_pipeline_dec_ex
(
    input   wire                                    clk,
    input   wire                                    rst,

    input   wire    [31:0                       ]   I_inst,             // 指令内容
    input   wire    [31:0                       ]   I_inst_addr,        // 指令地址
    input   wire    [31:0                       ]   I_rs1_rdata,        // 通用寄存器1读数据
    input   wire    [31:0                       ]   I_rs2_rdata,        // 通用寄存器2读数据
    input   wire    [31:0                       ]   I_csr_rdata,        // CSR寄存器读数据
    input   wire    [31:0                       ]   I_imm,              // 立即数
    input   wire                                    I_rd_we,            // 写通用寄存器标志
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rd_waddr,         // 写通用寄存器地址
    input   wire    [2:0                        ]   I_op,               // 指令类型
    input   wire    [1:0                        ]   I_alu_srca_sel,
    input   wire    [1:0                        ]   I_alu_srcb_sel,
    input   wire    [1:0                        ]   I_agu_src_sel,
    input   wire                                    I_csr_src_sel,
    input   wire                                    I_ld_valid,         // 访存有效标志
    input   wire                                    I_st_valid,         // 访存有效标志
    input   wire                                    I_br_valid,         // 分支有效标志
    input   wire                                    I_csr_valid,        // 写CSR寄存器标志
    input   wire    [11:0                       ]   I_csr_addr,         // 写CSR寄存器地址
    input   wire                                    I_f7b5_en,          // 指令funct7[5]有效标志
    input   wire                                    I_sign,             // 有符号位
    input   wire    [`ysyx_25110270_ExceptBus   ]   I_except,           // 异常

    input   wire    [1:0                        ]   I_fwd_ctrl_rs1,
    input   wire    [1:0                        ]   I_fwd_ctrl_rs2,
    input   wire    [1:0                        ]   I_fwd_ctrl_csr,

    output  reg     [31:0                       ]   O_inst,             // 指令内容
    output  reg     [31:0                       ]   O_inst_addr,        // 指令地址
    output  reg     [31:0                       ]   O_rs1_rdata,        // 通用寄存器1读数据
    output  reg     [31:0                       ]   O_rs2_rdata,        // 通用寄存器2读数据
    output  reg     [31:0                       ]   O_csr_rdata,        // CSR寄存器读数据
    output  reg     [31:0                       ]   O_imm,              // 立即数
    output  reg                                     O_rd_we,            // 写通用寄存器标志
    output  reg     [`ysyx_25110270_RegAddrBus  ]   O_rd_waddr,         // 写通用寄存器地址
    output  reg     [2:0                        ]   O_op,               // 指令类型
    output  reg     [1:0                        ]   O_alu_srca_sel,
    output  reg     [1:0                        ]   O_alu_srcb_sel,
    output  reg     [1:0                        ]   O_agu_src_sel,
    output  reg                                     O_csr_src_sel,
    output  reg                                     O_ld_valid,         // 访存有效标志
    output  reg                                     O_st_valid,         // 访存有效标志
    output  reg                                     O_br_valid,         // 分支有效标志
    output  reg                                     O_csr_valid,        // 写CSR寄存器标志
    output  reg     [11:0                       ]   O_csr_addr,         // 写CSR寄存器地址
    output  reg                                     O_f7b5_en,          // 指令funct7[5]有效标志
    output  reg                                     O_sign,             // 有符号位
    output  reg     [`ysyx_25110270_ExceptBus   ]   O_except,           // 异常

    output  reg     [1:0                        ]   O_fwd_ctrl_rs1,
    output  reg     [1:0                        ]   O_fwd_ctrl_rs2,
    output  reg     [1:0                        ]   O_fwd_ctrl_csr,

    input   wire                                    I_enable,
    input   wire                                    I_flush
);
    always @(posedge clk) begin
        if(rst | I_flush) begin
            O_rd_we         <= 0                        ;
            O_ld_valid      <= 0                        ;
            O_st_valid      <= 0                        ;
            O_br_valid      <= 0                        ;
            O_csr_valid     <= 0                        ;
            O_except        <= 0                        ;
        end else if(I_enable) begin
            O_inst          <= I_inst                   ;
            O_inst_addr     <= I_inst_addr              ;
            O_rs1_rdata     <= I_rs1_rdata              ;
            O_rs2_rdata     <= I_rs2_rdata              ;
            O_csr_rdata     <= I_csr_rdata              ;
            O_imm           <= I_imm                    ;
            O_rd_we         <= I_rd_we                  ;
            O_rd_waddr      <= I_rd_waddr               ;
            O_op            <= I_op                     ;
            O_alu_srca_sel  <= I_alu_srca_sel           ;
            O_alu_srcb_sel  <= I_alu_srcb_sel           ;
            O_agu_src_sel   <= I_agu_src_sel            ;
            O_csr_src_sel   <= I_csr_src_sel            ;
            O_ld_valid      <= I_ld_valid               ;
            O_st_valid      <= I_st_valid               ;
            O_br_valid      <= I_br_valid               ;
            O_csr_valid     <= I_csr_valid              ;
            O_csr_addr      <= I_csr_addr               ;
            O_f7b5_en       <= I_f7b5_en                ;
            O_sign          <= I_sign                   ;
            O_except        <= I_except                 ;
            O_fwd_ctrl_rs1  <= I_fwd_ctrl_rs1           ;   
            O_fwd_ctrl_rs2  <= I_fwd_ctrl_rs2           ;   
            O_fwd_ctrl_csr  <= I_fwd_ctrl_csr           ;   
        end
    end

endmodule


//------------------------------------------------------------------------
// 执行访存流水线单元
//------------------------------------------------------------------------

module ysyx_25110270_pipeline_ex_ls
(
    input   wire                                    clk,
    input   wire                                    rst,

    input   wire    [31:0                       ]   I_inst,             // 指令内容
    input   wire    [31:0                       ]   I_inst_addr,
    input   wire                                    I_rd_we,
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rd_waddr,
    input   wire    [31:0                       ]   I_rd_wdata,
    input   wire    [31:0                       ]   I_memory_addr,
    input   wire    [31:0                       ]   I_store_data,
    input   wire                                    I_ld_valid,         // 访存有效标志
    input   wire                                    I_st_valid,         // 访存有效标志
    input   wire    [2:0]                           I_ls_ctrl,          // 访存控制信号
    input   wire                                    I_csr_valid,        // 写CSR寄存器标志
    input   wire    [11:0                       ]   I_csr_addr,         // 写CSR寄存器地址
    input   wire    [31:0                       ]   I_csr_wdata,        // 写CSR寄存器数据
    input   wire    [`ysyx_25110270_ExceptBus   ]   I_except,           // 异常

    output  reg     [31:0                       ]   O_inst,             // 指令内容
    output  reg     [31:0                       ]   O_inst_addr,        // 指令地址
    output  reg                                     O_rd_we,
    output  reg     [`ysyx_25110270_RegAddrBus  ]   O_rd_waddr,
    output  reg     [31:0                       ]   O_rd_wdata,
    output  reg     [31:0                       ]   O_memory_addr,
    output  reg     [31:0                       ]   O_store_data,
    output  reg                                     O_ld_valid,         // 访存有效标志
    output  reg                                     O_st_valid,         // 访存有效标志
    output  reg     [2:0]                           O_ls_ctrl,          // 访存控制信号
    output  reg                                     O_csr_valid,        // 写CSR寄存器标志
    output  reg     [11:0                       ]   O_csr_addr,         // 写CSR寄存器地址
    output  reg     [31:0                       ]   O_csr_wdata,        // 写CSR寄存器数据
    output  reg     [`ysyx_25110270_ExceptBus   ]   O_except,           // 异常

    input   wire                                    I_enable,
    input   wire                                    I_flush
);
    always @(posedge clk) begin
        if(rst | I_flush) begin
            O_rd_we         <= 0                        ;
            O_ld_valid      <= 0                        ;
            O_st_valid      <= 0                        ;
            O_csr_valid     <= 0                        ;
            O_except        <= 0                        ;
        end else if(I_enable) begin
            O_inst          <= I_inst                   ;
            O_inst_addr     <= I_inst_addr              ;
            O_rd_we         <= I_rd_we                  ;
            O_rd_waddr      <= I_rd_waddr               ;
            O_rd_wdata      <= I_rd_wdata               ;
            O_memory_addr   <= I_memory_addr            ;
            O_store_data    <= I_store_data             ;
            O_ld_valid      <= I_ld_valid               ;
            O_st_valid      <= I_st_valid               ;
            O_ls_ctrl       <= I_ls_ctrl                ;
            O_csr_valid     <= I_csr_valid              ;
            O_csr_addr      <= I_csr_addr               ;
            O_csr_wdata     <= I_csr_wdata              ;
            O_except        <= I_except                 ;
        end
    end

endmodule


//------------------------------------------------------------------------
// 访存写回流水线单元
//------------------------------------------------------------------------

module ysyx_25110270_pipeline_ls_wb
(
    input   wire                                    clk,
    input   wire                                    rst,

    input   wire    [31:0                       ]   I_inst,             // 指令内容
    input   wire    [31:0                       ]   I_inst_addr,        // 指令地址
    input   wire                                    I_rd_we,
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rd_waddr,
    input   wire    [31:0                       ]   I_rd_wdata,
    input   wire                                    I_csr_valid,        // 写CSR寄存器标志
    input   wire    [11:0                       ]   I_csr_addr,         // 写CSR寄存器地址
    input   wire    [31:0                       ]   I_csr_wdata,        // 写CSR寄存器数据
    input   wire    [`ysyx_25110270_ExceptBus   ]   I_except,           // 异常

    input   wire                                    I_device_skip,

    output  reg     [31:0                       ]   O_inst,             // 指令内容
    output  reg     [31:0                       ]   O_inst_addr,        // 指令地址
    output  reg                                     O_rd_we,
    output  reg     [`ysyx_25110270_RegAddrBus  ]   O_rd_waddr,
    output  reg     [31:0                       ]   O_rd_wdata,
    output  reg                                     O_csr_valid,        // 写CSR寄存器标志
    output  reg     [11:0                       ]   O_csr_addr,         // 写CSR寄存器地址
    output  reg     [31:0                       ]   O_csr_wdata,        // 写CSR寄存器数据
    output  reg     [`ysyx_25110270_ExceptBus   ]   O_except,           // 异常

    output  wire                                    O_device_skip,

    input   wire                                    I_enable,
    input   wire                                    I_flush
);

    always @(posedge clk) begin
        if(rst | I_flush) begin
            O_rd_we         <= 0                        ;
            O_csr_valid     <= 0                        ;
            O_except        <= 0                        ;
        end else if(I_enable) begin
            O_inst          <= I_inst                   ;
            O_inst_addr     <= I_inst_addr              ;
            O_rd_we         <= I_rd_we                  ;
            O_rd_waddr      <= I_rd_waddr               ;
            O_rd_wdata      <= I_rd_wdata               ;
            O_csr_valid     <= I_csr_valid              ;
            O_csr_addr      <= I_csr_addr               ;
            O_csr_wdata     <= I_csr_wdata              ;
            O_except        <= I_except                 ;
            O_device_skip   <= I_device_skip            ;
        end
    end

endmodule