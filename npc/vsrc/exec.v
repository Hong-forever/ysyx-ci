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
    input   wire    [1:0                            ]   I_alu_srca_sel,
    input   wire    [1:0                            ]   I_alu_srcb_sel,
    input   wire    [1:0                            ]   I_agu_src_sel,
    input   wire                                        I_csr_src_sel,

    input   wire                                        I_ld_valid,         //访存有效标志
    input   wire                                        I_st_valid,         //访存有效标志
    input   wire                                        I_br_valid,        //跳转指令标志
    input   wire                                        I_csr_valid,        //CSR指令标志
    input   wire                                        I_f7b5_en,          //指令funct7=0x7b或0x5时有效
    input   wire                                        I_sign,             //有符号位
    input   wire    [2:0                            ]   I_op,

    input   wire    [11:0                           ]   I_csr_addr,

    input   wire    [31:0                           ]   I_rs1_rdata,
    input   wire    [31:0                           ]   I_rs2_rdata,
    input   wire    [31:0                           ]   I_csr_rdata,

    input   wire    [`ysyx_25110270_ExceptBus       ]   I_except,           //异常

    output  wire    [31:0                           ]   O_inst,
    output  wire    [31:0                           ]   O_inst_addr,

    output  wire                                        O_rd_we,
    output  wire    [`ysyx_25110270_RegAddrBus      ]   O_rd_waddr,
    output  wire    [31:0                           ]   O_rd_wdata,
    output  wire    [31:0                           ]   O_memory_addr,
    output  wire    [31:0                           ]   O_store_data,
    output  wire                                        O_ld_valid,         //访存有效标志
    output  wire                                        O_st_valid,         //访存有效标志
    output  wire    [2:0                            ]   O_ls_ctrl,

    output  wire                                        O_csr_valid,
    output  wire    [11:0                           ]   O_csr_addr,
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

    wire [31:0] csr_src = I_csr_src_sel ? I_imm : I_rs1_rdata;

    //------------------------------------------------------------------------
    // alu运算
    //------------------------------------------------------------------------
    wire src_neq, src_lt;
    wire [31:0] alu_result;

    wire [2:0] alu_op = (~I_op[2] & I_op[1] & I_op[0] & I_br_valid) ? `ysyx_25110270_RV32I_F3_ADD_SUB : I_op;  // jal, jalr指令需要加法运算

    ysyx_25110270_alu alu
    (
        .clk                        (clk                    ),
        .rst_n                      (rst_n                  ),
        .I_alu_srca                 (alu_srca               ),
        .I_alu_srcb                 (alu_srcb               ),
        .I_sign                     (I_sign                 ),
        .I_f7b5_en                  (I_f7b5_en              ),
        .I_alu_ctrl                 (alu_op                 ),
        .O_alu_result               (alu_result             ),
        .O_neq                      (src_neq                ),
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
        .I_src_neq                  (src_neq                ),
        .I_src_lt                   (src_lt                 ),
        .I_br_valid                 (I_br_valid             ),
        .I_bru_ctrl                 (I_op                   ),
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
        .I_csr_ctrl                 (I_op[1:0]              ),
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
    assign O_rd_wdata = I_csr_valid ? I_csr_rdata : alu_result;
    assign O_memory_addr = agu_result;
    assign O_store_data = I_rs2_rdata;

    assign O_ld_valid = I_ld_valid;
    assign O_st_valid = I_st_valid;
    assign O_ls_ctrl = I_op;

    assign O_csr_valid = I_csr_valid;
    assign O_csr_addr = I_csr_addr;
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
        if(I_br_valid & (I_op == 3'b011) & I_agu_src_sel == `ysyx_25110270_AGUSRC_PC) begin
            ftrace_exec(I_inst_addr, O_bru_target, rs1, O_rd_waddr, I_imm, 1);
        end else if(I_br_valid & (I_op == 3'b011) & I_agu_src_sel == `ysyx_25110270_AGUSRC_RS1) begin
            ftrace_exec(I_inst_addr, O_bru_target, rs1, O_rd_waddr, I_imm, 2);
        end
    end
`endif
    
endmodule //exu
