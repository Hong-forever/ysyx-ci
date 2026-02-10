`include "defines.v"

//------------------------------------------------------------------------
// 执行模块
//------------------------------------------------------------------------
module ysyx_25110270_exec
(
    input   wire                                        clk,
    input   wire                                        rst_n,

    input   wire    [31:0                           ]   I_inst,
    input   wire    [31:0                           ]   I_inst_addr,

    input   wire                                        I_valid,
    output  wire                                        O_ready,
    output  wire                                        O_valid,
    input   wire                                        I_ready,

    input   wire                                        I_rd_we,
    input   wire    [`ysyx_25110270_RegAddrBus      ]   I_rd_waddr,
    input   wire    [31:0                           ]   I_imm,
    input   wire                                        I_csr_we,
    input   wire    [12:0                           ]   I_csr_waddr,
    input   wire    [`ysyx_25110270_CSRCTL_BUS      ]   I_csr_ctrl,
    input   wire    [`ysyx_25110270_ALUCTL_BUS      ]   I_alu_ctrl,
    input   wire    [`ysyx_25110270_BRUCTL_BUS      ]   I_bru_ctrl,
    input   wire    [`ysyx_25110270_ALUSRCA_BUS     ]   I_alu_srca_sel,
    input   wire    [`ysyx_25110270_ALUSRCB_BUS     ]   I_alu_srcb_sel,
    input   wire    [`ysyx_25110270_AGUSRC_BUS      ]   I_agu_src_sel,
    input   wire    [`ysyx_25110270_CSRSRC_BUS      ]   I_csr_src_sel,
    input   wire                                        I_ls_valid,         //访存有效标志
    input   wire    [`ysyx_25110270_LSUCTL_BUS      ]   I_lsu_ctrl,

    input   wire    [31:0                           ]   I_rs1_rdata,
    input   wire    [31:0                           ]   I_rs2_rdata,
    input   wire    [31:0                           ]   I_csr_rdata,

    input   wire                                        I_csr_re,           //判断结果是否来自csr
    input   wire    [`ysyx_25110270_ExceptBus       ]   I_except,           //异常

    output  wire    [31:0                           ]   O_inst,
    output  wire    [31:0                           ]   O_inst_addr,

    output  wire                                        O_rd_we,
    output  wire    [`ysyx_25110270_RegAddrBus      ]   O_rd_waddr,
    output  wire    [31:0                           ]   O_rd_wdata,
    output  wire    [31:0                           ]   O_memory_addr,
    output  wire    [31:0                           ]   O_store_data,
    output  wire                                        O_ls_valid,         //访存有效标志
    output  wire    [`ysyx_25110270_LSUCTL_BUS      ]   O_lsu_ctrl,

    output  wire                                        O_csr_we,
    output  wire    [12:0                           ]   O_csr_waddr,
    output  wire    [31:0                           ]   O_csr_wdata,
    output  wire    [`ysyx_25110270_ExceptBus       ]   O_except,

    //bru
    output  wire                                        O_bru_taken,
    output  wire    [31:0                           ]   O_bru_target

);

    //------------------------------------------------------------------------
    // src选择
    //------------------------------------------------------------------------
    reg [31:0] alu_srca;
    reg [31:0] alu_srcb;
    reg [31:0] agu_src;
    reg [31:0] csr_src;

    always @(*) begin
        case(I_alu_srca_sel)
            `ysyx_25110270_ALUSRCA_RS1: alu_srca = I_rs1_rdata;
            `ysyx_25110270_ALUSRCA_PC:  alu_srca = I_inst_addr;
            default:                    alu_srca = 0;
        endcase
    end

    always @(*) begin
        case(I_alu_srcb_sel)
            `ysyx_25110270_ALUSRCB_RS2: alu_srcb = I_rs2_rdata;
            `ysyx_25110270_ALUSRCB_IMM: alu_srcb = I_imm;
            `ysyx_25110270_ALUSRCB_4:   alu_srcb = 4;
            default:                    alu_srcb = 0;
        endcase
    end

    always @(*) begin
        case(I_agu_src_sel)
            `ysyx_25110270_AGUSRC_RS1:  agu_src = I_rs1_rdata;
            `ysyx_25110270_AGUSRC_PC:   agu_src = I_inst_addr;
            default:                    agu_src = 0;
        endcase
    end

    always @(*) begin
        case(I_csr_src_sel)
            `ysyx_25110270_CSRSRC_RS1:  csr_src = I_rs1_rdata;
            `ysyx_25110270_CSRSRC_IMM:  csr_src = I_imm;
            default:                    csr_src = 0;
        endcase
    end

    //------------------------------------------------------------------------
    // alu运算
    //------------------------------------------------------------------------
    wire src_eq, src_lt;
    wire [31:0] alu_result;

    ysyx_25110270_alu alu
    (
        .clk                        (clk                    ),
        .rst_n                      (rst_n                  ),
        .I_alu_srca                 (alu_srca               ),
        .I_alu_srcb                 (alu_srcb               ),
        .I_alu_ctrl                 (I_alu_ctrl             ),
        .O_alu_result               (alu_result             ),
        .O_eq                       (src_eq                 ),
        .O_lt                       (src_lt                 )
    );

    //------------------------------------------------------------------------
    // agu运算
    //------------------------------------------------------------------------
    wire [31:0] agu_result;
    assign agu_result = agu_src + I_imm;

    //------------------------------------------------------------------------
    // bru运算
    //------------------------------------------------------------------------
    wire bru_taken;
    ysyx_25110270_bru bru
    (
        .I_src_eq                   (src_eq                 ),
        .I_src_lt                   (src_lt                 ),
        .I_bru_ctrl                 (I_bru_ctrl             ),
        .O_bru_taken                (bru_taken              )
    );

    //------------------------------------------------------------------------
    // csr运算
    //------------------------------------------------------------------------
    wire [31:0] csr_wdata;
    ysyx_25110270_csr csr
    (
        .I_csr_src                  (csr_src                ),
        .I_csr_rdata                (I_csr_rdata            ),
        .I_csr_ctrl                 (I_csr_ctrl             ),
        .O_csr_wdata                (csr_wdata              )
    );

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

    reg bru_taken_r;
    reg [31:0] agu_result_r;
    always @(posedge clk) begin
        if(!rst_n) begin
            bru_taken_r <= 0;
            agu_result_r <= 0;
        end else if(inst_valid) begin
            bru_taken_r <= bru_taken;
            agu_result_r <= agu_result;
        end
    end

    //------------------------------------------------------------------------
    // 输出
    //------------------------------------------------------------------------
    assign O_inst = I_inst;
    assign O_inst_addr = I_inst_addr;
    assign O_valid = inst_valid;
    assign O_ready = ready;

    assign O_rd_we = I_rd_we;
    assign O_rd_waddr = I_rd_waddr;
    assign O_rd_wdata = I_csr_re? I_csr_rdata : alu_result;
    assign O_memory_addr = agu_result;
    assign O_store_data = I_rs2_rdata;

    assign O_ls_valid = I_ls_valid;
    assign O_lsu_ctrl = I_lsu_ctrl;

    assign O_csr_we = I_csr_we;
    assign O_csr_waddr = I_csr_waddr;
    assign O_csr_wdata = csr_wdata;

    assign O_bru_taken = bru_taken_r;
    assign O_bru_target = agu_result_r;

    assign O_except = I_except;


`ifdef PERF
    import "DPI-C" function void exec_inst_cal();

    always @(posedge clk) begin
        if(inst_valid && (|I_inst) && (|I_inst_addr)) begin
            exec_inst_cal();
        end
    end

`endif


`ifdef DPIC
    import "DPI-C" function void ftrace_exec(input int pc, input int dnpc, input int rs1, input int rd, input int imm, input int op); //op=1 jal, op=2 jalr

    wire [3:0] rs1 = I_inst[18:15];

    always @(*) begin
        if (I_bru_ctrl == 1) begin
            ftrace_exec(I_inst_addr, O_bru_target, rs1, O_rd_waddr, I_imm, 1);
        end
        else if (I_bru_ctrl == 2) begin
            ftrace_exec(I_inst_addr, O_bru_target, rs1, O_rd_waddr, I_imm, 2);
        end
    end
`endif
    
endmodule //exu
