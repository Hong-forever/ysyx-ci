`include "defines.v"

module top
(
    input   wire                        clk,
    input   wire                        rst_n
);

    wire                    ibus_awvalid;
    wire                    ibus_awready;
    wire [`InstAddrBus   ]  ibus_awaddr;
    wire                    ibus_wvalid;
    wire                    ibus_wready;
    wire [`InstBus       ]  ibus_wdata;
    wire [`DBUS_MASK-1:0 ]  ibus_wstrb;
    wire                    ibus_bvalid;
    wire                    ibus_bready;
    wire [`AXI_RESP_BUS  ]  ibus_bresp;
    wire                    ibus_arvalid;
    wire                    ibus_arready;
    wire [`InstAddrBus   ]  ibus_araddr;
    wire                    ibus_rvalid;
    wire                    ibus_rready;
    wire [`InstBus       ]  ibus_rdata;
    wire [`AXI_RESP_BUS  ]  ibus_rresp;

    wire                    dbus_awvalid;
    wire                    dbus_awready;
    wire [`MemAddrBus    ]  dbus_awaddr;
    wire                    dbus_wvalid;
    wire                    dbus_wready;
    wire [`MemDataBus    ]  dbus_wdata;
    wire [`DBUS_MASK-1:0 ]  dbus_wstrb;
    wire                    dbus_bvalid;
    wire                    dbus_bready;
    wire [`AXI_RESP_BUS  ]  dbus_bresp;
    wire                    dbus_arvalid;
    wire                    dbus_arready;
    wire [`MemAddrBus    ]  dbus_araddr;
    wire                    dbus_rvalid;
    wire                    dbus_rready;
    wire [`MemDataBus    ]  dbus_rdata;
    wire [`AXI_RESP_BUS  ]  dbus_rresp;

    wire                    m_awvalid;
    wire                    m_awready;
    wire [`MemAddrBus    ]  m_awaddr;
    wire                    m_wvalid;
    wire                    m_wready;
    wire [`MemDataBus    ]  m_wdata;
    wire [`DBUS_MASK-1:0 ]  m_wstrb;
    wire                    m_bvalid;
    wire                    m_bready;
    wire [`AXI_RESP_BUS  ]  m_bresp;
    wire                    m_arvalid;
    wire                    m_arready;
    wire [`MemAddrBus    ]  m_araddr;
    wire                    m_rvalid;
    wire                    m_rready;
    wire [`MemDataBus    ]  m_rdata;
    wire [`AXI_RESP_BUS  ]  m_rresp;

    wire                    s0_awvalid;
    wire                    s0_awready;
    wire [`MemAddrBus    ]  s0_awaddr;
    wire                    s0_wvalid;
    wire                    s0_wready;
    wire [`MemDataBus    ]  s0_wdata;
    wire [`DBUS_MASK-1:0 ]  s0_wstrb;
    wire                    s0_bvalid;
    wire                    s0_bready;
    wire [`AXI_RESP_BUS  ]  s0_bresp;
    wire                    s0_arvalid;
    wire                    s0_arready;
    wire [`MemAddrBus    ]  s0_araddr;
    wire                    s0_rvalid;
    wire                    s0_rready;
    wire [`MemDataBus    ]  s0_rdata;
    wire [`AXI_RESP_BUS  ]  s0_rresp;

    wire                    s1_awvalid;
    wire                    s1_awready;
    wire [`MemAddrBus    ]  s1_awaddr;
    wire                    s1_wvalid;
    wire                    s1_wready;
    wire [`MemDataBus    ]  s1_wdata;
    wire [`DBUS_MASK-1:0 ]  s1_wstrb;
    wire                    s1_bvalid;
    wire                    s1_bready;
    wire [`AXI_RESP_BUS  ]  s1_bresp;
    wire                    s1_arvalid;
    wire                    s1_arready;
    wire [`MemAddrBus    ]  s1_araddr;
    wire                    s1_rvalid;
    wire                    s1_rready;
    wire [`MemDataBus    ]  s1_rdata;
    wire [`AXI_RESP_BUS  ]  s1_rresp;

    riscv_ic riscv_ic_inst
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        //ibus
        .ibus_awvalid           (ibus_awvalid               ),
        .ibus_awready           (ibus_awready               ),
        .ibus_awaddr            (ibus_awaddr                ),
        .ibus_wvalid            (ibus_wvalid                ),
        .ibus_wready            (ibus_wready                ),
        .ibus_wdata             (ibus_wdata                 ),
        .ibus_wstrb             (ibus_wstrb                 ),
        .ibus_bvalid            (ibus_bvalid                ),
        .ibus_bready            (ibus_bready                ),
        .ibus_bresp             (ibus_bresp                 ),
        .ibus_arvalid           (ibus_arvalid               ),
        .ibus_arready           (ibus_arready               ),
        .ibus_araddr            (ibus_araddr                ),
        .ibus_rvalid            (ibus_rvalid                ),
        .ibus_rready            (ibus_rready                ),
        .ibus_rdata             (ibus_rdata                 ),
        .ibus_rresp             (ibus_rresp                 ),

        //dbus
        .dbus_awvalid           (dbus_awvalid               ),
        .dbus_awready           (dbus_awready               ),
        .dbus_awaddr            (dbus_awaddr                ),
        .dbus_wvalid            (dbus_wvalid                ),
        .dbus_wready            (dbus_wready                ),
        .dbus_wdata             (dbus_wdata                 ),
        .dbus_wstrb             (dbus_wstrb                 ),
        .dbus_bvalid            (dbus_bvalid                ),
        .dbus_bready            (dbus_bready                ),
        .dbus_bresp             (dbus_bresp                 ),
        .dbus_arvalid           (dbus_arvalid               ),
        .dbus_arready           (dbus_arready               ),
        .dbus_araddr            (dbus_araddr                ),
        .dbus_rvalid            (dbus_rvalid                ),
        .dbus_rready            (dbus_rready                ),
        .dbus_rdata             (dbus_rdata                 ),
        .dbus_rresp             (dbus_rresp                 )
    );

    axi_arbiter #(
        .ADDR_WIDTH             (`MemAddrWidth              ),
        .DATA_WIDTH             (`MemDataWidth              )
    ) axi_arbiter_inst (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        // master0 (ibus)
        .M0_awvalid             (ibus_awvalid               ),
        .M0_awready             (ibus_awready               ),
        .M0_awaddr              (ibus_awaddr                ),
        .M0_wvalid              (ibus_wvalid                ),
        .M0_wready              (ibus_wready                ),
        .M0_wdata               (ibus_wdata                 ),
        .M0_wstrb               (ibus_wstrb                 ),
        .M0_bvalid              (ibus_bvalid                ),
        .M0_bready              (ibus_bready                ),
        .M0_bresp               (ibus_bresp                 ),
        .M0_arvalid             (ibus_arvalid               ),
        .M0_arready             (ibus_arready               ),
        .M0_araddr              (ibus_araddr                ),
        .M0_rvalid              (ibus_rvalid                ),
        .M0_rready              (ibus_rready                ),
        .M0_rdata               (ibus_rdata                 ),
        .M0_rresp               (ibus_rresp                 ),

        // master1 (dbus)
        .M1_awvalid             (dbus_awvalid               ),
        .M1_awready             (dbus_awready               ),
        .M1_awaddr              (dbus_awaddr                ),
        .M1_wvalid              (dbus_wvalid                ),
        .M1_wready              (dbus_wready                ),
        .M1_wdata               (dbus_wdata                 ),
        .M1_wstrb               (dbus_wstrb                 ),
        .M1_bvalid              (dbus_bvalid                ),
        .M1_bready              (dbus_bready                ),
        .M1_bresp               (dbus_bresp                 ),
        .M1_arvalid             (dbus_arvalid               ),
        .M1_arready             (dbus_arready               ),
        .M1_araddr              (dbus_araddr                ),
        .M1_rvalid              (dbus_rvalid                ),
        .M1_rready              (dbus_rready                ),
        .M1_rdata               (dbus_rdata                 ),
        .M1_rresp               (dbus_rresp                 ),

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
        .ADDR_WIDTH             (`MemAddrWidth              ),
        .DATA_WIDTH             (`MemDataWidth              ),
        .SLAVE_NUM              (2                          )
    ) xbar_inst (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        // slave (from arbiter)
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

        // master0 (to mem)
        .M0_awvalid             (s0_awvalid                 ),
        .M0_awready             (s0_awready                 ),
        .M0_awaddr              (s0_awaddr                  ),
        .M0_wvalid              (s0_wvalid                  ),
        .M0_wready              (s0_wready                  ),
        .M0_wdata               (s0_wdata                   ),
        .M0_wstrb               (s0_wstrb                   ),
        .M0_bvalid              (s0_bvalid                  ),
        .M0_bready              (s0_bready                  ),
        .M0_bresp               (s0_bresp                   ),
        .M0_arvalid             (s0_arvalid                 ),
        .M0_arready             (s0_arready                 ),
        .M0_araddr              (s0_araddr                  ),
        .M0_rvalid              (s0_rvalid                  ),
        .M0_rready              (s0_rready                  ),
        .M0_rdata               (s0_rdata                   ),
        .M0_rresp               (s0_rresp                   ),

        // master1
        .M1_awvalid             (s1_awvalid                 ),
        .M1_awready             (s1_awready                 ),
        .M1_awaddr              (s1_awaddr                  ),
        .M1_wvalid              (s1_wvalid                  ),
        .M1_wready              (s1_wready                  ),
        .M1_wdata               (s1_wdata                   ),
        .M1_wstrb               (s1_wstrb                   ),
        .M1_bvalid              (s1_bvalid                  ),
        .M1_bready              (s1_bready                  ),
        .M1_bresp               (s1_bresp                   ),
        .M1_arvalid             (s1_arvalid                 ),
        .M1_arready             (s1_arready                 ),
        .M1_araddr              (s1_araddr                  ),
        .M1_rvalid              (s1_rvalid                  ),
        .M1_rready              (s1_rready                  ),
        .M1_rdata               (s1_rdata                   ),
        .M1_rresp               (s1_rresp                   )
    );

    mem #(
        .ADDR_WIDTH             (`MemAddrWidth              ),
        .DATA_WIDTH             (`MemDataWidth              ),
        .MEM_DEPTH              (512                        ),
        .LFSR_SEED              (`SEED4                     )
    ) ram_inst (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .awvalid_i              (s0_awvalid                 ),
        .awready_o              (s0_awready                 ),
        .awaddr_i               (s0_awaddr                  ),
        .wvalid_i               (s0_wvalid                  ),
        .wready_o               (s0_wready                  ),
        .wdata_i                (s0_wdata                   ),
        .wstrb_i                (s0_wstrb                   ),
        .bvalid_o               (s0_bvalid                  ),
        .bready_i               (s0_bready                  ),
        .bresp_o                (s0_bresp                   ),
        .arvalid_i              (s0_arvalid                 ),
        .arready_o              (s0_arready                 ),
        .araddr_i               (s0_araddr                  ),
        .rvalid_o               (s0_rvalid                  ),
        .rready_i               (s0_rready                  ),
        .rdata_o                (s0_rdata                   ),
        .rresp_o                (s0_rresp                   )
    );



endmodule
