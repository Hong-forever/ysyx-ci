`include "defines.v"

//------------------------------------------------------------------------
// 取指译码流水线单元
//------------------------------------------------------------------------

module ysyx_25110270_pipeline_if_dec
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire    [`InstBus       ]   I_inst,             // 指令内容
    input   wire    [`InstAddrBus   ]   I_inst_addr,        // 指令地址

    output  reg     [`InstBus       ]   O_inst,             // 指令内容
    output  reg     [`InstAddrBus   ]   O_inst_addr         // 指令地址

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
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire    [`InstBus       ]   I_inst,             // 指令内容
    input   wire    [`InstAddrBus   ]   I_inst_addr,        // 指令地址
    input   wire    [`RegDataBus    ]   I_rs1_rdata,        // 通用寄存器1读数据
    input   wire    [`RegDataBus    ]   I_rs2_rdata,        // 通用寄存器2读数据
    input   wire    [`RegDataBus    ]   I_imm,              // 立即数
    input   wire                        I_rd_we,            // 写通用寄存器标志
    input   wire    [`RegAddrBus    ]   I_rd_waddr,         // 写通用寄存器地址
    input   wire                        I_csr_we,           // 写CSR寄存器标志
    input   wire    [`CSRAddrBus    ]   I_csr_waddr,        // 写CSR寄存器地址
    input   wire    [`CSRDataBus    ]   I_csr_rdata,        // CSR寄存器读数据
    input   wire    [`CSRCTL_WIDTH-1:0] I_CSRCtrl,
    input   wire    [`ALUCTL_WIDTH-1:0] I_ALUCtrl,          // ALU控制信号
    input   wire    [`BRUCTL_WIDTH-1:0] I_BRUCtrl,          // BRU控制信号
    input   wire    [`ALUSrcA_sel_width-1:0] I_ALUSrcA_sel,
    input   wire    [`ALUSrcB_sel_width-1:0] I_ALUSrcB_sel,
    input   wire    [`AGUSrc_sel_width-1:0]  I_AGUSrc_sel,
    input   wire    [`CSRSrc_sel_width-1:0]  I_CSRSrc_sel,
    input   wire                        I_ls_valid,         // 访存有效标志
    input   wire    [`ls_diff_bus   ]   I_ls_type,          // 访存有效标志
    input   wire                        I_csr_re,
    input   wire    [`Except_Bus    ]   I_except,           // 异常

    output  reg     [`InstBus       ]   O_inst,             // 指令内容
    output  reg     [`InstAddrBus   ]   O_inst_addr,        // 指令地址
    output  reg     [`RegDataBus    ]   O_rs1_rdata,        // 通用寄存器1读数据
    output  reg     [`RegDataBus    ]   O_rs2_rdata,        // 通用寄存器2读数据
    output  reg     [`RegDataBus    ]   O_imm,              // 立即数
    output  reg                         O_rd_we,            // 写通用寄存器标志
    output  reg     [`RegAddrBus    ]   O_rd_waddr,         // 写通用寄存器地址
    output  reg                         O_csr_we,           // 写CSR寄存器标志
    output  reg     [`CSRAddrBus    ]   O_csr_waddr,        // 写CSR寄存器地址
    output  reg     [`CSRDataBus    ]   O_csr_rdata,        // CSR寄存器读数据
    output  reg     [`CSRCTL_WIDTH-1:0] O_CSRCtrl,
    output  reg     [`ALUCTL_WIDTH-1:0] O_ALUCtrl,          // ALU控制信号
    output  reg     [`BRUCTL_WIDTH-1:0] O_BRUCtrl,          // BRU控制信号
    output  reg     [`ALUSrcA_sel_width-1:0] O_ALUSrcA_sel,
    output  reg     [`ALUSrcB_sel_width-1:0] O_ALUSrcB_sel,
    output  reg     [`AGUSrc_sel_width-1:0]  O_AGUSrc_sel,
    output  reg     [`CSRSrc_sel_width-1:0]  O_CSRSrc_sel,
    output  reg                         O_ls_valid,         // 访存有效标志
    output  reg     [`ls_diff_bus   ]   O_ls_type,          // 访存有效标志
    output  reg                         O_csr_re,
    output  reg     [`Except_Bus    ]   O_except           // 异常
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
            O_CSRCtrl       <= 0;
            O_ALUCtrl       <= 0;
            O_BRUCtrl       <= 0;
            O_ALUSrcA_sel   <= 0;
            O_ALUSrcB_sel   <= 0;
            O_AGUSrc_sel    <= 0;
            O_CSRSrc_sel    <= 0;
            O_ls_valid      <= 0;
            O_ls_type       <= 0;
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
            O_CSRCtrl       <= I_CSRCtrl;
            O_ALUCtrl       <= I_ALUCtrl;
            O_BRUCtrl       <= I_BRUCtrl;
            O_ALUSrcA_sel   <= I_ALUSrcA_sel;
            O_ALUSrcB_sel   <= I_ALUSrcB_sel;
            O_AGUSrc_sel    <= I_AGUSrc_sel;
            O_CSRSrc_sel    <= I_CSRSrc_sel;
            O_ls_valid      <= I_ls_valid;
            O_ls_type       <= I_ls_type;
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
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire    [`InstBus       ]   I_inst,             // 指令内容
    input   wire    [`InstAddrBus   ]   I_inst_addr,
    input   wire                        I_rd_we,
    input   wire    [`RegAddrBus    ]   I_rd_waddr,
    input   wire    [`RegDataBus    ]   I_rd_wdata,
    input   wire    [`MemAddrBus    ]   I_memory_addr,
    input   wire    [`MemDataBus    ]   I_store_data,
    input   wire                        I_ls_valid,         // 访存有效标志
    input   wire    [`ls_diff_bus   ]   I_ls_type,
    input   wire                        I_csr_we,           // 写CSR寄存器标志
    input   wire    [`CSRAddrBus    ]   I_csr_waddr,        // 写CSR寄存器地址
    input   wire    [`CSRDataBus    ]   I_csr_wdata,        // 写CSR寄存器数据
    input   wire    [`Except_Bus    ]   I_except,           // 异常

    output  reg     [`InstBus       ]   O_inst,             // 指令内容
    output  reg     [`InstAddrBus   ]   O_inst_addr,        // 指令地址
    output  reg                         O_rd_we,
    output  reg     [`RegAddrBus    ]   O_rd_waddr,
    output  reg     [`RegDataBus    ]   O_rd_wdata,
    output  reg     [`MemAddrBus    ]   O_memory_addr,
    output  reg     [`MemDataBus    ]   O_store_data,
    output  reg                         O_ls_valid,         // 访存有效标志
    output  reg     [`ls_diff_bus   ]   O_ls_type,
    output  reg                         O_csr_we,           // 写CSR寄存器标志
    output  reg     [`CSRAddrBus    ]   O_csr_waddr,        // 写CSR寄存器地址
    output  reg     [`CSRDataBus    ]   O_csr_wdata,        // 写CSR寄存器数据
    output  reg     [`Except_Bus    ]   O_except           // 异常

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
            O_ls_type       <= 0;
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
            O_ls_type       <= I_ls_type;
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
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire    [`InstBus       ]   I_inst,             // 指令内容
    input   wire    [`InstAddrBus   ]   I_inst_addr,        // 指令地址
    input   wire                        I_rd_we,
    input   wire    [`RegAddrBus    ]   I_rd_waddr,
    input   wire    [`RegDataBus    ]   I_rd_wdata,
    input   wire                        I_csr_we,           // 写CSR寄存器标志
    input   wire    [`CSRAddrBus    ]   I_csr_waddr,        // 写CSR寄存器地址
    input   wire    [`CSRDataBus    ]   I_csr_wdata,        // 写CSR寄存器数据
    input   wire    [`Except_Bus    ]   I_except,           // 异常

    input   wire                        I_device_skip,

    output  reg     [`InstBus       ]   O_inst,             // 指令内容
    output  reg     [`InstAddrBus   ]   O_inst_addr,        // 指令地址
    output  reg                         O_rd_we,
    output  reg     [`RegAddrBus    ]   O_rd_waddr,
    output  reg     [`RegDataBus    ]   O_rd_wdata,
    output  reg                         O_csr_we,           // 写CSR寄存器标志
    output  reg     [`CSRAddrBus    ]   O_csr_waddr,        // 写CSR寄存器地址
    output  reg     [`CSRDataBus    ]   O_csr_wdata,        // 写CSR寄存器数据
    output  reg     [`Except_Bus    ]   O_except,           // 异常

    output  wire                        O_device_skip

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