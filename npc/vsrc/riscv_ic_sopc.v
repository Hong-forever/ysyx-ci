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


    wire [`INT_BUS    ] inq;
    wire timer_int;

    assign inq = {{(`INT_WIDTH-1){1'b0}}, timer_int};

    reg device_skip;
    
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
        .dbus_rresp             (dbus_rresp                 ),

        .device_skip            (device_skip                ),

        // from peripheral
        .I_int                  (inq                        )
    );

`ifdef DPIC
    import "DPI-C" function int paddr_read(input int raddr);
    import "DPI-C" function void paddr_write(input int waddr, input int wdata, input int wmask);
    `define SERIAL_MMIO 32'h1000_0000
    `define RTC_MMIO    32'h2000_0000
    `define RAMDOM_WIDTH 8

    wire [`RAMDOM_WIDTH-1:0] irandom, irandom2, drandom, drandom2;

    reg                    i_arready;
    reg                    d_awready;
    reg                    d_wready;
    reg                    d_arready;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            i_arready <= 1'b1;
            d_awready <= 1'b1;
            d_wready  <= 1'b1;
            d_arready <= 1'b1;
        end else begin
            i_arready <= ~(ibus_arvalid & i_arready);
            d_awready <= ~(dbus_awvalid & d_awready);
            d_wready  <= ~(dbus_wvalid  & d_wready);
            d_arready <= ~(dbus_arvalid & d_arready);
        end
    end

    reg [`InstBus] inst;
    reg            inst_valid;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            inst <= `ZeroWord;
            inst_valid <= 1'b0;
        end else begin
            if(ibus_arvalid && i_arready) begin
                inst <= paddr_read(ibus_araddr);
                inst_valid <= 1'b1;
            end else if(ibus_rready && inst_valid) begin
                inst <= `ZeroWord;
                inst_valid <= 1'b0;
            end
        end
    end

    reg [`MemDataBus] rdata;
    reg               rdata_valid;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rdata <= `ZeroWord;
            rdata_valid <= 1'b0;
        end else begin
            if(dbus_arvalid && d_arready) begin
                rdata <= paddr_read(dbus_araddr);
                rdata_valid <= 1'b1;
            end else if(dbus_rready && rdata_valid) begin
                rdata <= `ZeroWord;
                rdata_valid <= 1'b0;
            end
        end
    end

    reg wdata_valid;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            wdata_valid <= 1'b0;
            device_skip <= 1'b0;
        end else begin
            if(dbus_awvalid && d_awready && dbus_wvalid && d_wready) begin
                paddr_write(dbus_awaddr, dbus_wdata, {28'b0, dbus_wstrb});
                wdata_valid <= 1'b1;
                if((dbus_awaddr & ~32'h7) == `RTC_MMIO || (dbus_awaddr & ~32'h3) == `SERIAL_MMIO) begin
                    device_skip <= 1'b1;
                end
            end else if(dbus_bready && wdata_valid) begin
                wdata_valid <= 1'b0;
                device_skip <= 1'b0;
            end
        end
    end

    assign ibus_arready = i_arready;
    assign ibus_rvalid  = inst_valid;
    assign ibus_rdata   = inst;

    assign dbus_awready = d_awready;
    assign dbus_wready  = d_wready;
    assign dbus_bvalid  = wdata_valid;
    assign dbus_arready = d_arready;
    assign dbus_rvalid  = rdata_valid;
    assign dbus_rdata   = rdata;

    // lfsr #(
    //     .WIDTH                  (`RAMDOM_WIDTH              )      
    // ) ilfsr_inst
    // (
    //     .clk                    (clk                        ),
    //     .rst_n                  (rst_n                      ),
    //     .I_seed                 (8'h0                       ),
    //     .O_random               (irandom                    )
    // );

    // lfsr #(
    //     .WIDTH                  (`RAMDOM_WIDTH              )      
    // ) dlfsr_inst
    // (
    //     .clk                    (clk                        ),
    //     .rst_n                  (rst_n                      ),
    //     .I_seed                 (8'h0                       ),
    //     .O_random               (drandom                    )
    // );
    
    // lfsr #(
    //     .WIDTH                  (`RAMDOM_WIDTH              )      
    // ) ilfsr_inst2
    // (
    //     .clk                    (clk                        ),
    //     .rst_n                  (rst_n                      ),
    //     .I_seed                 (8'h0                       ),
    //     .O_random               (irandom2                   )
    // );

    // lfsr #(
    //     .WIDTH                  (`RAMDOM_WIDTH              )      
    // ) dlfsr_inst2
    // (
    //     .clk                    (clk                        ),
    //     .rst_n                  (rst_n                      ),
    //     .I_seed                 (8'h0                       ),
    //     .O_random               (drandom2                   )
    // );

`endif

endmodule
