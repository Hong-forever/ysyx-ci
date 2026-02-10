`include "defines.v"

//------------------------------------------------------------------------
// 取指译码流水线单元
//------------------------------------------------------------------------

module ysyx_25110270_pipeline_if_dec
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire    [31:0           ]   I_inst,             // 指令内容
    input   wire    [31:0           ]   I_inst_addr,        // 指令地址

    output  reg     [31:0           ]   O_inst,             // 指令内容
    output  reg     [31:0           ]   O_inst_addr         // 指令地址

);
    always @(posedge clk) begin
        if (!rst_n) begin
            O_inst          <= 0;
            O_inst_addr     <= 0;
        end else begin
            O_inst          <= I_inst;
            O_inst_addr     <= I_inst_addr;
        end
    end

endmodule



//------------------------------------------------------------------------
// 译码执行流水线单元
//------------------------------------------------------------------------

module ysyx_25110270_pipeline_dec_ex
(
    input   wire                                    clk,
    input   wire                                    rst_n,

    input   wire    [31:0                       ]   I_inst,             // 指令内容
    input   wire    [31:0                       ]   I_inst_addr,        // 指令地址
    input   wire    [31:0                       ]   I_rs1_rdata,        // 通用寄存器1读数据
    input   wire    [31:0                       ]   I_rs2_rdata,        // 通用寄存器2读数据
    input   wire    [31:0                       ]   I_imm,              // 立即数
    input   wire                                    I_rd_we,            // 写通用寄存器标志
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rd_waddr,         // 写通用寄存器地址
    input   wire                                    I_csr_we,           // 写CSR寄存器标志
    input   wire    [11:0                       ]   I_csr_waddr,        // 写CSR寄存器地址
    input   wire    [31:0                       ]   I_csr_rdata,        // CSR寄存器读数据
    input   wire    [`ysyx_25110270_CSRCTL_BUS  ]   I_csr_ctrl,
    input   wire    [`ysyx_25110270_ALUCTL_BUS  ]   I_alu_ctrl,          // ALU控制信号
    input   wire    [`ysyx_25110270_BRUCTL_BUS  ]   I_bru_ctrl,          // BRU控制信号
    input   wire    [`ysyx_25110270_ALUSRCA_BUS ]   I_alu_srca_sel,
    input   wire    [`ysyx_25110270_ALUSRCB_BUS ]   I_alu_srcb_sel,
    input   wire    [`ysyx_25110270_AGUSRC_BUS  ]   I_agu_src_sel,
    input   wire    [`ysyx_25110270_CSRSRC_BUS  ]   I_csr_src_sel,
    input   wire                                    I_ls_valid,         // 访存有效标志
    input   wire    [`ysyx_25110270_LSUCTL_BUS  ]   I_lsu_ctrl,         // 访存有效标志
    input   wire                                    I_csr_re,
    input   wire    [`ysyx_25110270_ExceptBus   ]   I_except,           // 异常

    output  reg     [31:0                       ]   O_inst,             // 指令内容
    output  reg     [31:0                       ]   O_inst_addr,        // 指令地址
    output  reg     [31:0                       ]   O_rs1_rdata,        // 通用寄存器1读数据
    output  reg     [31:0                       ]   O_rs2_rdata,        // 通用寄存器2读数据
    output  reg     [31:0                       ]   O_imm,              // 立即数
    output  reg                                     O_rd_we,            // 写通用寄存器标志
    output  reg     [`ysyx_25110270_RegAddrBus  ]   O_rd_waddr,         // 写通用寄存器地址
    output  reg                                     O_csr_we,           // 写CSR寄存器标志
    output  reg     [11:0                       ]   O_csr_waddr,        // 写CSR寄存器地址
    output  reg     [31:0                       ]   O_csr_rdata,        // CSR寄存器读数据
    output  reg     [`ysyx_25110270_CSRCTL_BUS  ]   O_csr_ctrl,
    output  reg     [`ysyx_25110270_ALUCTL_BUS  ]   O_alu_ctrl,          // ALU控制信号
    output  reg     [`ysyx_25110270_BRUCTL_BUS  ]   O_bru_ctrl,          // BRU控制信号
    output  reg     [`ysyx_25110270_ALUSRCA_BUS ]   O_alu_srca_sel,
    output  reg     [`ysyx_25110270_ALUSRCB_BUS ]   O_alu_srcb_sel,
    output  reg     [`ysyx_25110270_AGUSRC_BUS  ]   O_agu_src_sel,
    output  reg     [`ysyx_25110270_CSRSRC_BUS  ]   O_csr_src_sel,
    output  reg                                     O_ls_valid,         // 访存有效标志
    output  reg     [`ysyx_25110270_LSUCTL_BUS  ]   O_lsu_ctrl,          // 访存有效标志
    output  reg                                     O_csr_re,
    output  reg     [`ysyx_25110270_ExceptBus   ]   O_except           // 异常
);
    always @(posedge clk) begin
        if (!rst_n) begin
            O_inst          <= 0;
            O_inst_addr     <= 0;
            O_rs1_rdata     <= 0;
            O_rs2_rdata     <= 0;
            O_rd_we         <= 0;
            O_imm           <= 0;
            O_rd_waddr      <= 0;
            O_csr_we        <= 0;
            O_csr_waddr     <= 0;
            O_csr_rdata     <= 0;
            O_csr_ctrl      <= 0;
            O_alu_ctrl      <= 0;
            O_bru_ctrl      <= 0;
            O_alu_srca_sel  <= 0;
            O_alu_srcb_sel  <= 0;
            O_agu_src_sel   <= 0;
            O_csr_src_sel   <= 0;
            O_ls_valid      <= 0;
            O_lsu_ctrl      <= 0;
            O_csr_re        <= 0;
            O_except        <= 0;
        end else begin
            O_inst          <= I_inst;
            O_inst_addr     <= I_inst_addr;
            O_rs1_rdata     <= I_rs1_rdata;
            O_rs2_rdata     <= I_rs2_rdata;
            O_rd_we         <= I_rd_we;
            O_rd_waddr      <= I_rd_waddr;
            O_imm           <= I_imm;
            O_csr_we        <= I_csr_we;
            O_csr_waddr     <= I_csr_waddr;
            O_csr_rdata     <= I_csr_rdata;
            O_csr_ctrl      <= I_csr_ctrl;
            O_alu_ctrl      <= I_alu_ctrl;
            O_bru_ctrl      <= I_bru_ctrl;
            O_alu_srca_sel  <= I_alu_srca_sel;
            O_alu_srcb_sel  <= I_alu_srcb_sel;
            O_agu_src_sel   <= I_agu_src_sel;
            O_csr_src_sel   <= I_csr_src_sel;
            O_ls_valid      <= I_ls_valid;
            O_lsu_ctrl      <= I_lsu_ctrl;
            O_csr_re        <= I_csr_re;
            O_except        <= I_except;
        end
    end

