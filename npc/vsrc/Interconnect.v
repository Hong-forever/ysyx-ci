`include "defines.v"

//------------------------------------------------------------------------
// AXI Interconnect模块
//------------------------------------------------------------------------

module Interconnect
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input   wire                        clk,
    input   wire                        rst_n,

    // from master0
    input   wire                        M0_awvalid,
    output  wire                        M0_awready,
    input   wire    [ADDR_WIDTH-1:0 ]   M0_awaddr,
    input   wire                        M0_wvalid,
    output  wire                        M0_wready,
    input   wire    [DATA_WIDTH-1:0 ]   M0_wdata,
    input   wire    [DATA_WIDTH/8-1:0]  M0_wstrb,
    output  wire                        M0_bvalid,
    input   wire                        M0_bready,
    output  wire    [1:0            ]   M0_bresp,
    input   wire                        M0_arvalid,
    output  wire                        M0_arready,
    input   wire    [ADDR_WIDTH-1:0 ]   M0_araddr,
    output  wire                        M0_rvalid,
    input   wire                        M0_rready,
    output  wire    [DATA_WIDTH-1:0 ]   M0_rdata,
    output  wire    [1:0            ]   M0_rresp,

    // from master1
    input   wire                        M1_awvalid,
    output  wire                        M1_awready,
    input   wire    [ADDR_WIDTH-1:0 ]   M1_awaddr,
    input   wire                        M1_wvalid,
    output  wire                        M1_wready,
    input   wire    [DATA_WIDTH-1:0 ]   M1_wdata,
    input   wire    [DATA_WIDTH/8-1:0]  M1_wstrb,
    output  wire                        M1_bvalid,
    input   wire                        M1_bready,
    output  wire    [1:0            ]   M1_bresp,
    input   wire                        M1_arvalid,
    output  wire                        M1_arready,
    input   wire    [ADDR_WIDTH-1:0 ]   M1_araddr,
    output  wire                        M1_rvalid,
    input   wire                        M1_rready,
    output  wire    [DATA_WIDTH-1:0 ]   M1_rdata,
    output  wire    [1:0            ]   M1_rresp,

    // to slave0
    output  wire                        S0_awvalid,
    input   wire                        S0_awready,
    output  wire    [ADDR_WIDTH-1:0 ]   S0_awaddr,
    output  wire                        S0_wvalid,
    input   wire                        S0_wready,
    output  wire    [DATA_WIDTH-1:0 ]   S0_wdata,
    output  wire    [DATA_WIDTH/8-1:0]  S0_wstrb,
    input   wire                        S0_bvalid,
    output  wire                        S0_bready,
    input   wire    [1:0            ]   S0_bresp,
    output  wire                        S0_arvalid,
    input   wire                        S0_arready,
    output  wire    [ADDR_WIDTH-1:0 ]   S0_araddr,
    input   wire                        S0_rvalid,
    output  wire                        S0_rready,
    input   wire    [DATA_WIDTH-1:0 ]   S0_rdata,
    input   wire    [1:0            ]   S0_rresp,

    // to slave1
    output  wire                        S1_awvalid,
    input   wire                        S1_awready,
    output  wire    [ADDR_WIDTH-1:0 ]   S1_awaddr,
    output  wire                        S1_wvalid,
    input   wire                        S1_wready,
    output  wire    [DATA_WIDTH-1:0 ]   S1_wdata,
    output  wire    [DATA_WIDTH/8-1:0]  S1_wstrb,
    input   wire                        S1_bvalid,
    output  wire                        S1_bready,
    input   wire    [1:0            ]   S1_bresp,
    output  wire                        S1_arvalid,
    input   wire                        S1_arready,
    output  wire    [ADDR_WIDTH-1:0 ]   S1_araddr,
    input   wire                        S1_rvalid,
    output  wire                        S1_rready,
    input   wire    [DATA_WIDTH-1:0 ]   S1_rdata,
    input   wire    [1:0            ]   S1_rresp,

    // to slave2
    output  wire                        S2_awvalid,
    input   wire                        S2_awready,
    output  wire    [ADDR_WIDTH-1:0 ]   S2_awaddr,
    output  wire                        S2_wvalid,
    input   wire                        S2_wready,
    output  wire    [DATA_WIDTH-1:0 ]   S2_wdata,
    output  wire    [DATA_WIDTH/8-1:0]  S2_wstrb,
    input   wire                        S2_bvalid,
    output  wire                        S2_bready,
    input   wire    [1:0            ]   S2_bresp,
    output  wire                        S2_arvalid,
    input   wire                        S2_arready,
    output  wire    [ADDR_WIDTH-1:0 ]   S2_araddr,
    input   wire                        S2_rvalid,
    output  wire                        S2_rready,
    input   wire    [DATA_WIDTH-1:0 ]   S2_rdata,
    input   wire    [1:0            ]   S2_rresp
);

    wire                    m_awvalid;
    wire                    m_awready;
    wire [ADDR_WIDTH-1:0 ]  m_awaddr;
    wire                    m_wvalid;
    wire                    m_wready;
    wire [DATA_WIDTH-1:0 ]  m_wdata;
    wire [DATA_WIDTH/8-1:0] m_wstrb;
    wire                    m_bvalid;
    wire                    m_bready;
    wire [1:0            ]  m_bresp;
    wire                    m_arvalid;
    wire                    m_arready;
    wire [ADDR_WIDTH-1:0 ]  m_araddr;
    wire                    m_rvalid;
    wire                    m_rready;
    wire [DATA_WIDTH-1:0 ]  m_rdata;
    wire [1:0            ]  m_rresp;
    
    arbiter #(
        .ADDR_WIDTH             (ADDR_WIDTH                 ),
        .DATA_WIDTH             (DATA_WIDTH                 )
    ) arbiter_inst (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        // master0 (ibus)
        .M0_awvalid             (M0_awvalid                 ),
        .M0_awready             (M0_awready                 ),
        .M0_awaddr              (M0_awaddr                  ),
        .M0_wvalid              (M0_wvalid                  ),
        .M0_wready              (M0_wready                  ),
        .M0_wdata               (M0_wdata                   ),
        .M0_wstrb               (M0_wstrb                   ),
        .M0_bvalid              (M0_bvalid                  ),
        .M0_bready              (M0_bready                  ),
        .M0_bresp               (M0_bresp                   ),
        .M0_arvalid             (M0_arvalid                 ),
        .M0_arready             (M0_arready                 ),
        .M0_araddr              (M0_araddr                  ),
        .M0_rvalid              (M0_rvalid                  ),
        .M0_rready              (M0_rready                  ),
        .M0_rdata               (M0_rdata                   ),
        .M0_rresp               (M0_rresp                   ),

        // master1 (dbus)
        .M1_awvalid             (M1_awvalid                 ),
        .M1_awready             (M1_awready                 ),
        .M1_awaddr              (M1_awaddr                  ),
        .M1_wvalid              (M1_wvalid                  ),
        .M1_wready              (M1_wready                  ),
        .M1_wdata               (M1_wdata                   ),
        .M1_wstrb               (M1_wstrb                   ),
        .M1_bvalid              (M1_bvalid                  ),
        .M1_bready              (M1_bready                  ),
        .M1_bresp               (M1_bresp                   ),
        .M1_arvalid             (M1_arvalid                 ),
        .M1_arready             (M1_arready                 ),
        .M1_araddr              (M1_araddr                  ),
        .M1_rvalid              (M1_rvalid                  ),
        .M1_rready              (M1_rready                  ),
        .M1_rdata               (M1_rdata                   ),
        .M1_rresp               (M1_rresp                   ),

        // master (output to slave)
        .M_awvalid              (m_awvalid                  ),
        .M_awready              (m_awready                  ),
        .M_awaddr               (m_awaddr                   ),
        .M_wvalid               (m_wvalid                   ),
        .M_wready               (m_wready                   ),
        .M_wdata                (m_wdata                    ),
        .M_wstrb                (m_wstrb                    ),
        .M_bvalid               (m_bvalid                   ),
        .M_bready               (m_bready                   ),
        .M_bresp                (m_bresp                    ),
        .M_arvalid              (m_arvalid                  ),
        .M_arready              (m_arready                  ),
        .M_araddr               (m_araddr                   ),
        .M_rvalid               (m_rvalid                   ),
        .M_rready               (m_rready                   ),
        .M_rdata                (m_rdata                    ),
        .M_rresp                (m_rresp                    )
    );

    xbar #(
        .ADDR_WIDTH             (ADDR_WIDTH                 ),
        .DATA_WIDTH             (DATA_WIDTH                 )
    ) xbar_inst (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        // master (input from arbiter)
        .S_awvalid              (m_awvalid                  ),
        .S_awready              (m_awready                  ),
        .S_awaddr               (m_awaddr                   ),
        .S_wvalid               (m_wvalid                   ),
        .S_wready               (m_wready                   ),
        .S_wdata                (m_wdata                    ),
        .S_wstrb                (m_wstrb                    ),
        .S_bvalid               (m_bvalid                   ),
        .S_bready               (m_bready                   ),
        .S_bresp                (m_bresp                    ),
        .S_arvalid              (m_arvalid                  ),
        .S_arready              (m_arready                  ),
        .S_araddr               (m_araddr                   ),
        .S_rvalid               (m_rvalid                   ),
        .S_rready               (m_rready                   ),
        .S_rdata                (m_rdata                    ),
        .S_rresp                (m_rresp                    ),

        // slave0
        .M0_awvalid             (S0_awvalid                 ),
        .M0_awready             (S0_awready                 ),
        .M0_awaddr              (S0_awaddr                  ),
        .M0_wvalid              (S0_wvalid                  ),
        .M0_wready              (S0_wready                  ),
        .M0_wdata               (S0_wdata                   ),
        .M0_wstrb               (S0_wstrb                   ),
        .M0_bvalid              (S0_bvalid                  ),
        .M0_bready              (S0_bready                  ),
        .M0_bresp               (S0_bresp                   ),
        .M0_arvalid             (S0_arvalid                 ),
        .M0_arready             (S0_arready                 ),
        .M0_araddr              (S0_araddr                  ),
        .M0_rvalid              (S0_rvalid                  ),
        .M0_rready              (S0_rready                  ),
        .M0_rdata               (S0_rdata                   ),
        .M0_rresp               (S0_rresp                   ),

        // slave1
        .M1_awvalid             (S1_awvalid                 ),
        .M1_awready             (S1_awready                 ),
        .M1_awaddr              (S1_awaddr                  ),
        .M1_wvalid              (S1_wvalid                  ),
        .M1_wready              (S1_wready                  ),
        .M1_wdata               (S1_wdata                   ),
        .M1_wstrb               (S1_wstrb                   ),
        .M1_bvalid              (S1_bvalid                  ),
        .M1_bready              (S1_bready                  ),
        .M1_bresp               (S1_bresp                   ),
        .M1_arvalid             (S1_arvalid                 ),
        .M1_arready             (S1_arready                 ),
        .M1_araddr              (S1_araddr                  ),
        .M1_rvalid              (S1_rvalid                  ),
        .M1_rready              (S1_rready                  ),
        .M1_rdata               (S1_rdata                   ),
        .M1_rresp               (S1_rresp                   ),

        // slave2
        .M2_awvalid             (S2_awvalid                 ),
        .M2_awready             (S2_awready                 ),
        .M2_awaddr              (S2_awaddr                  ),
        .M2_wvalid              (S2_wvalid                  ),
        .M2_wready              (S2_wready                  ),
        .M2_wdata               (S2_wdata                   ),
        .M2_wstrb               (S2_wstrb                   ),
        .M2_bvalid              (S2_bvalid                  ),
        .M2_bready              (S2_bready                  ),
        .M2_bresp               (S2_bresp                   ),
        .M2_arvalid             (S2_arvalid                 ),
        .M2_arready             (S2_arready                 ),
        .M2_araddr              (S2_araddr                  ),
        .M2_rvalid              (S2_rvalid                  ),
        .M2_rready              (S2_rready                  ),
        .M2_rdata               (S2_rdata                   ),
        .M2_rresp               (S2_rresp                   )
    );


endmodule
