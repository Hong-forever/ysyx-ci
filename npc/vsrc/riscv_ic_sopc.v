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

    mem #(
        .ADDR_WIDTH             (`MemAddrWidth              ),
        .DATA_WIDTH             (`MemDataWidth              ),
        .ROM_DEPTH              (4096                       )
    ) rom_inst (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .awvalid_i              (ibus_awvalid               ),
        .awready_o              (ibus_awready               ),
        .awaddr_i               (ibus_awaddr                ),
        .wvalid_i               (ibus_wvalid                ),
        .wready_o               (ibus_wready                ),
        .wdata_i                (ibus_wdata                 ),
        .wstrb_i                (ibus_wstrb                 ),
        .bvalid_o               (ibus_bvalid                ),
        .bready_i               (ibus_bready                ),
        .bresp_o                (ibus_bresp                 ),
        .arvalid_i              (ibus_arvalid               ),
        .arready_o              (ibus_arready               ),
        .araddr_i               (ibus_araddr                ),
        .rvalid_o               (ibus_rvalid                ),
        .rready_i               (ibus_rready                ),
        .rdata_o                (ibus_rdata                 ),
        .rresp_o                (ibus_rresp                 )
    );

    mem #(
        .ADDR_WIDTH             (`MemAddrWidth              ),
        .DATA_WIDTH             (`MemDataWidth              ),
        .ROM_DEPTH              (4096                       )
    ) ram_inst (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .awvalid_i              (dbus_awvalid               ),
        .awready_o              (dbus_awready               ),
        .awaddr_i               (dbus_awaddr                ),
        .wvalid_i               (dbus_wvalid                ),
        .wready_o               (dbus_wready                ),
        .wdata_i                (dbus_wdata                 ),
        .wstrb_i                (dbus_wstrb                 ),
        .bvalid_o               (dbus_bvalid                ),
        .bready_i               (dbus_bready                ),
        .bresp_o                (dbus_bresp                 ),
        .arvalid_i              (dbus_arvalid               ),
        .arready_o              (dbus_arready               ),
        .araddr_i               (dbus_araddr                ),
        .rvalid_o               (dbus_rvalid                ),
        .rready_i               (dbus_rready                ),
        .rdata_o                (dbus_rdata                 ),
        .rresp_o                (dbus_rresp                 )
    );


endmodule
