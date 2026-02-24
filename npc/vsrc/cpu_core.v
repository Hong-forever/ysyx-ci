`include "defines.v"

//------------------------------------------------------------------------
// cpu core
//------------------------------------------------------------------------

module ysyx_25110270_cpu_core
(
    input   wire                        clk,
    input   wire                        rst,

    input   wire                        io_interrupt,

    output  wire                        io_master_awvalid,
    input   wire                        io_master_awready,
    output  wire    [31:0]              io_master_awaddr,
    output  wire    [3:0]               io_master_awid,
    output  wire    [7:0]               io_master_awlen,
    output  wire    [2:0]               io_master_awsize,
    output  wire    [1:0]               io_master_awburst,
    output  wire                        io_master_wvalid,
    input   wire                        io_master_wready,
    output  wire    [31:0]              io_master_wdata,
    output  wire    [3:0]               io_master_wstrb,
    output  wire                        io_master_wlast,
    input   wire                        io_master_bvalid,
    output  wire                        io_master_bready,
    input   wire    [1:0]               io_master_bresp,
    input   wire    [3:0]               io_master_bid,
    output  wire                        io_master_arvalid,
    input   wire                        io_master_arready,
    output  wire    [31:0]              io_master_araddr,
    output  wire    [3:0]               io_master_arid,
    output  wire    [7:0]               io_master_arlen,
    output  wire    [2:0]               io_master_arsize,
    output  wire    [1:0]               io_master_arburst,
    input   wire                        io_master_rvalid,
    output  wire                        io_master_rready,
    input   wire    [31:0]              io_master_rdata,
    input   wire    [1:0]               io_master_rresp,
    input   wire                        io_master_rlast,
    input   wire    [3:0]               io_master_rid
);

    //-------------------------------------------------------------
    // ifetch
    //-------------------------------------------------------------
    wire [31:0                      ]   O_if_inst;
    wire [31:0                      ]   O_if_inst_addr;
    wire                                O_if_valid;

    //-------------------------------------------------------------
    // pipeline_if_dec
    //-------------------------------------------------------------
    wire [31:0                      ]   I_dec_inst;
    wire [31:0                      ]   I_dec_inst_addr;

    //-------------------------------------------------------------
    // decoder
    //-------------------------------------------------------------
    wire [`ysyx_25110270_RegAddrBus ]   O_rs1_raddr;
    wire [`ysyx_25110270_RegAddrBus ]   O_rs2_raddr;
    wire [11:0                      ]   O_csr_addr;
    wire [31:0                      ]   I_rs1_rdata;
    wire [31:0                      ]   I_rs2_rdata;
    wire [31:0                      ]   I_csr_rdata;

    wire [31:0                      ]   O_dec_inst;
    wire [31:0                      ]   O_dec_inst_addr;
    wire                                O_dec_valid;
    wire                                O_dec_ready;
    wire [31:0                      ]   O_dec_imm;
    wire                                O_dec_rd_we;
    wire [`ysyx_25110270_RegAddrBus ]   O_dec_rd_waddr;
    wire [2:0                       ]   O_dec_op;
    wire [1:0                       ]   O_dec_alu_srca_sel;
    wire [1:0                       ]   O_dec_alu_srcb_sel;
    wire [1:0                       ]   O_dec_agu_src_sel;
    wire                                O_dec_csr_src_sel;
    wire                                O_dec_ld_valid;
    wire                                O_dec_st_valid;
    wire                                O_dec_br_valid;
    wire                                O_dec_csr_valid;
    wire                                O_dec_f7b5_en;
    wire                                O_dec_sign;
    wire [`ysyx_25110270_ExceptBus  ]   O_dec_except;

    //-------------------------------------------------------------
    // pipeline_dec_ex
    //-------------------------------------------------------------
    wire [31:0                      ]   I_ex_inst;
    wire [31:0                      ]   I_ex_inst_addr;

    wire [31:0                      ]   I_ex_rs1_rdata;
    wire [31:0                      ]   I_ex_rs2_rdata;
    wire [31:0                      ]   I_ex_csr_rdata;

    wire [31:0                      ]   I_ex_imm;
    wire                                I_ex_rd_we;
    wire [`ysyx_25110270_RegAddrBus ]   I_ex_rd_waddr;
    wire [1:0                       ]   I_ex_alu_srca_sel;
    wire [1:0                       ]   I_ex_alu_srcb_sel;
    wire [1:0                       ]   I_ex_agu_src_sel;
    wire                                I_ex_csr_src_sel;
    wire                                I_ex_ld_valid;
    wire                                I_ex_st_valid;
    wire                                I_ex_br_valid;
    wire                                I_ex_csr_valid;
    wire                                I_ex_f7b5_en;
    wire                                I_ex_sign;
    wire [2:0                       ]   I_ex_op;

    wire [11:0                      ]   I_ex_csr_addr;

    wire [`ysyx_25110270_ExceptBus  ]   I_ex_except;

    //-------------------------------------------------------------
    // hazard_unit
    //-------------------------------------------------------------
    wire                                O_dec_rs1_re;
    wire                                O_dec_rs2_re;

    wire [1:0                       ]   dec_fwd_ctrl_rs1;
    wire [1:0                       ]   dec_fwd_ctrl_rs2;
    wire [1:0                       ]   dec_fwd_ctrl_csr;

    wire [1:0                       ]   ex_fwd_ctrl_rs1;
    wire [1:0                       ]   ex_fwd_ctrl_rs2;
    wire [1:0                       ]   ex_fwd_ctrl_csr;

    wire                                stallreq_dec;

    wire [31:0                      ]   fwd_old_rs_data;
    wire [31:0                      ]   fwd_old2_rs_data;
    wire [31:0                      ]   fwd_old_csr_data;
    wire [31:0                      ]   fwd_old2_csr_data;


    //-------------------------------------------------------------
    // exec
    //-------------------------------------------------------------
    wire                                O_ex_bru_taken;
    wire [31:0                      ]   O_ex_bru_target;

    wire [31:0                      ]   O_ex_inst;
    wire [31:0                      ]   O_ex_inst_addr;
    wire                                O_ex_valid;
    wire                                O_ex_ready;

    wire                                O_ex_rd_we;
    wire [`ysyx_25110270_RegAddrBus ]   O_ex_rd_waddr;
    wire [31:0                      ]   O_ex_rd_wdata;
    wire [31:0                      ]   O_ex_memory_addr;
    wire [31:0                      ]   O_ex_store_data;
    wire                                O_ex_ld_valid;
    wire                                O_ex_st_valid;
    wire [2:0                       ]   O_ex_ls_ctrl;
    wire                                O_ex_csr_valid;
    wire [11:0                      ]   O_ex_csr_addr;
    wire [31:0                      ]   O_ex_csr_wdata;
    wire [`ysyx_25110270_ExceptBus  ]   O_ex_except;


    //-------------------------------------------------------------
    // pipeline_ex_ls
    //-------------------------------------------------------------
    wire [31:0                      ]   I_ls_inst;
    wire [31:0                      ]   I_ls_inst_addr;
    wire                                I_ls_rd_we;
    wire [`ysyx_25110270_RegAddrBus ]   I_ls_rd_waddr;
    wire [31:0                      ]   I_ls_rd_wdata;
    wire [31:0                      ]   I_ls_memory_addr;
    wire [31:0                      ]   I_ls_store_data;
    wire                                I_ls_ld_valid;
    wire                                I_ls_st_valid;
    wire [2:0                       ]   I_ls_ls_ctrl;
    wire                                I_ls_csr_valid;
    wire [11:0                      ]   I_ls_csr_addr;
    wire [31:0                      ]   I_ls_csr_wdata;
    wire [`ysyx_25110270_ExceptBus  ]   I_ls_except;


    //-------------------------------------------------------------
    // ls
    //-------------------------------------------------------------
    wire [31:0                      ]   O_ls_inst;
    wire [31:0                      ]   O_ls_inst_addr;
    wire                                O_ls_valid;
    wire                                O_ls_ready;
    wire                                O_ls_rd_we;
    wire [`ysyx_25110270_RegAddrBus ]   O_ls_rd_waddr;
    wire [31:0                      ]   O_ls_rd_wdata;
    wire                                O_ls_csr_valid;
    wire [11:0                      ]   O_ls_csr_addr;
    wire [31:0                      ]   O_ls_csr_wdata;
    wire [`ysyx_25110270_ExceptBus  ]   O_ls_except;

    //-------------------------------------------------------------
    // pipeline_ls_wb
    //-------------------------------------------------------------
    wire [31:0                      ]   I_wb_inst;
    wire [31:0                      ]   I_wb_inst_addr;
    wire                                I_wb_rd_we;
    wire [`ysyx_25110270_RegAddrBus ]   I_wb_rd_waddr;
    wire [31:0                      ]   I_wb_rd_wdata;
    wire                                I_wb_csr_valid;
    wire [11:0                      ]   I_wb_csr_addr;
    wire [31:0                      ]   I_wb_csr_wdata;
    wire [`ysyx_25110270_ExceptBus  ]   I_wb_except;

    //-------------------------------------------------------------
    // wb
    //-------------------------------------------------------------
    wire                                O_flush;
    wire [31:0                      ]   O_flush_addr;

    //-------------------------------------------------------------
    // instantiate modules
    //-------------------------------------------------------------
    wire lsu_device_skip;
    wire wbu_device_skip;

    //ibus
    wire                                ibus_awvalid;
    wire                                ibus_awready;
    wire [31:0]                         ibus_awaddr;
    wire [3:0 ]                         ibus_awid;
    wire [7:0 ]                         ibus_awlen;
    wire [2:0 ]                         ibus_awsize;
    wire [1:0 ]                         ibus_awburst;
    wire                                ibus_wvalid;
    wire                                ibus_wready;
    wire [31:0]                         ibus_wdata;
    wire [3:0 ]                         ibus_wstrb;
    wire                                ibus_wlast;
    wire                                ibus_bvalid;
    wire                                ibus_bready;
    wire [1:0]                          ibus_bresp;
    wire [3:0 ]                         ibus_bid;
    wire                                ibus_arvalid;
    wire                                ibus_arready;
    wire [31:0]                         ibus_araddr;
    wire [3:0 ]                         ibus_arid;
    wire [7:0 ]                         ibus_arlen;
    wire [2:0 ]                         ibus_arsize;
    wire [1:0 ]                         ibus_arburst;
    wire                                ibus_rvalid;
    wire                                ibus_rready;
    wire [31:0]                         ibus_rdata;
    wire [1:0]                          ibus_rresp;
    wire                                ibus_rlast;
    wire [3:0 ]                         ibus_rid;

    //dbus
    wire                                dbus_awvalid;
    wire                                dbus_awready;
    wire [31:0]                         dbus_awaddr;
    wire [3:0 ]                         dbus_awid;
    wire [7:0 ]                         dbus_awlen;
    wire [2:0 ]                         dbus_awsize;
    wire [1:0 ]                         dbus_awburst;
    wire                                dbus_wvalid;
    wire                                dbus_wready;
    wire [31:0]                         dbus_wdata;
    wire [3:0 ]                         dbus_wstrb;
    wire                                dbus_wlast;
    wire                                dbus_bvalid;
    wire                                dbus_bready;
    wire [1:0]                          dbus_bresp;
    wire [3:0 ]                         dbus_bid;
    wire                                dbus_arvalid;
    wire                                dbus_arready;
    wire [31:0]                         dbus_araddr;
    wire [3:0 ]                         dbus_arid;
    wire [7:0 ]                         dbus_arlen;
    wire [2:0 ]                         dbus_arsize;
    wire [1:0 ]                         dbus_arburst;
    wire                                dbus_rvalid;
    wire                                dbus_rready;
    wire [31:0]                         dbus_rdata;
    wire [1:0]                          dbus_rresp;
    wire                                dbus_rlast;
    wire [3:0 ]                         dbus_rid;

    wire ifu_fence_i = O_ex_except[`ysyx_25110270_EXCPT_FENCE_I];
    ysyx_25110270_ifetch u_ifetch
    (
        .clk                    (clk                        ),
        .rst                    (rst                        ),

        .I_bru_taken            (O_ex_bru_taken             ),
        .I_bru_target           (O_ex_bru_target            ),

        .I_ready                (O_dec_ready                ),
        .O_valid                (O_if_valid                 ),

        .I_flush                (O_flush                    ),
        .I_flush_addr           (O_flush_addr               ),

        .I_fence_i              (ifu_fence_i                ),

        .O_inst                 (O_if_inst                  ),
        .O_inst_addr            (O_if_inst_addr             ),
        
        //to bus
        .ibus_awvalid           (ibus_awvalid               ),
        .ibus_awready           (ibus_awready               ),
        .ibus_awaddr            (ibus_awaddr                ),
        .ibus_awid              (ibus_awid                  ),
        .ibus_awlen             (ibus_awlen                 ),
        .ibus_awsize            (ibus_awsize                ),
        .ibus_awburst           (ibus_awburst               ),
        .ibus_wvalid            (ibus_wvalid                ),
        .ibus_wready            (ibus_wready                ),
        .ibus_wdata             (ibus_wdata                 ),
        .ibus_wstrb             (ibus_wstrb                 ),
        .ibus_wlast             (ibus_wlast                 ),
        .ibus_bvalid            (ibus_bvalid                ),
        .ibus_bready            (ibus_bready                ),
        .ibus_bresp             (ibus_bresp                 ),
        .ibus_bid               (ibus_bid                   ),
        .ibus_arvalid           (ibus_arvalid               ),
        .ibus_arready           (ibus_arready               ),
        .ibus_araddr            (ibus_araddr                ),
        .ibus_arid              (ibus_arid                  ),
        .ibus_arlen             (ibus_arlen                 ),
        .ibus_arsize            (ibus_arsize                ),
        .ibus_arburst           (ibus_arburst               ),
        .ibus_rvalid            (ibus_rvalid                ),
        .ibus_rready            (ibus_rready                ),
        .ibus_rdata             (ibus_rdata                 ),
        .ibus_rresp             (ibus_rresp                 ),
        .ibus_rlast             (ibus_rlast                 ),
        .ibus_rid               (ibus_rid                   )
    );

    ysyx_25110270_decoder u_decoder
    (
        .clk                    (clk                        ),
        .rst                    (rst                        ),

        .I_inst                 (I_dec_inst                 ),
        .I_inst_addr            (I_dec_inst_addr            ),

        .I_ready                (O_ex_ready & ~stallreq_dec ),
        .O_ready                (O_dec_ready                ),
        .O_valid                (O_dec_valid                ),

        .O_rs1_raddr            (O_rs1_raddr                ),
        .O_rs2_raddr            (O_rs2_raddr                ),
        .O_csr_addr             (O_csr_addr                 ),

        .O_inst                 (O_dec_inst                 ),
        .O_inst_addr            (O_dec_inst_addr            ),

        .O_imm                  (O_dec_imm                  ),
        .O_rd_we                (O_dec_rd_we                ),
        .O_rd_waddr             (O_dec_rd_waddr             ),
        .O_op                   (O_dec_op                   ),
        .O_alu_srca_sel         (O_dec_alu_srca_sel         ),
        .O_alu_srcb_sel         (O_dec_alu_srcb_sel         ),
        .O_agu_src_sel          (O_dec_agu_src_sel          ),
        .O_csr_src_sel          (O_dec_csr_src_sel          ),
        .O_ld_valid             (O_dec_ld_valid             ),
        .O_st_valid             (O_dec_st_valid             ),
        .O_br_valid             (O_dec_br_valid             ),
        .O_csr_valid            (O_dec_csr_valid            ),
        .O_f7b5_en              (O_dec_f7b5_en              ),
        .O_sign                 (O_dec_sign                 ),
        .O_except               (O_dec_except               ), 

        .O_rs1_re               (O_dec_rs1_re               ),
        .O_rs2_re               (O_dec_rs2_re               )
    );

    ysyx_25110270_hazard_unit u_hazard_unit
    (
        .I_rs1_re               (O_dec_rs1_re               ),
        .I_rs2_re               (O_dec_rs2_re               ),

        .I_rs1_raddr            (O_rs1_raddr                ),
        .I_rs2_raddr            (O_rs2_raddr                ),

        .I_ex_rd_we             (I_ex_rd_we                 ),
        .I_ex_rd_waddr          (I_ex_rd_waddr              ),

        .I_ls_rd_we             (I_ls_rd_we                 ),
        .I_ls_rd_waddr          (I_ls_rd_waddr              ),

        .I_csr_valid            (O_dec_csr_valid            ),
        .I_csr_raddr            (O_csr_addr                 ),
        .I_ex_csr_waddr         (I_ex_csr_addr              ),
        .I_ls_csr_waddr         (I_ls_csr_addr              ),

        .I_ex_ld_valid          (I_ex_ld_valid              ),
        .I_bru_taken            (O_ex_bru_taken             ),

        .O_fwd_ctrl_rs1         (dec_fwd_ctrl_rs1           ),
        .O_fwd_ctrl_rs2         (dec_fwd_ctrl_rs2           ),
        .O_fwd_ctrl_csr         (dec_fwd_ctrl_csr           ),
        .O_stallreq             (stallreq_dec               )
    );

    ysyx_25110270_exec u_exec
    (
        .clk                    (clk                        ),
        .rst                    (rst                        ),

        .I_inst                 (I_ex_inst                  ),
        .I_inst_addr            (I_ex_inst_addr             ),

        .I_ready                (O_ls_ready                 ),
        .O_ready                (O_ex_ready                 ),
        .O_valid                (O_ex_valid                 ),

        .I_rd_we                (I_ex_rd_we                 ),
        .I_rd_waddr             (I_ex_rd_waddr              ),
        .I_imm                  (I_ex_imm                   ),
        .I_alu_srca_sel         (I_ex_alu_srca_sel          ),
        .I_alu_srcb_sel         (I_ex_alu_srcb_sel          ),
        .I_agu_src_sel          (I_ex_agu_src_sel           ),
        .I_csr_src_sel          (I_ex_csr_src_sel           ),
        .I_ld_valid             (I_ex_ld_valid              ),
        .I_st_valid             (I_ex_st_valid              ),
        .I_br_valid             (I_ex_br_valid              ),
        .I_csr_valid            (I_ex_csr_valid             ),
        .I_f7b5_en              (I_ex_f7b5_en               ),
        .I_sign                 (I_ex_sign                  ),
        .I_op                   (I_ex_op                    ),
        .I_csr_addr             (I_ex_csr_addr              ),
        .I_except               (I_ex_except                ),

        .I_fwd_ctrl_rs1         (ex_fwd_ctrl_rs1            ),
        .I_fwd_ctrl_rs2         (ex_fwd_ctrl_rs2            ),
        .I_fwd_ctrl_csr         (ex_fwd_ctrl_csr            ),

        .I_rs1_rdata            (I_ex_rs1_rdata             ),
        .I_rs2_rdata            (I_ex_rs2_rdata             ),
        .I_csr_rdata            (I_ex_csr_rdata             ),

        .I_fwd_old_rs_data      (fwd_old_rs_data            ),
        .I_fwd_old2_rs_data     (fwd_old2_rs_data           ),
        .I_fwd_old_csr_data     (fwd_old_csr_data           ),
        .I_fwd_old2_csr_data    (fwd_old2_csr_data          ),

        .O_inst                 (O_ex_inst                  ),
        .O_inst_addr            (O_ex_inst_addr             ),

        .O_rd_we                (O_ex_rd_we                 ),
        .O_rd_waddr             (O_ex_rd_waddr              ),
        .O_rd_wdata             (O_ex_rd_wdata              ),
        .O_memory_addr          (O_ex_memory_addr           ),
        .O_store_data           (O_ex_store_data            ),
        .O_ld_valid             (O_ex_ld_valid              ),
        .O_st_valid             (O_ex_st_valid              ),
        .O_ls_ctrl              (O_ex_ls_ctrl               ),

        .O_csr_valid            (O_ex_csr_valid             ),
        .O_csr_addr             (O_ex_csr_addr              ),
        .O_csr_wdata            (O_ex_csr_wdata             ),
        .O_except               (O_ex_except                ),
        .O_bru_taken            (O_ex_bru_taken             ),
        .O_bru_target           (O_ex_bru_target            )
    );

    ysyx_25110270_lsu u_lsu
    (
        .clk                    (clk                        ),
        .rst                    (rst                        ),

        .I_inst                 (I_ls_inst                  ),
        .I_inst_addr            (I_ls_inst_addr             ),

        .I_valid                (ex_enable                  ),
        .O_ready                (O_ls_ready                 ),
        .O_valid                (O_ls_valid                 ),

        .I_rd_we                (I_ls_rd_we                 ),
        .I_rd_waddr             (I_ls_rd_waddr              ),
        .I_rd_wdata             (I_ls_rd_wdata              ),
        .I_memory_addr          (I_ls_memory_addr           ),
        .I_store_data           (I_ls_store_data            ),
        .I_ld_valid             (I_ls_ld_valid              ),
        .I_st_valid             (I_ls_st_valid              ),
        .I_ls_ctrl              (I_ls_ls_ctrl               ),
        .I_csr_valid            (I_ls_csr_valid             ),
        .I_csr_addr             (I_ls_csr_addr              ),
        .I_csr_wdata            (I_ls_csr_wdata             ),
        .I_except               (I_ls_except                ),

        .I_is_ldst              (O_ex_ld_valid|O_ex_st_valid),

        .O_device_skip          (lsu_device_skip            ),

        .O_inst                 (O_ls_inst                  ),
        .O_inst_addr            (O_ls_inst_addr             ),
        .O_rd_we                (O_ls_rd_we                 ),
        .O_rd_waddr             (O_ls_rd_waddr              ),
        .O_rd_wdata             (O_ls_rd_wdata              ),
        .O_csr_valid            (O_ls_csr_valid             ),
        .O_csr_addr             (O_ls_csr_addr              ),
        .O_csr_wdata            (O_ls_csr_wdata             ),
        .O_except               (O_ls_except                ),

        //to bus
        .dbus_awvalid           (dbus_awvalid               ),
        .dbus_awready           (dbus_awready               ),
        .dbus_awaddr            (dbus_awaddr                ),
        .dbus_awid              (dbus_awid                  ),
        .dbus_awlen             (dbus_awlen                 ),
        .dbus_awsize            (dbus_awsize                ),
        .dbus_awburst           (dbus_awburst               ),
        .dbus_wvalid            (dbus_wvalid                ),
        .dbus_wready            (dbus_wready                ),
        .dbus_wdata             (dbus_wdata                 ),
        .dbus_wstrb             (dbus_wstrb                 ),
        .dbus_wlast             (dbus_wlast                 ),
        .dbus_bvalid            (dbus_bvalid                ),
        .dbus_bready            (dbus_bready                ),
        .dbus_bresp             (dbus_bresp                 ),
        .dbus_bid               (dbus_bid                   ),
        .dbus_arvalid           (dbus_arvalid               ),
        .dbus_arready           (dbus_arready               ),
        .dbus_araddr            (dbus_araddr                ),
        .dbus_arid              (dbus_arid                  ),
        .dbus_arlen             (dbus_arlen                 ),
        .dbus_arsize            (dbus_arsize                ),
        .dbus_arburst           (dbus_arburst               ),
        .dbus_rvalid            (dbus_rvalid                ),
        .dbus_rready            (dbus_rready                ),
        .dbus_rdata             (dbus_rdata                 ),
        .dbus_rresp             (dbus_rresp                 ),
        .dbus_rlast             (dbus_rlast                 ),
        .dbus_rid               (dbus_rid                   )
    );

    ysyx_25110270_wbu u_wbu
    (
        .clk                    (clk                        ),
        .rst                    (rst                        ),

        .I_inst                 (I_wb_inst                  ),
        .I_inst_addr            (I_wb_inst_addr             ),

        .I_valid                (ls_enable                  ),

        .I_rs1_raddr            (O_rs1_raddr                ),
        .I_rs2_raddr            (O_rs2_raddr                ),
        .O_rs1_rdata            (I_rs1_rdata                ),
        .O_rs2_rdata            (I_rs2_rdata                ),
        .I_csr_raddr            (O_csr_addr                 ),
        .O_csr_rdata            (I_csr_rdata                ),

        .I_rd_we                (I_wb_rd_we                 ),
        .I_rd_waddr             (I_wb_rd_waddr              ),
        .I_rd_wdata             (I_wb_rd_wdata              ),

        .I_csr_valid            (I_wb_csr_valid             ),
        .I_csr_waddr            (I_wb_csr_addr              ),
        .I_csr_wdata            (I_wb_csr_wdata             ),

        .I_except               (I_wb_except                ),
        .I_except_addr          (I_wb_inst_addr             ),
        .I_next_inst_addr       (I_ls_inst_addr             ),

        .O_flush                (O_flush                    ),
        .O_flush_addr           (O_flush_addr               ),

        .I_if_addr              (O_if_inst_addr             ),
        .I_dec_addr             (O_dec_inst_addr            ),
        .I_ex_addr              (O_ex_inst_addr             ),
        .I_ls_addr              (O_ls_inst_addr             ),

        .I_device_skip          (wbu_device_skip            )
    );

    ysyx_25110270_arbiter arbiter_inst 
    (
        .clk                    (clk                        ),
        .rst                    (rst                        ),

        .M0_awvalid             (ibus_awvalid               ),
        .M0_awready             (ibus_awready               ),
        .M0_awaddr              (ibus_awaddr                ),
        .M0_awid                (ibus_awid                  ),
        .M0_awlen               (ibus_awlen                 ),
        .M0_awsize              (ibus_awsize                ),
        .M0_awburst             (ibus_awburst               ),
        .M0_wvalid              (ibus_wvalid                ),
        .M0_wready              (ibus_wready                ),
        .M0_wdata               (ibus_wdata                 ),
        .M0_wstrb               (ibus_wstrb                 ),
        .M0_wlast               (ibus_wlast                 ),
        .M0_bvalid              (ibus_bvalid                ),
        .M0_bready              (ibus_bready                ),
        .M0_bresp               (ibus_bresp                 ),
        .M0_bid                 (ibus_bid                   ),
        .M0_arvalid             (ibus_arvalid               ),
        .M0_arready             (ibus_arready               ),
        .M0_araddr              (ibus_araddr                ),
        .M0_arid                (ibus_arid                  ),
        .M0_arlen               (ibus_arlen                 ),
        .M0_arsize              (ibus_arsize                ),
        .M0_arburst             (ibus_arburst               ),
        .M0_rvalid              (ibus_rvalid                ),
        .M0_rready              (ibus_rready                ),
        .M0_rdata               (ibus_rdata                 ),
        .M0_rresp               (ibus_rresp                 ),
        .M0_rlast               (ibus_rlast                 ),
        .M0_rid                 (ibus_rid                   ),

        .M1_awvalid             (dbus_awvalid               ),
        .M1_awready             (dbus_awready               ),
        .M1_awaddr              (dbus_awaddr                ),
        .M1_awid                (dbus_awid                  ),
        .M1_awlen               (dbus_awlen                 ),
        .M1_awsize              (dbus_awsize                ),
        .M1_awburst             (dbus_awburst               ),
        .M1_wvalid              (dbus_wvalid                ),
        .M1_wready              (dbus_wready                ),
        .M1_wdata               (dbus_wdata                 ),
        .M1_wstrb               (dbus_wstrb                 ),
        .M1_wlast               (dbus_wlast                 ),
        .M1_bvalid              (dbus_bvalid                ),
        .M1_bready              (dbus_bready                ),
        .M1_bresp               (dbus_bresp                 ),
        .M1_bid                 (dbus_bid                   ),
        .M1_arvalid             (dbus_arvalid               ),
        .M1_arready             (dbus_arready               ),
        .M1_araddr              (dbus_araddr                ),
        .M1_arid                (dbus_arid                  ),
        .M1_arlen               (dbus_arlen                 ),
        .M1_arsize              (dbus_arsize                ),
        .M1_arburst             (dbus_arburst               ),
        .M1_rvalid              (dbus_rvalid                ),
        .M1_rready              (dbus_rready                ),
        .M1_rdata               (dbus_rdata                 ),
        .M1_rresp               (dbus_rresp                 ),
        .M1_rlast               (dbus_rlast                 ),
        .M1_rid                 (dbus_rid                   ),

        .M_awvalid              (io_master_awvalid          ),
        .M_awready              (io_master_awready          ),
        .M_awaddr               (io_master_awaddr           ),
        .M_awid                 (io_master_awid             ),
        .M_awlen                (io_master_awlen            ),
        .M_awsize               (io_master_awsize           ),
        .M_awburst              (io_master_awburst          ),
        .M_wvalid               (io_master_wvalid           ),
        .M_wready               (io_master_wready           ),
        .M_wdata                (io_master_wdata            ),
        .M_wstrb                (io_master_wstrb            ),
        .M_wlast                (io_master_wlast            ),
        .M_bvalid               (io_master_bvalid           ),
        .M_bready               (io_master_bready           ),
        .M_bresp                (io_master_bresp            ),
        .M_bid                  (io_master_bid              ),
        .M_arvalid              (io_master_arvalid          ),
        .M_arready              (io_master_arready          ),
        .M_araddr               (io_master_araddr           ),
        .M_arid                 (io_master_arid             ),
        .M_arlen                (io_master_arlen            ),
        .M_arsize               (io_master_arsize           ),
        .M_arburst              (io_master_arburst          ),
        .M_rvalid               (io_master_rvalid           ),
        .M_rready               (io_master_rready           ),
        .M_rdata                (io_master_rdata            ),
        .M_rresp                (io_master_rresp            ),
        .M_rlast                (io_master_rlast            ),
        .M_rid                  (io_master_rid              )
    );


    //------------------------------------------------------------------------
    // PIPELINE
    //------------------------------------------------------------------------

    wire cpu_execute = O_if_valid;

    wire if_enable = O_if_valid;
    wire if_flush = (O_flush | (O_ex_bru_taken & O_ls_ready)) & cpu_execute;

    ysyx_25110270_pipeline_if_dec u_pipeline_if_dec
    (
        .clk                    (clk                        ),
        .rst                    (rst                        ),

        .I_inst                 (O_if_inst                  ),
        .I_inst_addr            (O_if_inst_addr             ),

        .O_inst                 (I_dec_inst                 ),
        .O_inst_addr            (I_dec_inst_addr            ),

        .I_enable               (if_enable                  ),
        .I_flush                (if_flush                   )
    );

    wire dec_buble = stallreq_dec & O_ex_ready;

    wire dec_enable = O_dec_valid & cpu_execute;
    wire dec_flush = ((O_flush | (O_ex_bru_taken & O_ls_ready)) & cpu_execute) | dec_buble;

    ysyx_25110270_pipeline_dec_ex u_pipeline_dec_ex
    (
        .clk                    (clk                        ),
        .rst                    (rst                        ),

        .I_inst                 (O_dec_inst                 ),
        .I_inst_addr            (O_dec_inst_addr            ),
        .I_rs1_rdata            (I_rs1_rdata                ),
        .I_rs2_rdata            (I_rs2_rdata                ),
        .I_csr_rdata            (I_csr_rdata                ),
        .I_imm                  (O_dec_imm                  ),
        .I_rd_we                (O_dec_rd_we                ),
        .I_rd_waddr             (O_dec_rd_waddr             ),
        .I_op                   (O_dec_op                   ),
        .I_alu_srca_sel         (O_dec_alu_srca_sel         ),
        .I_alu_srcb_sel         (O_dec_alu_srcb_sel         ),
        .I_agu_src_sel          (O_dec_agu_src_sel          ),
        .I_csr_src_sel          (O_dec_csr_src_sel          ),
        .I_ld_valid             (O_dec_ld_valid             ),
        .I_st_valid             (O_dec_st_valid             ),
        .I_br_valid             (O_dec_br_valid             ),
        .I_csr_valid            (O_dec_csr_valid            ),
        .I_csr_addr             (O_csr_addr                 ),
        .I_f7b5_en              (O_dec_f7b5_en              ),
        .I_sign                 (O_dec_sign                 ),
        .I_except               (O_dec_except               ),
        .I_fwd_ctrl_rs1         (dec_fwd_ctrl_rs1           ),
        .I_fwd_ctrl_rs2         (dec_fwd_ctrl_rs2           ),
        .I_fwd_ctrl_csr         (dec_fwd_ctrl_csr           ),

        .O_inst                 (I_ex_inst                  ),
        .O_inst_addr            (I_ex_inst_addr             ),
        .O_rs1_rdata            (I_ex_rs1_rdata             ),
        .O_rs2_rdata            (I_ex_rs2_rdata             ),
        .O_csr_rdata            (I_ex_csr_rdata             ),
        .O_imm                  (I_ex_imm                   ),
        .O_rd_we                (I_ex_rd_we                 ),
        .O_rd_waddr             (I_ex_rd_waddr              ),
        .O_op                   (I_ex_op                    ),
        .O_alu_srca_sel         (I_ex_alu_srca_sel          ),
        .O_alu_srcb_sel         (I_ex_alu_srcb_sel          ),
        .O_agu_src_sel          (I_ex_agu_src_sel           ),
        .O_csr_src_sel          (I_ex_csr_src_sel           ),
        .O_ld_valid             (I_ex_ld_valid              ),
        .O_st_valid             (I_ex_st_valid              ),
        .O_br_valid             (I_ex_br_valid              ),
        .O_csr_valid            (I_ex_csr_valid             ),
        .O_csr_addr             (I_ex_csr_addr              ),
        .O_f7b5_en              (I_ex_f7b5_en               ),
        .O_sign                 (I_ex_sign                  ),
        .O_except               (I_ex_except                ),
        .O_fwd_ctrl_rs1         (ex_fwd_ctrl_rs1            ),
        .O_fwd_ctrl_rs2         (ex_fwd_ctrl_rs2            ),
        .O_fwd_ctrl_csr         (ex_fwd_ctrl_csr            ),

        .I_enable               (dec_enable                 ),
        .I_flush                (dec_flush                  )
    );

    wire ex_enable = (O_ex_valid & cpu_execute) | dec_buble;
    wire ex_flush = (O_flush & cpu_execute);

    ysyx_25110270_pipeline_ex_ls u_pipeline_ex_ls
    (
        .clk                    (clk                        ),
        .rst                    (rst                        ),

        .I_inst                 (O_ex_inst                  ),
        .I_inst_addr            (O_ex_inst_addr             ),
        .I_rd_we                (O_ex_rd_we                 ),
        .I_rd_waddr             (O_ex_rd_waddr              ),
        .I_rd_wdata             (O_ex_rd_wdata              ),
        .I_memory_addr          (O_ex_memory_addr           ),
        .I_store_data           (O_ex_store_data            ),
        .I_ld_valid             (O_ex_ld_valid              ),
        .I_st_valid             (O_ex_st_valid              ),
        .I_ls_ctrl              (O_ex_ls_ctrl               ),
        .I_csr_valid            (O_ex_csr_valid             ),
        .I_csr_addr             (O_ex_csr_addr              ),
        .I_csr_wdata            (O_ex_csr_wdata             ),
        .I_except               (O_ex_except                ),

        .O_inst                 (I_ls_inst                  ),
        .O_inst_addr            (I_ls_inst_addr             ),
        .O_rd_we                (I_ls_rd_we                 ),
        .O_rd_waddr             (I_ls_rd_waddr              ),
        .O_rd_wdata             (I_ls_rd_wdata              ),
        .O_memory_addr          (I_ls_memory_addr           ),
        .O_store_data           (I_ls_store_data            ),
        .O_ld_valid             (I_ls_ld_valid              ),
        .O_st_valid             (I_ls_st_valid              ),
        .O_ls_ctrl              (I_ls_ls_ctrl               ),
        .O_csr_valid            (I_ls_csr_valid             ),
        .O_csr_addr             (I_ls_csr_addr              ),
        .O_csr_wdata            (I_ls_csr_wdata             ),
        .O_except               (I_ls_except                ),
        .O_fwd_rs_data          (fwd_old_rs_data            ),
        .O_fwd_csr_data         (fwd_old_csr_data           ),

        .I_enable               (ex_enable                  ),
        .I_flush                (ex_flush                   )
    );

    wire ls_enable = (O_ls_valid & O_ex_valid & cpu_execute) | dec_buble;
    wire ls_flush = O_flush & cpu_execute;

    ysyx_25110270_pipeline_ls_wb u_pipeline_ls_wb
    (
        .clk                    (clk                        ),
        .rst                    (rst                        ),

        .I_inst                 (O_ls_inst                  ),
        .I_inst_addr            (O_ls_inst_addr             ),
        .I_rd_we                (O_ls_rd_we                 ),
        .I_rd_waddr             (O_ls_rd_waddr              ),
        .I_rd_wdata             (O_ls_rd_wdata              ),
        .I_csr_valid            (O_ls_csr_valid             ),
        .I_csr_addr             (O_ls_csr_addr              ),
        .I_csr_wdata            (O_ls_csr_wdata             ),
        .I_except               (O_ls_except                ),

        .I_device_skip          (lsu_device_skip            ),

        .O_inst                 (I_wb_inst                  ),
        .O_inst_addr            (I_wb_inst_addr             ),
        .O_rd_we                (I_wb_rd_we                 ),
        .O_rd_waddr             (I_wb_rd_waddr              ),
        .O_rd_wdata             (I_wb_rd_wdata              ),
        .O_csr_valid            (I_wb_csr_valid             ),
        .O_csr_addr             (I_wb_csr_addr              ),
        .O_csr_wdata            (I_wb_csr_wdata             ),
        .O_except               (I_wb_except                ),
        .O_fwd_rs_data          (fwd_old2_rs_data           ),
        .O_fwd_csr_data         (fwd_old2_csr_data          ),

        .O_device_skip          (wbu_device_skip            ),

        .I_enable               (ls_enable                  ),
        .I_flush                (ls_flush                   )
    );


endmodule //ysyx_25110270