endmodule


//------------------------------------------------------------------------
// 执行访存流水线单元
//------------------------------------------------------------------------

module ysyx_25110270_pipeline_ex_ls
(
    input   wire                                    clk,
    input   wire                                    rst_n,

    input   wire    [31:0                       ]   I_inst,             // 指令内容
    input   wire    [31:0                       ]   I_inst_addr,
    input   wire                                    I_rd_we,
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rd_waddr,
    input   wire    [31:0                       ]   I_rd_wdata,
    input   wire    [31:0                       ]   I_memory_addr,
    input   wire    [31:0                       ]   I_store_data,
    input   wire                                    I_ls_valid,         // 访存有效标志
    input   wire    [`ysyx_25110270_LSUCTL_BUS  ]   I_lsu_ctrl,
    input   wire                                    I_csr_we,           // 写CSR寄存器标志
    input   wire    [11:0                       ]   I_csr_waddr,        // 写CSR寄存器地址
    input   wire    [31:0                       ]   I_csr_wdata,        // 写CSR寄存器数据
    input   wire    [`ysyx_25110270_ExceptBus   ]   I_except,           // 异常

    output  reg     [31:0                       ]   O_inst,             // 指令内容
    output  reg     [31:0                       ]   O_inst_addr,        // 指令地址
    output  reg                                     O_rd_we,
    output  reg     [`ysyx_25110270_RegAddrBus  ]   O_rd_waddr,
    output  reg     [31:0                       ]   O_rd_wdata,
    output  reg     [31:0                       ]   O_memory_addr,
    output  reg     [31:0                       ]   O_store_data,
    output  reg                                     O_ls_valid,         // 访存有效标志
    output  reg     [`ysyx_25110270_LSUCTL_BUS  ]   O_lsu_ctrl,
    output  reg                                     O_csr_we,           // 写CSR寄存器标志
    output  reg     [11:0                       ]   O_csr_waddr,        // 写CSR寄存器地址
    output  reg     [31:0                       ]   O_csr_wdata,        // 写CSR寄存器数据
    output  reg     [`ysyx_25110270_ExceptBus   ]   O_except           // 异常

);
    always @(posedge clk) begin
        if (!rst_n) begin
            O_inst          <= 0;
            O_inst_addr     <= 0;
            O_rd_we         <= 0;
            O_rd_waddr      <= 0;
            O_rd_wdata      <= 0;
            O_memory_addr   <= 0;
            O_store_data    <= 0;
            O_ls_valid      <= 0;
            O_lsu_ctrl      <= 0;
            O_csr_we        <= 0;
            O_csr_waddr     <= 0;
            O_csr_wdata     <= 0;
            O_except        <= 0;
        end else begin
            O_inst          <= I_inst;
            O_inst_addr     <= I_inst_addr;
            O_rd_we         <= I_rd_we;
            O_rd_waddr      <= I_rd_waddr;
            O_rd_wdata      <= I_rd_wdata;
            O_memory_addr   <= I_memory_addr;
            O_store_data    <= I_store_data;
            O_ls_valid      <= I_ls_valid;
            O_lsu_ctrl      <= I_lsu_ctrl;
            O_csr_we        <= I_csr_we;
            O_csr_waddr     <= I_csr_waddr;
            O_csr_wdata     <= I_csr_wdata;
            O_except        <= I_except;
        end
    end

endmodule


//------------------------------------------------------------------------
// 访存写回流水线单元
//------------------------------------------------------------------------

module ysyx_25110270_pipeline_ls_wb
(
    input   wire                                    clk,
    input   wire                                    rst_n,

    input   wire    [31:0                       ]   I_inst,             // 指令内容
    input   wire    [31:0                       ]   I_inst_addr,        // 指令地址
    input   wire                                    I_rd_we,
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rd_waddr,
    input   wire    [31:0                       ]   I_rd_wdata,
    input   wire                                    I_csr_we,           // 写CSR寄存器标志
    input   wire    [11:0                       ]   I_csr_waddr,        // 写CSR寄存器地址
    input   wire    [31:0                       ]   I_csr_wdata,        // 写CSR寄存器数据
    input   wire    [`ysyx_25110270_ExceptBus   ]   I_except,           // 异常

    input   wire                                    I_device_skip,

    output  reg     [31:0                       ]   O_inst,             // 指令内容
    output  reg     [31:0                       ]   O_inst_addr,        // 指令地址
    output  reg                                     O_rd_we,
    output  reg     [`ysyx_25110270_RegAddrBus  ]   O_rd_waddr,
    output  reg     [31:0                       ]   O_rd_wdata,
    output  reg                                     O_csr_we,           // 写CSR寄存器标志
    output  reg     [11:0                       ]   O_csr_waddr,        // 写CSR寄存器地址
    output  reg     [31:0                       ]   O_csr_wdata,        // 写CSR寄存器数据
    output  reg     [`ysyx_25110270_ExceptBus   ]   O_except,           // 异常

    output  wire                                    O_device_skip

);

    always @(posedge clk) begin
        if (!rst_n) begin
            O_inst          <= 0;
            O_inst_addr     <= 0;
            O_rd_we         <= 0;
            O_rd_waddr      <= 0;
            O_rd_wdata      <= 0;
            O_csr_we        <= 0;
            O_csr_waddr     <= 0;
            O_csr_wdata     <= 0;
            O_except        <= 0;
            O_device_skip   <= 0;
        end else begin
            O_inst          <= I_inst;
            O_inst_addr     <= I_inst_addr;
            O_rd_we         <= I_rd_we;
            O_rd_waddr      <= I_rd_waddr;
            O_rd_wdata      <= I_rd_wdata;
            O_csr_we        <= I_csr_we;
            O_csr_waddr     <= I_csr_waddr;
            O_csr_wdata     <= I_csr_wdata;
            O_except        <= I_except;
            O_device_skip   <= I_device_skip;
        end
    end

endmodule