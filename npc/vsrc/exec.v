`include "defines.v"

//------------------------------------------------------------------------
// 执行模块
//------------------------------------------------------------------------
module ysyx_25110270_exec
(
    input   wire                                    clk,
    input   wire                                    rst,

    input   wire    [31:0                       ]   I_inst,
    input   wire    [31:0                       ]   I_inst_addr,

    input   wire                                    I_valid,
    output  wire                                    O_ready,
    output  wire                                    O_valid,

    input   wire                                    I_rd_we,
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rd_waddr,
    input   wire    [31:0                       ]   I_imm,
    input   wire    [1:0                        ]   I_alu_srca_sel,
    input   wire    [1:0                        ]   I_alu_srcb_sel,
    input   wire    [1:0                        ]   I_agu_src_sel,
    input   wire                                    I_csr_src_sel,

    input   wire    [31:0                       ]   I_pred_target,      //分支预测目标地址

    input   wire                                    I_ld_valid,         //访存有效标志
    input   wire                                    I_st_valid,         //访存有效标志
    input   wire                                    I_br_valid,         //跳转指令标志
    input   wire                                    I_csr_valid,        //CSR指令标志
    input   wire                                    I_f7b5_en,          //指令funct7=0x7b或0x5时有效
    input   wire                                    I_sign,             //有符号位
    input   wire    [2:0                        ]   I_op,
    input   wire    [`ysyx_25110270_CsrMapBus   ]   I_csr_addr,
    input   wire    [`ysyx_25110270_ExceptBus   ]   I_except,             //异常

    input   wire                                    I_fwd_ctrl_rs1,
    input   wire                                    I_fwd_ctrl_rs2,
    input   wire                                    I_fwd_ctrl_csr,

    input   wire    [31:0                       ]   I_rs1_rdata,
    input   wire    [31:0                       ]   I_rs2_rdata,
    input   wire    [31:0                       ]   I_csr_rdata,

    input   wire    [31:0                       ]   I_fwd_old_rs_data,      //转发的旧数据
    input   wire    [31:0                       ]   I_fwd_old_csr_data,     //转发的旧数据

    output  wire    [31:0                       ]   O_inst,
    output  wire    [31:0                       ]   O_inst_addr,

    output  wire                                    O_rd_we,
    output  wire    [`ysyx_25110270_RegAddrBus  ]   O_rd_waddr,
    output  wire    [31:0                       ]   O_rd_wdata,

    output  wire                                    O_csr_valid,
    output  wire    [`ysyx_25110270_CsrMapBus   ]   O_csr_addr,
    output  wire    [31:0                       ]   O_csr_wdata,

    output  wire    [`ysyx_25110270_ExceptBus   ]   O_except,

    output  wire                                    O_device_skip,

    //bru
    output  wire                                    O_btb_update,
    output  wire                                    O_bru_taken,
    output  wire    [31:0                       ]   O_bru_target,

    //to bus
    output  wire                                    dbus_awvalid,
    input   wire                                    dbus_awready,
    output  wire    [31:0]                          dbus_awaddr,
    output  wire    [3:0 ]                          dbus_awid,
    output  wire    [7:0 ]                          dbus_awlen,
    output  wire    [2:0 ]                          dbus_awsize,
    output  wire    [1:0 ]                          dbus_awburst,
    output  wire                                    dbus_wvalid,
    input   wire                                    dbus_wready,
    output  wire    [31:0]                          dbus_wdata,
    output  wire    [3:0 ]                          dbus_wstrb,
    output  wire                                    dbus_wlast,
    input   wire                                    dbus_bvalid,
    output  wire                                    dbus_bready,
    input   wire    [1:0 ]                          dbus_bresp,
    input   wire    [3:0 ]                          dbus_bid,
    output  wire                                    dbus_arvalid,
    input   wire                                    dbus_arready,
    output  wire    [31:0]                          dbus_araddr,
    output  wire    [3:0 ]                          dbus_arid,
    output  wire    [7:0 ]                          dbus_arlen,
    output  wire    [2:0 ]                          dbus_arsize,
    output  wire    [1:0 ]                          dbus_arburst,
    input   wire                                    dbus_rvalid,
    output  wire                                    dbus_rready,
    input   wire    [31:0]                          dbus_rdata,
    input   wire    [1:0 ]                          dbus_rresp,
    input   wire                                    dbus_rlast,
    input   wire    [3:0 ]                          dbus_rid

);
    //------------------------------------------------------------------------
    // fwd选择
    //------------------------------------------------------------------------
    wire [31:0] final_rs1_rdata = I_fwd_ctrl_rs1 ? I_fwd_old_rs_data : I_rs1_rdata;
    wire [31:0] final_rs2_rdata = I_fwd_ctrl_rs2 ? I_fwd_old_rs_data : I_rs2_rdata;
    wire [31:0] final_csr_rdata = I_fwd_ctrl_csr ? I_fwd_old_csr_data : I_csr_rdata;

    //------------------------------------------------------------------------
    // src选择
    //------------------------------------------------------------------------
    reg [31:0] alu_srca;
    reg [31:0] alu_srcb;
    reg [31:0] agu_src;

    reg btb_update;

    always @(*) begin
        case(I_alu_srca_sel)
            `ysyx_25110270_ALUSRCA_RS1: alu_srca = final_rs1_rdata;
            `ysyx_25110270_ALUSRCA_PC:  alu_srca = I_inst_addr;
            default:                    alu_srca = 0;
        endcase
    end

    always @(*) begin
        case(I_alu_srcb_sel)
            `ysyx_25110270_ALUSRCB_RS2: alu_srcb = final_rs2_rdata;
            `ysyx_25110270_ALUSRCB_IMM: alu_srcb = I_imm;
            `ysyx_25110270_ALUSRCB_4:   alu_srcb = 4;
            default:                    alu_srcb = 0;
        endcase
    end

    always @(*) begin
        case(I_agu_src_sel)
            `ysyx_25110270_AGUSRC_RS1: begin
                agu_src = final_rs1_rdata;
                btb_update = 1'b0;
            end
            `ysyx_25110270_AGUSRC_PC: begin
                agu_src = I_inst_addr;
                btb_update = 1'b1;
            end
            default: begin
                agu_src = 0;
                btb_update = 1;
            end
        endcase
    end

    wire [31:0] csr_src = I_csr_src_sel ? I_imm : final_rs1_rdata;

    //------------------------------------------------------------------------
    // alu运算
    //------------------------------------------------------------------------
    wire src_eq, src_lt;
    wire [31:0] alu_result;

    wire [2:0] alu_op = (I_op == 3'b011 & I_br_valid) ? `ysyx_25110270_RV32I_F3_ADD_SUB : I_op;  // jal, jalr指令需要加法运算

    ysyx_25110270_alu alu
    (
        .I_alu_srca                 (alu_srca               ),
        .I_alu_srcb                 (alu_srcb               ),
        .I_sign                     (I_sign                 ),
        .I_f7b5_en                  (I_f7b5_en              ),
        .I_alu_ctrl                 (alu_op                 ),
        .O_alu_result               (alu_result             ),
        .O_eq                       (src_eq                 ),
        .O_lt                       (src_lt                 )
    );

    //------------------------------------------------------------------------
    // agu运算
    //------------------------------------------------------------------------
    wire [31:0] agu_result, fix_addr_plus4;
    assign agu_result = agu_src + I_imm;
    assign fix_addr_plus4 = I_inst_addr + 4;

    //------------------------------------------------------------------------
    // bru运算
    //------------------------------------------------------------------------
    wire bru_taken;
    ysyx_25110270_bru bru
    (
        .I_src_eq                   (src_eq                 ),
        .I_src_lt                   (src_lt                 ),
        .I_bru_ctrl                 (I_op                   ),
        .O_bru_taken                (bru_taken              )
    );


    //------------------------------------------------------------------------
    // csr运算
    //------------------------------------------------------------------------
    wire [31:0] csr_wdata;
    ysyx_25110270_csr_exe csr_exe
    (
        .I_csr_src                  (csr_src                ),
        .I_csr_rdata                (I_csr_rdata            ),
        .I_csr_ctrl                 (I_op[1:0]              ),
        .O_csr_wdata                (csr_wdata              )
    );



    //------------------------------------------------------------------------
    // ex2 pipeline
    //------------------------------------------------------------------------
    reg [31:0] agu_result_r, fix_addr_plus4_r;
    reg bru_taken_r;
    reg br_valid_r;

    reg ld_valdi_r, st_valid_r;
    reg data_avalid;
    reg [31:0] store_data;
    reg [2:0] ls_ctrl;

    reg [31:0] rd_wdata;

    always @(posedge clk) begin
        if(rst) begin
            bru_taken_r <= 1'b0;
            ls_ctrl <= 0;
        end else begin
            bru_taken_r <= bru_taken;
            agu_result_r <= agu_result;
            fix_addr_plus4_r <= fix_addr_plus4;
            store_data <= final_rs2_rdata;
            ls_ctrl <= (I_ld_valid | I_st_valid) ? I_op : 3'b111;
        end
    end

    always @(posedge clk) begin
        if(rst) begin
            br_valid_r <= 1'b0;
        end else if(I_valid) begin
            br_valid_r <= 1'b0;
        end else begin
            br_valid_r <= I_br_valid;
        end
    end

    
    wire bru_taken_need = (bru_taken_r & (I_pred_target != agu_result_r));         //应该跳转，但是跳转错误
    wire bru_taken_noneed = (!bru_taken_r & (I_pred_target != fix_addr_plus4_r));  //不用跳转，但是跳转了
    wire bru_taken_final = (bru_taken_need | bru_taken_noneed) & br_valid_r; //最终是否需要跳转

    wire stallreq_br = I_br_valid & ~br_valid_r; //等待分支结果
    wire stallreq_ls;

    wire stallreq = stallreq_br | stallreq_ls;

    wire device_skip;

    ysyx_25110270_lsu lsu
    (
        .clk                        (clk                    ),
        .rst                        (rst                    ),

        .I_inst                     (I_inst                 ),
        .I_inst_addr                (I_inst_addr            ),

        .I_valid                    (I_valid                ),

        .I_alu_result               (alu_result             ),
        .I_csr_valid                (I_csr_valid            ),
        .I_csr_rdata                (final_csr_rdata        ),

        .I_ld_valid                 (I_ld_valid             ),
        .I_st_valid                 (I_st_valid             ),
        .I_ls_ctrl                  (ls_ctrl                ),
        .I_memory_addr              (agu_result_r           ),
        .I_store_data               (store_data             ),

        .O_rd_wdata                 (rd_wdata               ),
        .O_stallreq                 (stallreq_ls            ),
        .O_device_skip              (device_skip            ),

        .dbus_awvalid               (dbus_awvalid           ),
        .dbus_awready               (dbus_awready           ),
        .dbus_awaddr                (dbus_awaddr            ),
        .dbus_awid                  (dbus_awid              ),
        .dbus_awlen                 (dbus_awlen             ),
        .dbus_awsize                (dbus_awsize            ),
        .dbus_awburst               (dbus_awburst           ),
        .dbus_wvalid                (dbus_wvalid            ),
        .dbus_wready                (dbus_wready            ),
        .dbus_wdata                 (dbus_wdata             ),
        .dbus_wstrb                 (dbus_wstrb             ),
        .dbus_wlast                 (dbus_wlast             ),
        .dbus_bvalid                (dbus_bvalid            ),
        .dbus_bready                (dbus_bready            ),
        .dbus_bresp                 (dbus_bresp             ),
        .dbus_bid                   (dbus_bid               ),
        .dbus_arvalid               (dbus_arvalid           ),
        .dbus_arready               (dbus_arready           ),
        .dbus_araddr                (dbus_araddr            ),
        .dbus_arid                  (dbus_arid              ),
        .dbus_arlen                 (dbus_arlen             ),
        .dbus_arsize                (dbus_arsize            ),
        .dbus_arburst               (dbus_arburst           ),
        .dbus_rvalid                (dbus_rvalid            ),
        .dbus_rready                (dbus_rready            ),
        .dbus_rdata                 (dbus_rdata             ),
        .dbus_rresp                 (dbus_rresp             ),
        .dbus_rlast                 (dbus_rlast             ),
        .dbus_rid                   (dbus_rid               )
    );


    //------------------------------------------------------------------------
    // 输出
    //------------------------------------------------------------------------
    assign O_inst = I_inst;
    assign O_inst_addr = I_inst_addr;

    assign O_ready = ~stallreq;
    assign O_valid = O_ready;

    assign O_rd_we = I_rd_we;
    assign O_rd_waddr = I_rd_waddr;
    assign O_rd_wdata = rd_wdata;

    assign O_csr_valid = I_csr_valid;
    assign O_csr_addr = I_csr_addr;
    assign O_csr_wdata = csr_wdata;

    assign O_btb_update = btb_update & bru_taken_final;
    assign O_bru_taken = bru_taken_final;
    assign O_bru_target = bru_taken_need ? agu_result_r : fix_addr_plus4_r;

    assign O_except = I_except;
    assign O_device_skip = device_skip;

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

    reg stallreq_br_r;
    always @(posedge clk) begin
        if(rst) begin
            stallreq_br_r <= 1'b0;
        end else begin
            stallreq_br_r <= stallreq_br;
        end
    end
`endif

`ifdef PERF

    import "DPI-C" function void jump_br_cal(input int inst, input int pc, input int target, input int is_taken, input int is_taken_final, input int pred_target);

    always @(posedge clk) begin
        if(I_br_valid & stallreq_br_r) begin
            jump_br_cal(I_inst, I_inst_addr, agu_result_r, bru_taken_r, bru_taken_final, I_pred_target);
        end
    end

`endif

endmodule //exu
