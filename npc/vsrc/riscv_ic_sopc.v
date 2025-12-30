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

    Interconnect #(
        .ADDR_WIDTH             (`MemAddrWidth              ),
        .DATA_WIDTH             (`MemDataWidth              ),
        .MASTER_NUM             (2                          ),
        .SLAVE_NUM              (2                          )
    ) interconnect_inst (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        // master0
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

        // master1
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

        // slave0
        .S0_awvalid             (s0_awvalid                 ),
        .S0_awready             (s0_awready                 ),
        .S0_awaddr              (s0_awaddr                  ),
        .S0_wvalid              (s0_wvalid                  ),
        .S0_wready              (s0_wready                  ),
        .S0_wdata               (s0_wdata                   ),
        .S0_wstrb               (s0_wstrb                   ),
        .S0_bvalid              (s0_bvalid                  ),
        .S0_bready              (s0_bready                  ),
        .S0_bresp               (s0_bresp                   ),
        .S0_arvalid             (s0_arvalid                 ),
        .S0_arready             (s0_arready                 ),
        .S0_araddr              (s0_araddr                  ),
        .S0_rvalid              (s0_rvalid                  ),
        .S0_rready              (s0_rready                  ),
        .S0_rdata               (s0_rdata                   ),
        .S0_rresp               (s0_rresp                   ),

        // slave1
        .S1_awvalid             (s1_awvalid                 ),
        .S1_awready             (s1_awready                 ),
        .S1_awaddr              (s1_awaddr                  ),
        .S1_wvalid              (s1_wvalid                  ),
        .S1_wready              (s1_wready                  ),
        .S1_wdata               (s1_wdata                   ),
        .S1_wstrb               (s1_wstrb                   ),
        .S1_bvalid              (s1_bvalid                  ),
        .S1_bready              (s1_bready                  ),
        .S1_bresp               (s1_bresp                   ),
        .S1_arvalid             (s1_arvalid                 ),
        .S1_arready             (s1_arready                 ),
        .S1_araddr              (s1_araddr                  ),
        .S1_rvalid              (s1_rvalid                  ),
        .S1_rready              (s1_rready                  ),
        .S1_rdata               (s1_rdata                   ),
        .S1_rresp               (s1_rresp                   )
    );

    mem #(
        .ADDR_WIDTH             (`MemAddrWidth              ),
        .DATA_WIDTH             (`MemDataWidth              ),
        .MEM_DEPTH              (512                        ),
        .LFSR_SEED              (`SEED4                     )
    ) mem_inst (
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
