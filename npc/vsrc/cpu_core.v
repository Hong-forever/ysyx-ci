`include "defines.v"

//------------------------------------------------------------------------
// cpu core
//------------------------------------------------------------------------

module ysyx_25110270_cpu_core
(
    input   wire                        clk,
    input   wire                        rst_n,

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
    wire [`InstBus    ] O_if_inst;
    wire [`InstAddrBus] O_if_inst_addr;
    wire                O_if_valid;

    //-------------------------------------------------------------
    // pipeline_if_dec
    //-------------------------------------------------------------
    wire [`InstBus    ] I_dec_inst;
    wire [`InstAddrBus] I_dec_inst_addr;

    //-------------------------------------------------------------
    // decoder
    //-------------------------------------------------------------
    wire [`RegAddrBus ] O_rs1_raddr;
    wire [`RegAddrBus ] O_rs2_raddr;
    wire [`CSRAddrBus ] O_csr_raddr;
    wire [`RegDataBus ] I_rs1_rdata;
    wire [`RegDataBus ] I_rs2_rdata;
    wire [`CSRDataBus ] I_csr_rdata;

    wire [`InstBus    ] O_dec_inst;
    wire [`InstAddrBus] O_dec_inst_addr;
    wire                O_dec_valid;
    wire                O_dec_ready;
    wire [`RegDataBus ] O_dec_rs1_rdata;
    wire [`RegDataBus ] O_dec_rs2_rdata;
    wire [`RegDataBus ] O_dec_imm;
    wire                O_dec_rd_we;
    wire [`RegAddrBus ] O_dec_rd_waddr;
    wire                O_dec_csr_we;
    wire [`CSRAddrBus ] O_dec_csr_waddr;
    wire [`CSRDataBus ] O_dec_csr_rdata;
    wire [`CSRCTL_WIDTH-1:0     ] O_dec_CSRCtrl;
    wire [`ALUCTL_WIDTH-1:0     ] O_dec_ALUCtrl;
    wire [`BRUCTL_WIDTH-1:0     ] O_dec_BRUCtrl;
    wire [`ALUSrcA_sel_width-1:0] O_dec_ALUSrcA_sel;
    wire [`ALUSrcB_sel_width-1:0] O_dec_ALUSrcB_sel;
    wire [`AGUSrc_sel_width-1:0 ] O_dec_AGUSrc_sel;
    wire [`CSRSrc_sel_width-1:0 ] O_dec_CSRSrc_sel;
    wire                O_dec_ls_valid;
    wire [`ls_diff_bus] O_dec_ls_type;
    wire [`Except_Bus ] O_dec_except;

    //-------------------------------------------------------------
    // pipeline_dec_ex
    //-------------------------------------------------------------
    wire [`InstBus    ] I_ex_inst;
    wire [`InstAddrBus] I_ex_inst_addr;
    wire [`RegDataBus ] I_ex_rs1_rdata;
    wire [`RegDataBus ] I_ex_rs2_rdata;
    wire [`RegDataBus ] I_ex_imm;
    wire                I_ex_rd_we;
    wire [`RegAddrBus ] I_ex_rd_waddr;
    wire                I_ex_csr_we;
    wire [`CSRAddrBus ] I_ex_csr_waddr;
    wire [`CSRDataBus ] I_ex_csr_rdata;
    wire [`CSRCTL_WIDTH-1:0] I_ex_CSRCtrl;
    wire [`ALUCTL_WIDTH-1:0] I_ex_ALUCtrl;
    wire [`BRUCTL_WIDTH-1:0] I_ex_BRUCtrl;
    wire [`ALUSrcA_sel_width-1:0] I_ex_ALUSrcA_sel;
    wire [`ALUSrcB_sel_width-1:0] I_ex_ALUSrcB_sel;
    wire [`AGUSrc_sel_width-1:0 ] I_ex_AGUSrc_sel;
    wire [`CSRSrc_sel_width-1:0 ] I_ex_CSRSrc_sel;
    wire                I_ex_ls_valid;
    wire [`ls_diff_bus] I_ex_ls_type;
    wire                I_ex_rs1_re;
    wire                I_ex_rs2_re;
    wire                I_ex_csr_re;
    wire [`RegAddrBus ] I_ex_rs1_raddr;
    wire [`RegAddrBus ] I_ex_rs2_raddr;
    wire [`CSRAddrBus ] I_ex_csr_raddr;
    wire [`Except_Bus ] I_ex_except;

    //-------------------------------------------------------------
    // fwd_unit
    //-------------------------------------------------------------
    wire                O_dec_rs1_re;
    wire                O_dec_rs2_re;
    wire                O_dec_csr_re;

    //-------------------------------------------------------------
    // exec
    //-------------------------------------------------------------
    wire                O_ex_bru_taken;
    wire [`InstAddrBus] O_ex_bru_target;

    wire [`InstBus    ] O_ex_inst;
    wire [`InstAddrBus] O_ex_inst_addr;
    wire                O_ex_valid;
    wire                O_ex_ready;
    wire                O_ex_rd_we;
    wire [`RegAddrBus ] O_ex_rd_waddr;
    wire [`RegDataBus ] O_ex_rd_wdata;
    wire [`MemAddrBus ] O_ex_memory_addr;
    wire [`MemDataBus ] O_ex_store_data;
    wire                O_ex_ls_valid;
    wire [`ls_diff_bus] O_ex_ls_type;
    wire                O_ex_csr_we;
    wire [`CSRAddrBus ] O_ex_csr_waddr;
    wire [`CSRDataBus ] O_ex_csr_wdata;
    wire [`Except_Bus ] O_ex_except;


    //-------------------------------------------------------------
    // pipeline_ex_ls
    //-------------------------------------------------------------
    wire [`InstBus    ] I_ls_inst;
    wire [`InstAddrBus] I_ls_inst_addr;
    wire                I_ls_rd_we;
    wire [`RegAddrBus ] I_ls_rd_waddr;
    wire [`RegDataBus ] I_ls_rd_wdata;
    wire [`MemAddrBus ] I_ls_memory_addr;
    wire [`MemDataBus ] I_ls_store_data;
    wire                I_ls_ls_valid;
    wire [`ls_diff_bus] I_ls_ls_type;
    wire                I_ls_csr_we;
    wire [`CSRAddrBus ] I_ls_csr_waddr;
    wire [`CSRDataBus ] I_ls_csr_wdata;
    wire [`Except_Bus ] I_ls_except;


    //-------------------------------------------------------------
    // ls
    //-------------------------------------------------------------
    wire [`InstBus    ] O_ls_inst;
    wire [`InstAddrBus] O_ls_inst_addr;
    wire                O_ls_valid;
    wire                O_ls_ready;
    wire                O_ls_rd_we;
    wire [`RegAddrBus ] O_ls_rd_waddr;
    wire [`RegDataBus ] O_ls_rd_wdata;
    wire                O_ls_csr_we;
    wire [`CSRAddrBus ] O_ls_csr_waddr;
    wire [`CSRDataBus ] O_ls_csr_wdata;
    wire [`Except_Bus ] O_ls_except;

    //-------------------------------------------------------------
    // pipeline_ls_wb
    //-------------------------------------------------------------
    wire [`InstBus    ] I_wb_inst;
    wire [`InstAddrBus] I_wb_inst_addr;
    wire                I_wb_rd_we;
    wire [`RegAddrBus ] I_wb_rd_waddr;
    wire [`RegDataBus ] I_wb_rd_wdata;
    wire                I_wb_csr_we;
    wire [`CSRAddrBus ] I_wb_csr_waddr;
    wire [`CSRDataBus ] I_wb_csr_wdata;
    wire [`Except_Bus ] I_wb_except;

    //-------------------------------------------------------------
    // wb
    //-------------------------------------------------------------
    wire                O_flush;
    wire [`InstAddrBus] O_flush_addr;

    //-------------------------------------------------------------
    // instantiate modules
    //-------------------------------------------------------------
    wire lsu_device_skip;
    wire wbu_device_skip;

    //ibus
    wire        ibus_awvalid;
    wire        ibus_awready;
    wire [31:0] ibus_awaddr;
    wire [3:0 ] ibus_awid;
    wire [7:0 ] ibus_awlen;
    wire [2:0 ] ibus_awsize;
    wire [1:0 ] ibus_awburst;
    wire        ibus_wvalid;
    wire        ibus_wready;
    wire [31:0] ibus_wdata;
    wire [3:0 ] ibus_wstrb;
    wire        ibus_wlast;
    wire        ibus_bvalid;
    wire        ibus_bready;
    wire [1:0]  ibus_bresp;
    wire [3:0 ] ibus_bid;
    wire        ibus_arvalid;
    wire        ibus_arready;
    wire [31:0] ibus_araddr;
    wire [3:0 ] ibus_arid;
    wire [7:0 ] ibus_arlen;
    wire [2:0 ] ibus_arsize;
    wire [1:0 ] ibus_arburst;
    wire        ibus_rvalid;
    wire        ibus_rready;
    wire [31:0] ibus_rdata;
    wire [1:0]  ibus_rresp;
    wire        ibus_rlast;
    wire [3:0 ] ibus_rid;

    //dbus
    wire        dbus_awvalid;
    wire        dbus_awready;
    wire [31:0] dbus_awaddr;
    wire [3:0 ] dbus_awid;
    wire [7:0 ] dbus_awlen;
    wire [2:0 ] dbus_awsize;
    wire [1:0 ] dbus_awburst;
    wire        dbus_wvalid;
    wire        dbus_wready;
    wire [31:0] dbus_wdata;
    wire [3:0 ] dbus_wstrb;
    wire        dbus_wlast;
    wire        dbus_bvalid;
    wire        dbus_bready;
    wire [1:0]  dbus_bresp;
    wire [3:0 ] dbus_bid;
    wire        dbus_arvalid;
    wire        dbus_arready;
    wire [31:0] dbus_araddr;
    wire [3:0 ] dbus_arid;
    wire [7:0 ] dbus_arlen;
    wire [2:0 ] dbus_arsize;
    wire [1:0 ] dbus_arburst;
    wire        dbus_rvalid;
    wire        dbus_rready;
    wire [31:0] dbus_rdata;
    wire [1:0]  dbus_rresp;
    wire        dbus_rlast;
    wire [3:0 ] dbus_rid;

    wire  if_out_valid, if_out_ready;
    wire  dec_out_valid, dec_out_ready;
    wire  ex_out_valid, ex_out_ready;
    wire  ls_out_valid, ls_out_ready;
    wire  wb_out_valid, wb_out_ready;

    ysyx_25110270_ifetch u_ifetch
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .I_bru_taken            (O_ex_bru_taken             ),
        .I_bru_target           (O_ex_bru_target            ),

        .I_valid                (wb_out_valid               ),
        .O_ready                (if_out_ready               ),
        .O_valid                (if_out_valid               ),
        .I_ready                (dec_out_ready              ),

        .I_flush                (O_flush                    ),
        .I_flush_addr           (O_flush_addr               ),

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
        .rst_n                  (rst_n                      ),

        .I_inst                 (I_dec_inst                 ),
        .I_inst_addr            (I_dec_inst_addr            ),

        .I_valid                (if_out_valid               ),
        .O_ready                (dec_out_ready              ),
        .O_valid                (dec_out_valid              ),
        .I_ready                (ex_out_ready               ),

        .O_rs1_raddr            (O_rs1_raddr                ),
        .O_rs2_raddr            (O_rs2_raddr                ),
        .O_csr_raddr            (O_csr_raddr                ),
        .I_rs1_rdata            (I_rs1_rdata                ),
        .I_rs2_rdata            (I_rs2_rdata                ),
        .I_csr_rdata            (I_csr_rdata                ),

        .O_inst                 (O_dec_inst                 ),
        .O_inst_addr            (O_dec_inst_addr            ),

        .O_rs1_rdata            (O_dec_rs1_rdata            ),
        .O_rs2_rdata            (O_dec_rs2_rdata            ),
        .O_imm                  (O_dec_imm                  ),
        .O_rd_we                (O_dec_rd_we                ),
        .O_rd_waddr             (O_dec_rd_waddr             ),
        .O_csr_we               (O_dec_csr_we               ),
        .O_csr_waddr            (O_dec_csr_waddr            ),
        .O_csr_rdata            (O_dec_csr_rdata            ),
        .O_CSRCtrl              (O_dec_CSRCtrl              ),
        .O_ALUCtrl              (O_dec_ALUCtrl              ),
        .O_BRUCtrl              (O_dec_BRUCtrl              ),
        .O_ALUSrcA_sel          (O_dec_ALUSrcA_sel          ),
        .O_ALUSrcB_sel          (O_dec_ALUSrcB_sel          ),
        .O_AGUSrc_sel           (O_dec_AGUSrc_sel           ),
        .O_CSRSrc_sel           (O_dec_CSRSrc_sel           ),
        .O_ls_valid             (O_dec_ls_valid             ),
        .O_ls_type              (O_dec_ls_type              ),
        .O_rs1_re               (O_dec_rs1_re               ),
        .O_rs2_re               (O_dec_rs2_re               ),
        .O_csr_re               (O_dec_csr_re               ),
        .O_except               (O_dec_except               )    
    );

    ysyx_25110270_exec u_exec
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .I_inst                 (I_ex_inst                  ),
        .I_inst_addr            (I_ex_inst_addr             ),

        .I_valid                (dec_out_valid              ),
        .O_ready                (ex_out_ready               ),
        .O_valid                (ex_out_valid               ),
        .I_ready                (ls_out_ready               ),

        .I_rd_we                (I_ex_rd_we                 ),
        .I_rd_waddr             (I_ex_rd_waddr              ),
        .I_imm                  (I_ex_imm                   ),
        .I_csr_we               (I_ex_csr_we                ),
        .I_csr_waddr            (I_ex_csr_waddr             ),
        .I_CSRCtrl              (I_ex_CSRCtrl               ),
        .I_ALUCtrl              (I_ex_ALUCtrl               ),
        .I_BRUCtrl              (I_ex_BRUCtrl               ),
        .I_ALUSrcA_sel          (I_ex_ALUSrcA_sel           ),
        .I_ALUSrcB_sel          (I_ex_ALUSrcB_sel           ),
        .I_AGUSrc_sel           (I_ex_AGUSrc_sel            ),
        .I_CSRSrc_sel           (I_ex_CSRSrc_sel            ),
        .I_ls_valid             (I_ex_ls_valid              ),
        .I_ls_type              (I_ex_ls_type               ),
        .I_rs1_rdata            (I_ex_rs1_rdata             ),
        .I_rs2_rdata            (I_ex_rs2_rdata             ),
        .I_csr_rdata            (I_ex_csr_rdata             ),
        .I_csr_re               (I_ex_csr_re                ),
        .I_except               (I_ex_except                ),

        .O_inst                 (O_ex_inst                  ),
        .O_inst_addr            (O_ex_inst_addr             ),

        .O_rd_we                (O_ex_rd_we                 ),
        .O_rd_waddr             (O_ex_rd_waddr              ),
        .O_rd_wdata             (O_ex_rd_wdata              ),
        .O_memory_addr          (O_ex_memory_addr           ),
        .O_store_data           (O_ex_store_data            ),
        .O_ls_valid             (O_ex_ls_valid              ),
        .O_ls_type              (O_ex_ls_type               ),
        .O_csr_we               (O_ex_csr_we                ),
        .O_csr_waddr            (O_ex_csr_waddr             ),
        .O_csr_wdata            (O_ex_csr_wdata             ),
        .O_except               (O_ex_except                ),
        .O_bru_taken            (O_ex_bru_taken             ),
        .O_bru_target           (O_ex_bru_target            )
    );

    ysyx_25110270_lsu u_lsu
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .I_inst                 (I_ls_inst                  ),
        .I_inst_addr            (I_ls_inst_addr             ),

        .I_valid                (ex_out_valid               ),
        .O_ready                (ls_out_ready               ),
        .O_valid                (ls_out_valid               ),
        .I_ready                (wb_out_ready               ),

        .I_rd_we                (I_ls_rd_we                 ),
        .I_rd_waddr             (I_ls_rd_waddr              ),
        .I_rd_wdata             (I_ls_rd_wdata              ),
        .I_memory_addr          (I_ls_memory_addr           ),
        .I_store_data           (I_ls_store_data            ),
        .I_ls_valid             (I_ls_ls_valid              ),
        .I_ls_type              (I_ls_ls_type               ),
        .I_csr_we               (I_ls_csr_we                ),
        .I_csr_waddr            (I_ls_csr_waddr             ),
        .I_csr_wdata            (I_ls_csr_wdata             ),
        .I_except               (I_ls_except                ),

        .I_is_ldst              (O_ex_ls_valid              ),

        .O_device_skip          (lsu_device_skip            ),

        .O_inst                 (O_ls_inst                  ),
        .O_inst_addr            (O_ls_inst_addr             ),
        .O_rd_we                (O_ls_rd_we                 ),
        .O_rd_waddr             (O_ls_rd_waddr              ),
        .O_rd_wdata             (O_ls_rd_wdata              ),
        .O_csr_we               (O_ls_csr_we                ),
        .O_csr_waddr            (O_ls_csr_waddr             ),
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
        .rst_n                  (rst_n                      ),

        .I_inst                 (I_wb_inst                  ),
        .I_inst_addr            (I_wb_inst_addr             ),

        .I_valid                (ls_out_valid               ),
        .O_ready                (wb_out_ready               ),
        .O_valid                (wb_out_valid               ),
        .I_ready                (if_out_ready               ),

        .I_rs1_raddr            (O_rs1_raddr                ),
        .I_rs2_raddr            (O_rs2_raddr                ),
        .O_rs1_rdata            (I_rs1_rdata                ),
        .O_rs2_rdata            (I_rs2_rdata                ),
        .I_rd_we                (I_wb_rd_we                 ),
        .I_rd_waddr             (I_wb_rd_waddr              ),
        .I_rd_wdata             (I_wb_rd_wdata              ),

        .I_csr_raddr            (O_csr_raddr                ),
        .O_csr_rdata            (I_csr_rdata                ),
        .I_csr_we               (I_wb_csr_we                ),
        .I_csr_waddr            (I_wb_csr_waddr             ),
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
        .rst_n                  (rst_n                      ),

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

    ysyx_25110270_pipeline_if_dec u_pipeline_if_dec
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .I_inst                 (O_if_inst                  ),
        .I_inst_addr            (O_if_inst_addr             ),

        .O_inst                 (I_dec_inst                 ),
        .O_inst_addr            (I_dec_inst_addr            )
    );

    ysyx_25110270_pipeline_dec_ex u_pipeline_dec_ex
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .I_inst                 (O_dec_inst                 ),
        .I_inst_addr            (O_dec_inst_addr            ),
        .I_rs1_rdata            (O_dec_rs1_rdata            ),
        .I_rs2_rdata            (O_dec_rs2_rdata            ),
        .I_imm                  (O_dec_imm                  ),
        .I_rd_we                (O_dec_rd_we                ),
        .I_rd_waddr             (O_dec_rd_waddr             ),
        .I_csr_we               (O_dec_csr_we               ),
        .I_csr_waddr            (O_dec_csr_waddr            ),
        .I_csr_rdata            (O_dec_csr_rdata            ),
        .I_CSRCtrl              (O_dec_CSRCtrl              ),
        .I_ALUCtrl              (O_dec_ALUCtrl              ),
        .I_BRUCtrl              (O_dec_BRUCtrl              ),
        .I_ALUSrcA_sel          (O_dec_ALUSrcA_sel          ),
        .I_ALUSrcB_sel          (O_dec_ALUSrcB_sel          ),
        .I_AGUSrc_sel           (O_dec_AGUSrc_sel           ),
        .I_CSRSrc_sel           (O_dec_CSRSrc_sel           ),
        .I_ls_valid             (O_dec_ls_valid             ),
        .I_ls_type              (O_dec_ls_type              ),
        .I_csr_re               (O_dec_csr_re               ),
        .I_except               (O_dec_except               ),

        .O_inst                 (I_ex_inst                  ),
        .O_inst_addr            (I_ex_inst_addr             ),
        .O_rs1_rdata            (I_ex_rs1_rdata             ),
        .O_rs2_rdata            (I_ex_rs2_rdata             ),
        .O_imm                  (I_ex_imm                   ),
        .O_rd_we                (I_ex_rd_we                 ),
        .O_rd_waddr             (I_ex_rd_waddr              ),
        .O_csr_we               (I_ex_csr_we                ),
        .O_csr_waddr            (I_ex_csr_waddr             ),
        .O_csr_rdata            (I_ex_csr_rdata             ),
        .O_CSRCtrl              (I_ex_CSRCtrl               ),
        .O_ALUCtrl              (I_ex_ALUCtrl               ),
        .O_BRUCtrl              (I_ex_BRUCtrl               ),
        .O_ALUSrcA_sel          (I_ex_ALUSrcA_sel           ),
        .O_ALUSrcB_sel          (I_ex_ALUSrcB_sel           ),
        .O_AGUSrc_sel           (I_ex_AGUSrc_sel            ),
        .O_CSRSrc_sel           (I_ex_CSRSrc_sel            ),
        .O_ls_valid             (I_ex_ls_valid              ),
        .O_ls_type              (I_ex_ls_type               ),
        .O_csr_re               (I_ex_csr_re                ),
        .O_except               (I_ex_except                )
    );

    ysyx_25110270_pipeline_ex_ls u_pipeline_ex_ls
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .I_inst                 (O_ex_inst                  ),
        .I_inst_addr            (O_ex_inst_addr             ),
        .I_rd_we                (O_ex_rd_we                 ),
        .I_rd_waddr             (O_ex_rd_waddr              ),
        .I_rd_wdata             (O_ex_rd_wdata              ),
        .I_memory_addr          (O_ex_memory_addr           ),
        .I_store_data           (O_ex_store_data            ),
        .I_ls_valid             (O_ex_ls_valid              ),
        .I_ls_type              (O_ex_ls_type               ),
        .I_csr_we               (O_ex_csr_we                ),
        .I_csr_waddr            (O_ex_csr_waddr             ),
        .I_csr_wdata            (O_ex_csr_wdata             ),
        .I_except               (O_ex_except                ),

        .O_inst                 (I_ls_inst                  ),
        .O_inst_addr            (I_ls_inst_addr             ),
        .O_rd_we                (I_ls_rd_we                 ),
        .O_rd_waddr             (I_ls_rd_waddr              ),
        .O_rd_wdata             (I_ls_rd_wdata              ),
        .O_memory_addr          (I_ls_memory_addr           ),
        .O_store_data           (I_ls_store_data            ),
        .O_ls_valid             (I_ls_ls_valid              ),
        .O_ls_type              (I_ls_ls_type               ),
        .O_csr_we               (I_ls_csr_we                ),
        .O_csr_waddr            (I_ls_csr_waddr             ),
        .O_csr_wdata            (I_ls_csr_wdata             ),
        .O_except               (I_ls_except                )
    );

    ysyx_25110270_pipeline_ls_wb u_pipeline_ls_wb
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .I_inst                 (O_ls_inst                  ),
        .I_inst_addr            (O_ls_inst_addr             ),
        .I_rd_we                (O_ls_rd_we                 ),
        .I_rd_waddr             (O_ls_rd_waddr              ),
        .I_rd_wdata             (O_ls_rd_wdata              ),
        .I_csr_we               (O_ls_csr_we                ),
        .I_csr_waddr            (O_ls_csr_waddr             ),
        .I_csr_wdata            (O_ls_csr_wdata             ),
        .I_except               (O_ls_except                ),

        .I_device_skip          (lsu_device_skip            ),

        .O_inst                 (I_wb_inst                  ),
        .O_inst_addr            (I_wb_inst_addr             ),
        .O_rd_we                (I_wb_rd_we                 ),
        .O_rd_waddr             (I_wb_rd_waddr              ),
        .O_rd_wdata             (I_wb_rd_wdata              ),
        .O_csr_we               (I_wb_csr_we                ),
        .O_csr_waddr            (I_wb_csr_waddr             ),
        .O_csr_wdata            (I_wb_csr_wdata             ),
        .O_except               (I_wb_except                ),

        .O_device_skip          (wbu_device_skip            )
    );



endmodule //ysyx_25110270
