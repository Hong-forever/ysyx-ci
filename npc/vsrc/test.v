// `include "defines.v"

// module top
// (
//     input   wire                        clk,
//     input   wire                        rst_n
// );

//     wire        m_awvalid;
//     wire        m_awready;
//     wire [31:0] m_awaddr;
//     wire [3:0 ] m_awid;
//     wire [7:0 ] m_awlen;
//     wire [2:0 ] m_awsize;
//     wire [1:0 ] m_awburst;
//     wire        m_wvalid;
//     wire        m_wready;
//     wire [31:0] m_wdata;
//     wire [3:0 ] m_wstrb;
//     wire        m_wlast;
//     wire        m_bvalid;
//     wire        m_bready;
//     wire [1:0]  m_bresp;
//     wire [3:0 ] m_bid;
//     wire        m_arvalid;
//     wire        m_arready;
//     wire [31:0] m_araddr;
//     wire [3:0 ] m_arid;
//     wire [7:0 ] m_arlen;
//     wire [2:0 ] m_arsize;
//     wire [1:0 ] m_arburst;
//     wire        m_rvalid;
//     wire        m_rready;
//     wire [31:0] m_rdata;
//     wire [1:0]  m_rresp;
//     wire        m_rlast;
//     wire [3:0 ] m_rid;

//     wire        s0_awvalid;
//     wire        s0_awready;
//     wire [31:0] s0_awaddr;
//     wire [3:0 ] s0_awid;
//     wire [7:0 ] s0_awlen;
//     wire [2:0 ] s0_awsize;
//     wire [1:0 ] s0_awburst;
//     wire        s0_wvalid;
//     wire        s0_wready;
//     wire [31:0] s0_wdata;
//     wire [3:0 ] s0_wstrb;
//     wire        s0_wlast;
//     wire        s0_bvalid;
//     wire        s0_bready;
//     wire [1:0]  s0_bresp;
//     wire [3:0 ] s0_bid;
//     wire        s0_arvalid;
//     wire        s0_arready;
//     wire [31:0] s0_araddr;
//     wire [3:0 ] s0_arid;
//     wire [7:0 ] s0_arlen;
//     wire [2:0 ] s0_arsize;
//     wire [1:0 ] s0_arburst;
//     wire        s0_rvalid;
//     wire        s0_rready;
//     wire [31:0] s0_rdata;
//     wire [1:0]  s0_rresp;
//     wire        s0_rlast;
//     wire [3:0 ] s0_rid;

//     wire        s1_awvalid;
//     wire        s1_awready;
//     wire [31:0] s1_awaddr;
//     wire [3:0 ] s1_awid;
//     wire [7:0 ] s1_awlen;
//     wire [2:0 ] s1_awsize;
//     wire [1:0 ] s1_awburst;
//     wire        s1_wvalid;
//     wire        s1_wready;
//     wire [31:0] s1_wdata;
//     wire [3:0 ] s1_wstrb;
//     wire        s1_wlast;
//     wire        s1_bvalid;
//     wire        s1_bready;
//     wire [1:0]  s1_bresp;
//     wire [3:0 ] s1_bid;
//     wire        s1_arvalid;
//     wire        s1_arready;
//     wire [31:0] s1_araddr;
//     wire [3:0 ] s1_arid;
//     wire [7:0 ] s1_arlen;
//     wire [2:0 ] s1_arsize;
//     wire [1:0 ] s1_arburst;
//     wire        s1_rvalid;
//     wire        s1_rready;
//     wire [31:0] s1_rdata;
//     wire [1:0]  s1_rresp;
//     wire        s1_rlast;
//     wire [3:0 ] s1_rid;
    
