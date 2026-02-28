module ysyx_25110270
(
    input   wire                        clock,
    input   wire                        reset,

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
    input   wire    [3:0]               io_master_rid,

    input   wire                        io_slave_awvalid,
    output  wire                        io_slave_awready,
    input   wire    [31:0]              io_slave_awaddr,
    input   wire    [3:0]               io_slave_awid,
    input   wire    [7:0]               io_slave_awlen,
    input   wire    [2:0]               io_slave_awsize,
    input   wire    [1:0]               io_slave_awburst,
    input   wire                        io_slave_wvalid,
    output  wire                        io_slave_wready,
    input   wire    [31:0]              io_slave_wdata,
    input   wire    [3:0]               io_slave_wstrb,
    input   wire                        io_slave_wlast,
    output  wire                        io_slave_bvalid,
    input   wire                        io_slave_bready,
    output  wire    [1:0]               io_slave_bresp,
    output  wire    [3:0]               io_slave_bid,
    input   wire                        io_slave_arvalid,
    output  wire                        io_slave_arready,
    input   wire    [31:0]              io_slave_araddr,
    input   wire    [3:0]               io_slave_arid,
    input   wire    [7:0]               io_slave_arlen,
    input   wire    [2:0]               io_slave_arsize,
    input   wire    [1:0]               io_slave_arburst,
    output  wire                        io_slave_rvalid,
    input   wire                        io_slave_rready,
    output  wire    [31:0]              io_slave_rdata,
    output  wire    [1:0]               io_slave_rresp,
    output  wire                        io_slave_rlast,
    output  wire    [3:0]               io_slave_rid
);

    wire clk = clock;
    wire rst_n = ~reset;

    //cpu core
    wire        cpu_awvalid;
    wire        cpu_awready;
    wire [31:0] cpu_awaddr;
    wire [3:0 ] cpu_awid;
    wire [7:0 ] cpu_awlen;
    wire [2:0 ] cpu_awsize;
    wire [1:0 ] cpu_awburst;
    wire        cpu_wvalid;
    wire        cpu_wready;
    wire [31:0] cpu_wdata;
    wire [3:0 ] cpu_wstrb;
    wire        cpu_wlast;
    wire        cpu_bvalid;
    wire        cpu_bready;
    wire [1:0]  cpu_bresp;
    wire [3:0 ] cpu_bid;
    wire        cpu_arvalid;
    wire        cpu_arready;
    wire [31:0] cpu_araddr;
    wire [3:0 ] cpu_arid;
    wire [7:0 ] cpu_arlen;
    wire [2:0 ] cpu_arsize;
    wire [1:0 ] cpu_arburst;
    wire        cpu_rvalid;
    wire        cpu_rready;
    wire [31:0] cpu_rdata;
    wire [1:0]  cpu_rresp;
    wire        cpu_rlast;
    wire [3:0 ] cpu_rid;

    //clint
    wire        clint_awvalid;
    wire        clint_awready;
    wire [31:0] clint_awaddr;
    wire [3:0 ] clint_awid;
    wire [7:0 ] clint_awlen;
    wire [2:0 ] clint_awsize;
    wire [1:0 ] clint_awburst;
    wire        clint_wvalid;
    wire        clint_wready;
    wire [31:0] clint_wdata;
    wire [3:0 ] clint_wstrb;
    wire        clint_wlast;
    wire        clint_bvalid;
    wire        clint_bready;
    wire [1:0]  clint_bresp;
    wire [3:0 ] clint_bid;
    wire        clint_arvalid;
    wire        clint_arready;
    wire [31:0] clint_araddr;
    wire [3:0 ] clint_arid;
    wire [7:0 ] clint_arlen;
    wire [2:0 ] clint_arsize;
    wire [1:0 ] clint_arburst;
    wire        clint_rvalid;
    wire        clint_rready;
    wire [31:0] clint_rdata;
    wire [1:0]  clint_rresp;
    wire        clint_rlast;
    wire [3:0 ] clint_rid;

    ysyx_25110270_cpu_core cpu_core
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .io_interrupt           (io_interrupt               ),

        .io_master_awvalid      (cpu_awvalid                ),
        .io_master_awready      (cpu_awready                ),
        .io_master_awaddr       (cpu_awaddr                 ),
        .io_master_awid         (cpu_awid                   ),
        .io_master_awlen        (cpu_awlen                  ),
        .io_master_awsize       (cpu_awsize                 ),
        .io_master_awburst      (cpu_awburst                ),
        .io_master_wvalid       (cpu_wvalid                 ),
        .io_master_wready       (cpu_wready                 ),
        .io_master_wdata        (cpu_wdata                  ),
        .io_master_wstrb        (cpu_wstrb                  ),
        .io_master_wlast        (cpu_wlast                  ),
        .io_master_bvalid       (cpu_bvalid                 ),
        .io_master_bready       (cpu_bready                 ),
        .io_master_bresp        (cpu_bresp                  ),
        .io_master_bid          (cpu_bid                    ),
        .io_master_arvalid      (cpu_arvalid                ),
        .io_master_arready      (cpu_arready                ),
        .io_master_araddr       (cpu_araddr                 ),
        .io_master_arid         (cpu_arid                   ),
        .io_master_arlen        (cpu_arlen                  ),
        .io_master_arsize       (cpu_arsize                 ),
        .io_master_arburst      (cpu_arburst                ),
        .io_master_rvalid       (cpu_rvalid                 ),
        .io_master_rready       (cpu_rready                 ),
        .io_master_rdata        (cpu_rdata                  ),
        .io_master_rresp        (cpu_rresp                  ),
        .io_master_rlast        (cpu_rlast                  ),
        .io_master_rid          (cpu_rid                    )

    );

    ysyx_25110270_xbar xbar 
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .S_awvalid              (cpu_awvalid                ),
        .S_awready              (cpu_awready                ),
        .S_awaddr               (cpu_awaddr                 ),
        .S_awid                 (cpu_awid                   ),
        .S_awlen                (cpu_awlen                  ),
        .S_awsize               (cpu_awsize                 ),
        .S_awburst              (cpu_awburst                ),
        .S_wvalid               (cpu_wvalid                 ),
        .S_wready               (cpu_wready                 ),
        .S_wdata                (cpu_wdata                  ),
        .S_wstrb                (cpu_wstrb                  ),
        .S_wlast                (cpu_wlast                  ),
        .S_bvalid               (cpu_bvalid                 ),
        .S_bready               (cpu_bready                 ),
        .S_bresp                (cpu_bresp                  ),
        .S_bid                  (cpu_bid                    ),
        .S_arvalid              (cpu_arvalid                ),
        .S_arready              (cpu_arready                ),
        .S_araddr               (cpu_araddr                 ),
        .S_arid                 (cpu_arid                   ),
        .S_arlen                (cpu_arlen                  ),
        .S_arsize               (cpu_arsize                 ),
        .S_arburst              (cpu_arburst                ),
        .S_rvalid               (cpu_rvalid                 ),
        .S_rready               (cpu_rready                 ),
        .S_rdata                (cpu_rdata                  ),
        .S_rresp                (cpu_rresp                  ),
        .S_rlast                (cpu_rlast                  ),
        .S_rid                  (cpu_rid                    ),

        .M0_awvalid             (clint_awvalid              ),
        .M0_awready             (clint_awready              ),
        .M0_awaddr              (clint_awaddr               ),
        .M0_awid                (clint_awid                 ),
        .M0_awlen               (clint_awlen                ),
        .M0_awsize              (clint_awsize               ),
        .M0_awburst             (clint_awburst              ),
        .M0_wvalid              (clint_wvalid               ),
        .M0_wready              (clint_wready               ),
        .M0_wdata               (clint_wdata                ),
        .M0_wstrb               (clint_wstrb                ),
        .M0_wlast               (clint_wlast                ),
        .M0_bvalid              (clint_bvalid               ),
        .M0_bready              (clint_bready               ),
        .M0_bresp               (clint_bresp                ),
        .M0_bid                 (clint_bid                  ),
        .M0_arvalid             (clint_arvalid              ),
        .M0_arready             (clint_arready              ),
        .M0_araddr              (clint_araddr               ),
        .M0_arid                (clint_arid                 ),
        .M0_arlen               (clint_arlen                ),
        .M0_arsize              (clint_arsize               ),
        .M0_arburst             (clint_arburst              ),
        .M0_rvalid              (clint_rvalid               ),
        .M0_rready              (clint_rready               ),
        .M0_rdata               (clint_rdata                ),
        .M0_rresp               (clint_rresp                ),
        .M0_rlast               (clint_rlast                ),
        .M0_rid                 (clint_rid                  ),

        .M1_awvalid             (io_master_awvalid          ),
        .M1_awready             (io_master_awready          ),
        .M1_awaddr              (io_master_awaddr           ),
        .M1_awid                (io_master_awid             ),
        .M1_awlen               (io_master_awlen            ),
        .M1_awsize              (io_master_awsize           ),
        .M1_awburst             (io_master_awburst          ),
        .M1_wvalid              (io_master_wvalid           ),
        .M1_wready              (io_master_wready           ),
        .M1_wdata               (io_master_wdata            ),
        .M1_wstrb               (io_master_wstrb            ),
        .M1_wlast               (io_master_wlast            ),
        .M1_bvalid              (io_master_bvalid           ),
        .M1_bready              (io_master_bready           ),
        .M1_bresp               (io_master_bresp            ),
        .M1_bid                 (io_master_bid              ),
        .M1_arvalid             (io_master_arvalid          ),
        .M1_arready             (io_master_arready          ),
        .M1_araddr              (io_master_araddr           ),
        .M1_arid                (io_master_arid             ),
        .M1_arlen               (io_master_arlen            ),
        .M1_arsize              (io_master_arsize           ),
        .M1_arburst             (io_master_arburst          ),
        .M1_rvalid              (io_master_rvalid           ),
        .M1_rready              (io_master_rready           ),
        .M1_rdata               (io_master_rdata            ),
        .M1_rresp               (io_master_rresp            ),
        .M1_rlast               (io_master_rlast            ),
        .M1_rid                 (io_master_rid              )
    );

    ysyx_25110270_clint clint
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .awvalid_i              (clint_awvalid              ),
        .awready_o              (clint_awready              ),
        .awaddr_i               (clint_awaddr               ),
        .awid_i                 (clint_awid                 ),
        .awlen_i                (clint_awlen                ),
        .awsize_i               (clint_awsize               ),
        .awburst_i              (clint_awburst              ),
        .wvalid_i               (clint_wvalid               ),
        .wready_o               (clint_wready               ),
        .wdata_i                (clint_wdata                ),
        .wstrb_i                (clint_wstrb                ),
        .wlast_i                (clint_wlast                ),
        .bvalid_o               (clint_bvalid               ),
        .bready_i               (clint_bready               ),
        .bresp_o                (clint_bresp                ),
        .bid_o                  (clint_bid                  ),
        .arvalid_i              (clint_arvalid              ),
        .arready_o              (clint_arready              ),
        .araddr_i               (clint_araddr               ),
        .arid_i                 (clint_arid                 ),
        .arlen_i                (clint_arlen                ),
        .arsize_i               (clint_arsize               ),
        .arburst_i              (clint_arburst              ),
        .rvalid_o               (clint_rvalid               ),
        .rready_i               (clint_rready               ),
        .rdata_o                (clint_rdata                ),
        .rresp_o                (clint_rresp                ),
        .rlast_o                (clint_rlast                ),
        .rid_o                  (clint_rid                  )
    );

    assign io_slave_awready = 1'b0;
    assign io_slave_wready  = 1'b0;
    assign io_slave_bvalid  = 1'b0;
    assign io_slave_bresp   = 2'b00;
    assign io_slave_bid     = 4'b0;
    assign io_slave_arready = 1'b0;
    assign io_slave_rvalid  = 1'b0;
    assign io_slave_rdata   = 32'b0;
    assign io_slave_rresp   = 2'b00;
    assign io_slave_rlast   = 1'b0;
    assign io_slave_rid     = 4'b0;


endmodule //ysyx_25110270
