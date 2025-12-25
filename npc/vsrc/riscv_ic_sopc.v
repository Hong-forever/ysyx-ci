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

    wire device_skip;
    
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

        // from peripheral
        .I_int                  (inq                        )
    );

`ifdef DPIC
    import "DPI-C" function int paddr_read(input int raddr);
    import "DPI-C" function void paddr_write(input int waddr, input int wdata, input int wmask);

    `define RAMDOM_WIDTH 8
    wire [`RAMDOM_WIDTH-1:0] irandom, irandom2, drandom, drandom2;

    reg ireq, dreq, ireq_flag, dreq_flag;
    reg [`RAMDOM_WIDTH-1:0] irandom_req, drandom_req;

    reg ireqReady, dreqReady;

    reg [`MemAddrBus] iaddr, daddr;
    reg [`MemDataBus] dwdata;
    reg [`DBUS_MASK-1:0] dmask;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ireq <= 1'b0;
            iaddr <= `ZeroWord;
            ireq_flag <= 1'b0;
            ireqReady <= 1'b1;
            irandom_req <= 0;

            dreq <= 1'b0;
            daddr <= `ZeroWord;
            dwdata <= `ZeroWord;
            dmask <= 0;
            dreq_flag <= 1'b0;
            dreqReady <= 1'b1;
            drandom_req <= 0;
        end else begin
            if(ibus_reqValid) begin
                ireq <= 1'b0;
                ireqReady <= 1'b0;
                iaddr <= ibus_addr;
                irandom_req <= irandom;
                ireq_flag <= 1'b1;
            end else begin
                if(ireq_flag) begin
                    irandom_req <= irandom_req - 1;
                    if(irandom_req == 0) begin
                        ireq <= 1'b1;
                        ireq_flag <= 1'b0;
                    end
                end else begin
                    ireq <= 1'b0;
                end
                ireqReady <= 1'b1;
            end

            if(dbus_reqValid) begin
                dreq <= 1'b0;
                dreqReady <= 1'b0;
                daddr <= dbus_addr;
                dwdata <= dbus_wdata;
                dmask <= dbus_mask;
                drandom_req <= drandom;
                dreq_flag <= 1'b1;
            end else begin
                if(dreq_flag) begin
                    drandom_req <= drandom_req - 1;
                    if(drandom_req == 0) begin
                        dreq <= 1'b1;
                        dreq_flag <= 1'b0;
                    end
                end else begin
                    dreq <= 1'b0;
                end
                dreqReady <= 1'b1;
            end
        end
    end

    reg [`InstBus] inst;
    reg inst_ready;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            inst <= `ZeroWord;
            inst_ready <= 1'b0;
        end else if(ireq) begin
            inst <= paddr_read(iaddr);
            inst_ready <= 1'b1;
        end else begin
            inst <= `ZeroWord;
            inst_ready <= 1'b0;
        end
    end

    reg [`MemDataBus] rdata;
    reg data_ready;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rdata <= `ZeroWord;
            data_ready <= 1'b0;
        end else if(dreq & ~dbus_we) begin
            rdata <= paddr_read(daddr);
            data_ready <= 1'b1;
        end else if(dreq & dbus_we) begin
            paddr_write(daddr, dwdata, {28'b0, dmask});
            data_ready <= 1'b1;
        end else begin
            rdata <= `ZeroWord;
            data_ready <= 1'b0;
        end
    end

    reg irdy, drdy, irdy_flag, drdy_flag;
    reg [`RAMDOM_WIDTH-1:0] irandom_rdy, drandom_rdy;
    reg [`InstBus] inst_rdy;
    reg [`MemDataBus] data_rdy;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            irdy <= 1'b0;
            irdy_flag <= 1'b0;
            inst_rdy <= `ZeroWord;
            irandom_rdy <= 0;

            drdy <= 1'b0;
            drdy_flag <= 1'b0;
            data_rdy <= `ZeroWord;
            drandom_rdy <= 0;
        end else begin
            if(inst_ready) begin
                irdy <= 1'b0;
                irdy_flag <= 1'b1;
                inst_rdy <= inst;
                irandom_rdy <= irandom2;
            end else begin
                if(irdy_flag) begin
                    irandom_rdy <= irandom_rdy - 1;
                    if(irandom_rdy == 0) begin
                        irdy <= 1'b1;
                        irdy_flag <= 1'b0;
                    end
                end else if(ibus_respReady) begin
                    irdy <= 1'b0;
                    inst_rdy <= `ZeroWord;
                end
            end

            if(data_ready) begin
                drdy <= 1'b0;
                drdy_flag <= 1'b1;
                data_rdy <= rdata;
                drandom_rdy <= drandom2;
            end else begin
                if(drdy_flag) begin
                    drandom_rdy <= drandom_rdy - 1;
                    if(drandom_rdy == 0) begin
                        drdy <= 1'b1;
                        drdy_flag <= 1'b0;
                    end
                end else if(dbus_respReady) begin
                    drdy <= 1'b0;
                    data_rdy <= `ZeroWord;
                end
            end
        end
    end

    assign ibus_reqReady = ireqReady;
    assign ibus_respValid = irdy;
    assign ibus_rdata = inst_rdy;

    assign dbus_reqReady = dreqReady;
    assign dbus_respValid = drdy;
    assign dbus_rdata = data_rdy;

    `define SERIAL_MMIO 32'h1000_0000
    `define RTC_MMIO    32'h2000_0000
    assign device_skip = ((dbus_addr & ~32'h3) == `SERIAL_MMIO) || ((dbus_addr & ~32'h7) == `RTC_MMIO);

    lfsr #(
        .WIDTH                  (`RAMDOM_WIDTH              )      
    ) ilfsr_inst
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .I_seed                 (8'h0                       ),
        .O_random               (irandom                    )
    );

    lfsr #(
        .WIDTH                  (`RAMDOM_WIDTH              )      
    ) dlfsr_inst
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .I_seed                 (8'h0                       ),
        .O_random               (drandom                    )
    );
    
    lfsr #(
        .WIDTH                  (`RAMDOM_WIDTH              )      
    ) ilfsr_inst2
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .I_seed                 (8'h0                       ),
        .O_random               (irandom2                   )
    );

    lfsr #(
        .WIDTH                  (`RAMDOM_WIDTH              )      
    ) dlfsr_inst2
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .I_seed                 (8'h0                       ),
        .O_random               (drandom2                   )
    );


`else
    rom #(
        .DATA_WIDTH     (32                     ),
        .ADDR_WIDTH     (32                     ),
        .ROM_DEPTH      (256                    )
    ) irom_inst
    (
        .clk            (clk                    ),
        .rst_n          (rst_n                  ),

        .ce_i           (ibus_reqValid               ),
        .addr_i         (ibus_addr              ),
        .data_o         (ibus_rdata             )
    );

    ram #(
        .DATA_WIDTH     (32                     ),
        .ADDR_WIDTH     (32                     ),
        .RAM_DEPTH      (256                    )
    ) dram_inst
    (
        .clk            (clk                    ),
        .rst_n          (rst_n                  ),

        .ce_i           (dbus_reqValid               ),
        .we_i           (dbus_we                ),
        .addr_i         (dbus_addr              ),
        .data_i         (dbus_wdata             ),
        .data_o         (dbus_rdata             ),
        .sel_i          (dbus_mask              )
    );
`endif

endmodule