//     wire        s2_awvalid;
//     wire        s2_awready;
//     wire [31:0] s2_awaddr;
//     wire [3:0 ] s2_awid;
//     wire [7:0 ] s2_awlen;
//     wire [2:0 ] s2_awsize;
//     wire [1:0 ] s2_awburst;
//     wire        s2_wvalid;
//     wire        s2_wready;
//     wire [31:0] s2_wdata;
//     wire [3:0 ] s2_wstrb;
//     wire        s2_wlast;
//     wire        s2_bvalid;
//     wire        s2_bready;
//     wire [1:0]  s2_bresp;
//     wire [3:0 ] s2_bid;
//     wire        s2_arvalid;
//     wire        s2_arready;
//     wire [31:0] s2_araddr;
//     wire [3:0 ] s2_arid;
//     wire [7:0 ] s2_arlen;
//     wire [2:0 ] s2_arsize;
//     wire [1:0 ] s2_arburst;
//     wire        s2_rvalid;
//     wire        s2_rready;
//     wire [31:0] s2_rdata;
//     wire [1:0]  s2_rresp;
//     wire        s2_rlast;
//     wire [3:0 ] s2_rid;

//     ysyx_25110270 cpu
//     (
//         .clock                  (clk                        ),
//         .reset                  (~rst_n                     ),

//         .io_interrupt           (1'b0                       ),

//         .io_master_awvalid      (m_awvalid                  ),
//         .io_master_awready      (m_awready                  ),
//         .io_master_awaddr       (m_awaddr                   ),
//         .io_master_awid         (m_awid                     ),
//         .io_master_awlen        (m_awlen                    ),
//         .io_master_awsize       (m_awsize                   ),
//         .io_master_awburst      (m_awburst                  ),
//         .io_master_wvalid       (m_wvalid                   ),
//         .io_master_wready       (m_wready                   ),
//         .io_master_wdata        (m_wdata                    ),
//         .io_master_wstrb        (m_wstrb                    ),
//         .io_master_wlast        (m_wlast                    ),
//         .io_master_bvalid       (m_bvalid                   ),
//         .io_master_bready       (m_bready                   ),
//         .io_master_bresp        (m_bresp                    ),
//         .io_master_bid          (m_bid                      ),
//         .io_master_arvalid      (m_arvalid                  ),
//         .io_master_arready      (m_arready                  ),
//         .io_master_araddr       (m_araddr                   ),
//         .io_master_arid         (m_arid                     ),
//         .io_master_arlen        (m_arlen                    ),
//         .io_master_arsize       (m_arsize                   ),
//         .io_master_arburst      (m_arburst                  ),
//         .io_master_rvalid       (m_rvalid                   ),
//         .io_master_rready       (m_rready                   ),
//         .io_master_rdata        (m_rdata                    ),
//         .io_master_rresp        (m_rresp                    ),
//         .io_master_rlast        (m_rlast                    ),
//         .io_master_rid          (m_rid                      )
//     );

//     ysyx_25110270_xbar xbar
//     (
//         .clk                    (clk                        ),
//         .rst_n                  (rst_n                      ),

//         .S_awvalid              (m_awvalid                  ),
//         .S_awready              (m_awready                  ),
//         .S_awaddr               (m_awaddr                   ),
//         .S_awid                 (m_awid                     ),
//         .S_awlen                (m_awlen                    ),
//         .S_awsize               (m_awsize                   ),
//         .S_awburst              (m_awburst                  ),
//         .S_wvalid               (m_wvalid                   ),
//         .S_wready               (m_wready                   ),
//         .S_wdata                (m_wdata                    ),
//         .S_wstrb                (m_wstrb                    ),
//         .S_wlast                (m_wlast                    ),
//         .S_bvalid               (m_bvalid                   ),
//         .S_bready               (m_bready                   ),
//         .S_bresp                (m_bresp                    ),
//         .S_bid                  (m_bid                      ),
//         .S_arvalid              (m_arvalid                  ),
//         .S_arready              (m_arready                  ),
//         .S_araddr               (m_araddr                   ),
//         .S_arid                 (m_arid                     ),
//         .S_arlen                (m_arlen                    ),
//         .S_arsize               (m_arsize                   ),
//         .S_arburst              (m_arburst                  ),
//         .S_rvalid               (m_rvalid                   ),
//         .S_rready               (m_rready                   ),
//         .S_rdata                (m_rdata                    ),
//         .S_rresp                (m_rresp                    ),
//         .S_rlast                (m_rlast                    ),
//         .S_rid                  (m_rid                      ),

