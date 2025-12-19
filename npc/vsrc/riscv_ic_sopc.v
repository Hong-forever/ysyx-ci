`include "defines.v"

module top
(
    input   wire                        clk,
    input   wire                        rst_n
);
    wire ibus_req;
    wire ibus_ready;
    wire ibus_we;
    wire [`MemAddrBus] ibus_addr;
    wire [`MemDataBus] ibus_wdata;
    wire [`DBUS_MASK-1:0] ibus_mask;
    wire [`MemDataBus] ibus_rdata;

    wire dbus_req;
    wire dbus_ready;
    wire dbus_we;
    wire [`MemAddrBus] dbus_addr;
    wire [`MemDataBus] dbus_wdata;
    wire [`DBUS_MASK-1:0] dbus_mask;
    wire [`MemDataBus] dbus_rdata;

    wire [`INT_BUS    ] inq;
    wire timer_int;

    assign inq = {{(`INT_WIDTH-1){1'b0}}, timer_int};

    wire device_skip;
    
    riscv_ic riscv_ic_inst
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        //ibus
        .O_ibus_req             (ibus_req                   ),
        .I_ibus_ready           (ibus_ready                 ),
        .O_ibus_we              (ibus_we                    ),
        .O_ibus_addr            (ibus_addr                  ),
        .O_ibus_data            (ibus_wdata                 ),
        .O_ibus_mask            (ibus_mask                  ),
        .I_ibus_data            (ibus_rdata                 ),

        //dbus
        .O_dbus_req             (dbus_req                   ),
        .I_dbus_ready           (dbus_ready                 ),
        .O_dbus_we              (dbus_we                    ),
        .O_dbus_addr            (dbus_addr                  ),
        .O_dbus_data            (dbus_wdata                 ),
        .O_dbus_mask            (dbus_mask                  ),
        .I_dbus_data            (dbus_rdata                 ),
        .device_skip            (device_skip                ),

        // from peripheral
        .I_int                  (inq                        )
    );

`ifdef DPIC
    import "DPI-C" function int paddr_read(input int raddr);
    import "DPI-C" function void paddr_write(input int waddr, input int wdata, input int wmask);

    `define RAMDOM_WIDTH 8
    wire [`RAMDOM_WIDTH-1:0] irandom, irandom2, drandom, drandom2;
    lfsr #(
        .WIDTH                  (`RAMDOM_WIDTH              )      
    ) ilfsr_inst
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .I_seed                 (8'h2                       ),
        .O_random               (irandom                    )
    );

    lfsr #(
        .WIDTH                  (`RAMDOM_WIDTH              )      
    ) dlfsr_inst
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .I_seed                 (8'h3                       ),
        .O_random               (drandom                    )
    );
    
    lfsr #(
        .WIDTH                  (`RAMDOM_WIDTH              )      
    ) ilfsr_inst2
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .I_seed                 (8'h4                       ),
        .O_random               (irandom2                   )
    );

    lfsr #(
        .WIDTH                  (`RAMDOM_WIDTH              )      
    ) dlfsr_inst2
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .I_seed                 (8'h5                       ),
        .O_random               (drandom2                   )
    );

    reg ireq, dreq, ireq_flag, dreq_flag;
    reg [`RAMDOM_WIDTH-1:0] irandom_req, drandom_req;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ireq <= 1'b0;
            ireq_flag <= 1'b0;
            dreq <= 1'b0;
            dreq_flag <= 1'b0;
            irandom_req <= 0;
            drandom_req <= 0;
        end else begin
            if(ibus_req) begin
                ireq <= 1'b0;
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
            end

            if(dbus_req) begin
                dreq <= 1'b0;
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
            inst <= paddr_read(ibus_addr);
            inst_ready <= 1'b1;
        end else begin
            inst <= `ZeroWord;
            inst_ready <= 1'b0;
        end
    end

    reg [`MemDataBus] data;
    reg data_ready;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data <= `ZeroWord;
            data_ready <= 1'b0;
        end else if(dreq & ~dbus_we) begin
            data <= paddr_read(dbus_addr);
            data_ready <= 1'b1;
        end else if(dreq & dbus_we) begin
            paddr_write(dbus_addr, dbus_wdata, {28'b0, dbus_mask});
            data_ready <= 1'b1;
        end else begin
            data <= `ZeroWord;
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
            drdy <= 1'b0;
            drdy_flag <= 1'b0;
            irandom_rdy <= 0;
            drandom_rdy <= 0;
            inst_rdy <= `ZeroWord;
            data_rdy <= `ZeroWord;
        end else begin
            if(inst_ready) begin
                irdy <= 1'b0;
                irandom_rdy <= irandom2;
                irdy_flag <= 1'b1;
                inst_rdy <= `ZeroWord;
            end else begin
                if(irdy_flag) begin
                    irandom_rdy <= irandom_rdy - 1;
                    if(irandom_rdy == 0) begin
                        irdy <= 1'b1;
                        irdy_flag <= 1'b0;
                        inst_rdy <= inst;
                    end
                end else begin
                    irdy <= 1'b0;
                    inst_rdy <= `ZeroWord;
                end
            end

            if(data_ready) begin
                drdy <= 1'b0;
                drandom_rdy <= drandom2;
                drdy_flag <= 1'b1;
                data_rdy <= `ZeroWord;
            end else begin
                if(drdy_flag) begin
                    drandom_rdy <= drandom_rdy - 1;
                    if(drandom_rdy == 0) begin
                        drdy <= 1'b1;
                        drdy_flag <= 1'b0;
                        data_rdy <= data;
                    end
                end else begin
                    drdy <= 1'b0;
                    data_rdy <= `ZeroWord;
                end
            end
        end
    end

    assign ibus_rdata = inst_rdy;
    assign ibus_ready = irdy;

    assign dbus_rdata = data_rdy;
    assign dbus_ready = drdy;

    `define SERIAL_MMIO 32'h1000_0000
    `define RTC_MMIO    32'h2000_0000
    assign device_skip = ((dbus_addr & ~32'h3) == `SERIAL_MMIO) || ((dbus_addr & ~32'h7) == `RTC_MMIO);

`else
    rom #(
        .DATA_WIDTH     (32                     ),
        .ADDR_WIDTH     (32                     ),
        .ROM_DEPTH      (256                    )
    ) irom_inst
    (
        .clk            (clk                    ),
        .rst_n          (rst_n                  ),

        .ce_i           (ibus_req               ),
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

        .ce_i           (dbus_req               ),
        .we_i           (dbus_we                ),
        .addr_i         (dbus_addr              ),
        .data_i         (dbus_wdata             ),
        .data_o         (dbus_rdata             ),
        .sel_i          (dbus_mask              )
    );
`endif

endmodule
