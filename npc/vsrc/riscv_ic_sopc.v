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

    wire                    s_awvalid;
    wire                    s_awready;
    wire [`MemAddrBus    ]  s_awaddr;
    
    wire                    s_wvalid;
    wire                    s_wready;
    wire [`MemDataBus    ]  s_wdata;
    wire [`DBUS_MASK-1:0 ]  s_wstrb;

    wire                    s_bvalid;
    wire                    s_bready;
    wire [`AXI_RESP_BUS  ]  s_bresp;

    wire                    s_arvalid;
    wire                    s_arready;
    wire [`MemAddrBus    ]  s_araddr;

    wire                    s_rvalid;
    wire                    s_rready;
    wire [`MemDataBus    ]  s_rdata;
    wire [`AXI_RESP_BUS  ]  s_rresp;


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

        // slave (mem)
        .S_awvalid              (s_awvalid                  ),
        .S_awready              (s_awready                  ),
        .S_awaddr               (s_awaddr                   ),
        .S_wvalid               (s_wvalid                   ),
        .S_wready               (s_wready                   ),
        .S_wdata                (s_wdata                    ),
        .S_wstrb                (s_wstrb                    ),
        .S_bvalid               (s_bvalid                   ),
        .S_bready               (s_bready                   ),
        .S_bresp                (s_bresp                    ),
        .S_arvalid              (s_arvalid                  ),
        .S_arready              (s_arready                  ),
        .S_araddr               (s_araddr                   ),
        .S_rvalid               (s_rvalid                   ),
        .S_rready               (s_rready                   ),
        .S_rdata                (s_rdata                    ),
        .S_rresp                (s_rresp                    )
    );

    mem #(
        .ADDR_WIDTH             (`MemAddrWidth              ),
        .DATA_WIDTH             (`MemDataWidth              ),
        .MEM_DEPTH              (4096                       ),
        .LFSR_SEED              (`SEED4                     )
    ) ram_inst (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .awvalid_i              (s_awvalid                  ),
        .awready_o              (s_awready                  ),
        .awaddr_i               (s_awaddr                   ),
        .wvalid_i               (s_wvalid                   ),
        .wready_o               (s_wready                   ),
        .wdata_i                (s_wdata                    ),
        .wstrb_i                (s_wstrb                    ),
        .bvalid_o               (s_bvalid                   ),
        .bready_i               (s_bready                   ),
        .bresp_o                (s_bresp                    ),
        .arvalid_i              (s_arvalid                  ),
        .arready_o              (s_arready                  ),
        .araddr_i               (s_araddr                   ),
        .rvalid_o               (s_rvalid                   ),
        .rready_i               (s_rready                   ),
        .rdata_o                (s_rdata                    ),
        .rresp_o                (s_rresp                    )
    );


endmodule