//         .M0_awvalid             (s0_awvalid                 ),
//         .M0_awready             (s0_awready                 ),
//         .M0_awaddr              (s0_awaddr                  ),
//         .M0_awid                (s0_awid                    ),
//         .M0_awlen               (s0_awlen                   ),
//         .M0_awsize              (s0_awsize                  ),
//         .M0_awburst             (s0_awburst                 ),
//         .M0_wvalid              (s0_wvalid                  ),
//         .M0_wready              (s0_wready                  ),
//         .M0_wdata               (s0_wdata                   ),
//         .M0_wstrb               (s0_wstrb                   ),
//         .M0_wlast               (s0_wlast                   ),
//         .M0_bvalid              (s0_bvalid                  ),
//         .M0_bready              (s0_bready                  ),
//         .M0_bresp               (s0_bresp                   ),
//         .M0_bid                 (s0_bid                     ),
//         .M0_arvalid             (s0_arvalid                 ),
//         .M0_arready             (s0_arready                 ),
//         .M0_araddr              (s0_araddr                  ),
//         .M0_arid                (s0_arid                    ),
//         .M0_arlen               (s0_arlen                   ),
//         .M0_arsize              (s0_arsize                  ),
//         .M0_arburst             (s0_arburst                 ),
//         .M0_rvalid              (s0_rvalid                  ),
//         .M0_rready              (s0_rready                  ),
//         .M0_rdata               (s0_rdata                   ),
//         .M0_rresp               (s0_rresp                   ),
//         .M0_rlast               (s0_rlast                   ),
//         .M0_rid                 (s0_rid                     ),

//         .M1_awvalid             (s1_awvalid                 ),
//         .M1_awready             (s1_awready                 ),
//         .M1_awaddr              (s1_awaddr                  ),
//         .M1_awid                (s1_awid                    ),
//         .M1_awlen               (s1_awlen                   ),
//         .M1_awsize              (s1_awsize                  ),
//         .M1_awburst             (s1_awburst                 ),
//         .M1_wvalid              (s1_wvalid                  ),
//         .M1_wready              (s1_wready                  ),
//         .M1_wdata               (s1_wdata                   ),
//         .M1_wstrb               (s1_wstrb                   ),
//         .M1_wlast               (s1_wlast                   ),
//         .M1_bvalid              (s1_bvalid                  ),
//         .M1_bready              (s1_bready                  ),
//         .M1_bresp               (s1_bresp                   ),
//         .M1_bid                 (s1_bid                     ),
//         .M1_arvalid             (s1_arvalid                 ),
//         .M1_arready             (s1_arready                 ),
//         .M1_araddr              (s1_araddr                  ),
//         .M1_arid                (s1_arid                    ),
//         .M1_arlen               (s1_arlen                   ),
//         .M1_arsize              (s1_arsize                  ),
//         .M1_arburst             (s1_arburst                 ),
//         .M1_rvalid              (s1_rvalid                  ),
//         .M1_rready              (s1_rready                  ),
//         .M1_rdata               (s1_rdata                   ),
//         .M1_rresp               (s1_rresp                   ),
//         .M1_rlast               (s1_rlast                   ),
//         .M1_rid                 (s1_rid                     ),

//         .M2_awvalid             (s2_awvalid                 ),
//         .M2_awready             (s2_awready                 ),
//         .M2_awaddr              (s2_awaddr                  ),
//         .M2_awid                (s2_awid                    ),
//         .M2_awlen               (s2_awlen                   ),
//         .M2_awsize              (s2_awsize                  ),
//         .M2_awburst             (s2_awburst                 ),
//         .M2_wvalid              (s2_wvalid                  ),
//         .M2_wready              (s2_wready                  ),
//         .M2_wdata               (s2_wdata                   ),
//         .M2_wstrb               (s2_wstrb                   ),
//         .M2_wlast               (s2_wlast                   ),
//         .M2_bvalid              (s2_bvalid                  ),
//         .M2_bready              (s2_bready                  ),
//         .M2_bresp               (s2_bresp                   ),
//         .M2_bid                 (s2_bid                     ),
//         .M2_arvalid             (s2_arvalid                 ),
//         .M2_arready             (s2_arready                 ),
//         .M2_araddr              (s2_araddr                  ),
//         .M2_arid                (s2_arid                    ),
//         .M2_arlen               (s2_arlen                   ),
//         .M2_arsize              (s2_arsize                  ),
//         .M2_arburst             (s2_arburst                 ),
//         .M2_rvalid              (s2_rvalid                  ),
//         .M2_rready              (s2_rready                  ),
//         .M2_rdata               (s2_rdata                   ),
//         .M2_rresp               (s2_rresp                   ),
//         .M2_rlast               (s2_rlast                   ),
//         .M2_rid                 (s2_rid                     )
//     );

//     ysyx_25110270_mem #(
//         .ADDR_WIDTH             (`MemAddrWidth              ),
//         .DATA_WIDTH             (`MemDataWidth              ),
//         .MEM_DEPTH              (512                        ),
//         .LFSR_SEED              (`SEED4                     )
//     ) mem_inst (
//         .clk                    (clk                        ),
//         .rst_n                  (rst_n                      ),

//         .awvalid_i              (s0_awvalid                 ),
//         .awready_o              (s0_awready                 ),
//         .awaddr_i               (s0_awaddr                  ),
//         .wvalid_i               (s0_wvalid                  ),
//         .wready_o               (s0_wready                  ),
//         .wdata_i                (s0_wdata                   ),
//         .wstrb_i                (s0_wstrb                   ),
//         .bvalid_o               (s0_bvalid                  ),
//         .bready_i               (s0_bready                  ),
//         .bresp_o                (s0_bresp                   ),
//         .arvalid_i              (s0_arvalid                 ),
//         .arready_o              (s0_arready                 ),
//         .araddr_i               (s0_araddr                  ),
//         .rvalid_o               (s0_rvalid                  ),
//         .rready_i               (s0_rready                  ),
//         .rdata_o                (s0_rdata                   ),
//         .rresp_o                (s0_rresp                   )
//     );

//     ysyx_25110270_uart #(
//         .ADDR_WIDTH             (`MemAddrWidth              ),
//         .DATA_WIDTH             (`MemDataWidth              )
//     ) uart_inst (
//         .clk                    (clk                        ),
//         .rst_n                  (rst_n                      ),

//         .awvalid_i              (s1_awvalid                 ),
//         .awready_o              (s1_awready                 ),
//         .awaddr_i               (s1_awaddr                  ),
//         .wvalid_i               (s1_wvalid                  ),
//         .wready_o               (s1_wready                  ),
//         .wdata_i                (s1_wdata                   ),
//         .wstrb_i                (s1_wstrb                   ),
//         .bvalid_o               (s1_bvalid                  ),
//         .bready_i               (s1_bready                  ),
//         .bresp_o                (s1_bresp                   ),
//         .arvalid_i              (s1_arvalid                 ),
//         .arready_o              (s1_arready                 ),
//         .araddr_i               (s1_araddr                  ),
//         .rvalid_o               (s1_rvalid                  ),
//         .rready_i               (s1_rready                  ),
//         .rdata_o                (s1_rdata                   ),
//         .rresp_o                (s1_rresp                   )
//     );

//     ysyx_25110270_clint #(
//         .ADDR_WIDTH             (`MemAddrWidth              ),
//         .DATA_WIDTH             (`MemDataWidth              )
//     ) clint_inst (
//         .clk                    (clk                        ),
//         .rst_n                  (rst_n                      ),

//         .awvalid_i              (s2_awvalid                 ),
//         .awready_o              (s2_awready                 ),
//         .awaddr_i               (s2_awaddr                  ),
//         .wvalid_i               (s2_wvalid                  ),
//         .wready_o               (s2_wready                  ),
//         .wdata_i                (s2_wdata                   ),
//         .wstrb_i                (s2_wstrb                   ),
//         .bvalid_o               (s2_bvalid                  ),
//         .bready_i               (s2_bready                  ),
//         .bresp_o                (s2_bresp                   ),
//         .arvalid_i              (s2_arvalid                 ),
//         .arready_o              (s2_arready                 ),
//         .araddr_i               (s2_araddr                  ),
//         .rvalid_o               (s2_rvalid                  ),
//         .rready_i               (s2_rready                  ),
//         .rdata_o                (s2_rdata                   ),
//         .rresp_o                (s2_rresp                   )
//     );

// endmodule
