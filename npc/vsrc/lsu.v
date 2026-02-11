`include "defines.v"

//------------------------------------------------------------------------
// 访存单元
//------------------------------------------------------------------------

module ysyx_25110270_lsu
(
    input   wire                                    clk,
    input   wire                                    rst_n,

    input   wire    [31:0                       ]   I_inst,             //指令内容
    input   wire    [31:0                       ]   I_inst_addr,

    input   wire                                    I_valid,
    output  wire                                    O_ready,
    output  wire                                    O_valid,
    input   wire                                    I_ready,

    input   wire                                    I_rd_we,
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rd_waddr,
    input   wire    [31:0                       ]   I_rd_wdata,
    input   wire    [31:0                       ]   I_memory_addr,
    input   wire    [31:0                       ]   I_store_data,
    input   wire                                    I_ld_valid,
    input   wire                                    I_st_valid,
    input   wire    [2:0                        ]   I_ls_ctrl,
    input   wire                                    I_csr_valid,
    input   wire    [11:0                       ]   I_csr_addr,
    input   wire    [31:0                       ]   I_csr_wdata,
    input   wire    [`ysyx_25110270_ExceptBus   ]   I_except,

    input   wire                                    I_is_ldst,          //是否为访存指令

    output  wire    [31:0                       ]   O_inst,
    output  wire    [31:0                       ]   O_inst_addr,

    output  wire                                    O_rd_we,
    output  wire    [`ysyx_25110270_RegAddrBus  ]   O_rd_waddr,
    output  wire    [31:0                       ]   O_rd_wdata,
    output  wire                                    O_csr_valid,
    output  wire    [11:0                       ]   O_csr_addr,
    output  wire    [31:0                       ]   O_csr_wdata,
    output  wire    [`ysyx_25110270_ExceptBus   ]   O_except,

    output  wire                                    O_device_skip,

    //to bus
    output  wire                                    dbus_awvalid,
    input   wire                                    dbus_awready,
    output  wire    [31:0]                          dbus_awaddr,
    output  wire    [3:0 ]                          dbus_awid,
    output  wire    [7:0 ]                          dbus_awlen,
    output  wire    [2:0 ]                          dbus_awsize,
    output  wire    [1:0 ]                          dbus_awburst,
    output  wire                                    dbus_wvalid,
    input   wire                                    dbus_wready,
    output  wire    [31:0]                          dbus_wdata,
    output  wire    [3:0 ]                          dbus_wstrb,
    output  wire                                    dbus_wlast,
    input   wire                                    dbus_bvalid,
    output  wire                                    dbus_bready,
    input   wire    [1:0 ]                          dbus_bresp,
    input   wire    [3:0 ]                          dbus_bid,
    output  wire                                    dbus_arvalid,
    input   wire                                    dbus_arready,
    output  wire    [31:0]                          dbus_araddr,
    output  wire    [3:0 ]                          dbus_arid,
    output  wire    [7:0 ]                          dbus_arlen,
    output  wire    [2:0 ]                          dbus_arsize,
    output  wire    [1:0 ]                          dbus_arburst,
    input   wire                                    dbus_rvalid,
    output  wire                                    dbus_rready,
    input   wire    [31:0]                          dbus_rdata,
    input   wire    [1:0 ]                          dbus_rresp,
    input   wire                                    dbus_rlast,
    input   wire    [3:0 ]                          dbus_rid
);

    //------------------------------------------------------------------------
    // 存取结果
    //------------------------------------------------------------------------
    reg [31:0] rdata;
    always @(posedge clk) begin
        if (!rst_n) begin
            rdata <= 0;
        end else if(dbus_rvalid) begin
            rdata <= dbus_rdata;
        end
    end

    wire [31:0] lb_00_res = {{24{rdata[7]}},  rdata[7:0]};
    wire [31:0] lb_01_res = {{24{rdata[15]}}, rdata[15:8]};
    wire [31:0] lb_10_res = {{24{rdata[23]}}, rdata[23:16]};
    wire [31:0] lb_11_res = {{24{rdata[31]}}, rdata[31:24]};

    wire [31:0] lh_00_res = {{16{rdata[15]}}, rdata[15:0]};
    wire [31:0] lh_10_res = {{16{rdata[31]}}, rdata[31:16]};

    wire [31:0] lw_res = rdata;

    wire [31:0] lbu_00_res = {{24{1'b0}}, rdata[7:0]};
    wire [31:0] lbu_01_res = {{24{1'b0}}, rdata[15:8]};
    wire [31:0] lbu_10_res = {{24{1'b0}}, rdata[23:16]};
    wire [31:0] lbu_11_res = {{24{1'b0}}, rdata[31:24]};

    wire [31:0] lhu_00_res = {{16{1'b0}}, rdata[15:0]};
    wire [31:0] lhu_10_res = {{16{1'b0}}, rdata[31:16]};


    // 地址明辨
    wire [1:0] offset = I_memory_addr[1:0];

    //------------------------------------------------------------------------
    // 访存逻辑
    //------------------------------------------------------------------------

    wire [2:0] ld_ctrl = I_ld_valid ? I_ls_ctrl : 3'b111; // 111 no op

    reg [31:0] rd_data;
    always @(*) begin
        rd_data = I_rd_wdata;
        case({ld_ctrl, offset})
            {`ysyx_25110270_RV32I_F3_LB,  2'b00}: rd_data = lb_00_res;
            {`ysyx_25110270_RV32I_F3_LB,  2'b01}: rd_data = lb_01_res;
            {`ysyx_25110270_RV32I_F3_LB,  2'b10}: rd_data = lb_10_res;
            {`ysyx_25110270_RV32I_F3_LB,  2'b11}: rd_data = lb_11_res;

            {`ysyx_25110270_RV32I_F3_LH,  2'b00}: rd_data = lh_00_res;
            {`ysyx_25110270_RV32I_F3_LH,  2'b10}: rd_data = lh_10_res;

            {`ysyx_25110270_RV32I_F3_LW,  2'b00}: rd_data = lw_res;

            {`ysyx_25110270_RV32I_F3_LBU, 2'b00}: rd_data = lbu_00_res;
            {`ysyx_25110270_RV32I_F3_LBU, 2'b01}: rd_data = lbu_01_res;
            {`ysyx_25110270_RV32I_F3_LBU, 2'b10}: rd_data = lbu_10_res;
            {`ysyx_25110270_RV32I_F3_LBU, 2'b11}: rd_data = lbu_11_res;

            {`ysyx_25110270_RV32I_F3_LHU, 2'b00}: rd_data = lhu_00_res;
            {`ysyx_25110270_RV32I_F3_LHU, 2'b10}: rd_data = lhu_10_res;

            default: begin end
        endcase
    end

    //------------------------------------------------------------------------
    // 存储逻辑
    //------------------------------------------------------------------------

    reg [31:0] wdata;
    reg [3:0] data_mask;
    always @(posedge clk) begin
        if(!rst_n) begin
            wdata     <= 0;
            data_mask <= 0;
        end else begin
            case({I_ls_ctrl[1:0], offset})  // 00 sb, 01 sh, 10 sw
                {2'b00, 2'b00}: begin
                    wdata     <= {24'b0, I_store_data[7:0]};
                    data_mask <= 4'b0001;
                end
                {2'b00, 2'b01}: begin
                    wdata     <= {16'b0, I_store_data[7:0], 8'b0};
                    data_mask <= 4'b0010;
                end
                {2'b00, 2'b10}: begin
                    wdata     <= {8'b0, I_store_data[7:0], 16'b0};
                    data_mask <= 4'b0100;
                end
                {2'b00, 2'b11}: begin
                    wdata     <= {I_store_data[7:0], 24'b0};
                    data_mask <= 4'b1000;
                end
                {2'b01, 2'b00}: begin
                    wdata     <= {16'b0, I_store_data[15:0]};
                    data_mask <= 4'b0011;
                end
                {2'b01, 2'b10}: begin
                    wdata     <= {I_store_data[15:0], 16'b0};
                    data_mask <= 4'b1100;
                end
                {2'b10, 2'b00}: begin
                    wdata     <= I_store_data;
                    data_mask <= 4'b1111;
                end
                default: begin
                    wdata     <= 0;
                    data_mask <= 0;
                end
            endcase
        end
    end
    
    reg [2:0] data_axsize;
    always @(posedge clk) begin
        if(!rst_n) begin
            data_axsize <= 3'b000;
        end else begin
            case(I_ls_ctrl[1:0])  // 00 sb/lb/lbu, 01 sh/lh/lhu, 10 sw/lw
                2'b00:   data_axsize <= 3'b000;
                2'b01:   data_axsize <= 3'b001;
                2'b10:   data_axsize <= 3'b010;
                default: data_axsize <= 3'b000;
            endcase
        end
    end

    reg req_valid;
    always @(posedge clk) begin
        if(!rst_n) begin
            req_valid <= 1'b0;
        end else if(I_valid) begin
            req_valid <= 1'b1;
        end else if((I_ld_valid && dbus_arready) || (I_st_valid && dbus_awready))begin
            req_valid <= 1'b0;
        end
    end

    parameter IDLE = 3'b001;
    parameter MEM  = 3'b010;
    parameter WB   = 3'b100;

    reg data_avalid;
    reg [2:0] state, nstate;
    always @(posedge clk) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= nstate;
        end
    end

    wire ls_req = (I_ld_valid | I_st_valid) & req_valid;
    wire data_avalid_next = (ls_req && !(dbus_awready | dbus_arready)) || (I_valid && I_is_ldst);

    always @(posedge clk) begin
        if(!rst_n) begin
            data_avalid <= 0;
        end else begin
            data_avalid <= data_avalid_next;
        end
    end

    always @(*) begin
        if(!rst_n) begin
            nstate = IDLE;
        end else begin
            case(state)
                IDLE:    nstate = (dbus_awready | dbus_arready) ? MEM : IDLE;
                MEM:     nstate = (dbus_bvalid | dbus_rvalid)   ? WB  : MEM;
                WB:      nstate = IDLE;
                default: nstate = IDLE;
            endcase
        end
    end

    wire stallreq = ls_req | (state == MEM);

    reg inst_valid;
    reg ready;

    always @(posedge clk) begin
        if(!rst_n) begin
            inst_valid <= 1'b0;
        end else if(I_ready & inst_valid) begin
            inst_valid <= 1'b0;
        end else if((I_valid && ~I_is_ldst) || (dbus_bvalid || dbus_rvalid)) begin
            inst_valid <= 1'b1;
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            ready <= 1'b1;
        end else if(I_valid) begin
            ready <= 1'b0;
        end else if(~stallreq) begin
            ready <= 1'b1;
        end
    end

    //------------------------------------------------------------------------
    // 输出
    //------------------------------------------------------------------------
    assign O_inst = I_inst;
    assign O_inst_addr = I_inst_addr;
    assign O_valid = inst_valid;
    assign O_ready = ready;

    assign O_rd_we = I_rd_we;
    assign O_rd_waddr = I_rd_waddr;
    assign O_rd_wdata = rd_data;

    assign O_csr_valid = I_csr_valid;
    assign O_csr_addr = I_csr_addr;
    assign O_csr_wdata = I_csr_wdata;

    assign O_except = I_except;

    assign O_device_skip = (I_ld_valid | I_st_valid) & 
    (
        (I_memory_addr >= `ysyx_25110270_SERIAL_BASE & I_memory_addr < (`ysyx_25110270_SERIAL_BASE + `ysyx_25110270_SERIAL_SIZE)) |
        (I_memory_addr >= `ysyx_25110270_CLINT_BASE  & I_memory_addr < (`ysyx_25110270_CLINT_BASE  + `ysyx_25110270_CLINT_SIZE )) |
        (I_memory_addr >= `ysyx_25110270_SPI_BASE    & I_memory_addr < (`ysyx_25110270_SPI_BASE    + `ysyx_25110270_SPI_SIZE   )) |
        (I_memory_addr >= `ysyx_25110270_GPIO_BASE   & I_memory_addr < (`ysyx_25110270_GPIO_BASE   + `ysyx_25110270_GPIO_SIZE  )) |
        (I_memory_addr >= `ysyx_25110270_PS2_BASE    & I_memory_addr < (`ysyx_25110270_PS2_BASE    + `ysyx_25110270_PS2_SIZE   )) |
        (I_memory_addr >= `ysyx_25110270_VGA_BASE    & I_memory_addr < (`ysyx_25110270_VGA_BASE    + `ysyx_25110270_VGA_SIZE   )) |
        (I_memory_addr >= `ysyx_25110270_CHIPL_BASE  /*& I_memory_addr < (`ysyx_25110270_CHIPL_BASE  + `ysyx_25110270_CHIPL_SIZE )*/)
    );


    assign dbus_awvalid = data_avalid & I_st_valid;
    assign dbus_wvalid = data_avalid & I_st_valid;
    assign dbus_arvalid = data_avalid & I_ld_valid;

    assign dbus_awaddr = I_memory_addr;
    assign dbus_awid = 4'b0000;
    assign dbus_awlen = 8'b0000_0000;
    assign dbus_awsize = data_axsize;
    assign dbus_awburst = 2'b01;

    assign dbus_wdata = wdata;
    assign dbus_wstrb = data_mask;
    assign dbus_wlast = 1'b1;

    assign dbus_bready = 1'b1;

    assign dbus_araddr = I_memory_addr;
    assign dbus_arid = 4'b0000;
    assign dbus_arlen = 8'b0000_0000;
    assign dbus_arsize = data_axsize;
    assign dbus_arburst = 2'b01;

    assign dbus_rready = 1'b1;

`ifdef DEBUG
    wire not_in_mrom   = (I_memory_addr < `ysyx_25110270_MromAddrBase ) | (I_memory_addr >= (`ysyx_25110270_MromAddrBase  + `ysyx_25110270_MromSize   ));
    wire not_in_sram   = (I_memory_addr < `ysyx_25110270_SramAddrBase ) | (I_memory_addr >= (`ysyx_25110270_SramAddrBase  + `ysyx_25110270_SramSize   ));
    wire not_in_flash  = (I_memory_addr < `ysyx_25110270_FlashAddrBase) | (I_memory_addr >= (`ysyx_25110270_FlashAddrBase + `ysyx_25110270_FlashSize  ));
    wire not_in_psram  = (I_memory_addr < `ysyx_25110270_PsramAddrBase) | (I_memory_addr >= (`ysyx_25110270_PsramAddrBase + `ysyx_25110270_PsramSize  ));
    wire not_in_sdram  = (I_memory_addr < `ysyx_25110270_SdramAddrBase) | (I_memory_addr >= (`ysyx_25110270_SdramAddrBase + `ysyx_25110270_SdramSize  ));
    wire not_in_clint  = (I_memory_addr < `ysyx_25110270_CLINT_BASE   ) | (I_memory_addr >= (`ysyx_25110270_CLINT_BASE    + `ysyx_25110270_CLINT_SIZE ));
    wire not_in_serial = (I_memory_addr < `ysyx_25110270_SERIAL_BASE  ) | (I_memory_addr >= (`ysyx_25110270_SERIAL_BASE   + `ysyx_25110270_SERIAL_SIZE));
    wire not_in_spi    = (I_memory_addr < `ysyx_25110270_SPI_BASE     ) | (I_memory_addr >= (`ysyx_25110270_SPI_BASE      + `ysyx_25110270_SPI_SIZE   ));
    wire not_in_gpio   = (I_memory_addr < `ysyx_25110270_GPIO_BASE    ) | (I_memory_addr >= (`ysyx_25110270_GPIO_BASE     + `ysyx_25110270_GPIO_SIZE  ));
    wire not_in_ps2    = (I_memory_addr < `ysyx_25110270_PS2_BASE     ) | (I_memory_addr >= (`ysyx_25110270_PS2_BASE      + `ysyx_25110270_PS2_SIZE   ));
    wire not_in_vga    = (I_memory_addr < `ysyx_25110270_VGA_BASE     ) | (I_memory_addr >= (`ysyx_25110270_VGA_BASE      + `ysyx_25110270_VGA_SIZE   ));
    wire not_in_chipl  = (I_memory_addr < `ysyx_25110270_CHIPL_BASE   )/* | (I_memory_addr >= (`ysyx_25110270_CHIPL_BASE    + `ysyx_25110270_CHIPL_SIZE ))*/;

    wire not_in_device =  not_in_mrom & not_in_sram & not_in_flash & 
                          not_in_psram & not_in_sdram & not_in_clint & 
                          not_in_serial & not_in_spi & not_in_gpio & 
                          not_in_ps2 & not_in_vga & not_in_chipl;

    always @(posedge clk) begin
        if((dbus_arvalid || dbus_awvalid) && not_in_device) begin
            $error("LSU: Data read address out of range at pc 0x%08x, access addr 0x%08x!", I_inst_addr, I_memory_addr);
        end
        if(dbus_bvalid && dbus_bresp != 2'b00) begin
            $error("LSU: DBUS write error at pc 0x%08x!", I_inst_addr);
        end
        if(dbus_rvalid && dbus_rresp != 2'b00) begin
            $error("LSU: DBUS read error at pc 0x%08x!", I_inst_addr);
        end
    end
`endif

`ifdef PERF
    import "DPI-C" function void ls_data_cal();

    always @(posedge clk) begin
        if(dbus_bvalid & dbus_bready | dbus_rvalid & dbus_rready) begin
            ls_data_cal();
        end
    end
    
    import "DPI-C" function void ls_delay_cal(input int begin_flag, input int end_flag);

    reg begin_flag_r;
    wire begin_flag = dbus_arvalid | dbus_awvalid;
    wire end_flag   = (dbus_bvalid && dbus_bready) || (dbus_rvalid && dbus_rready);

    always @(posedge clk) begin
        if(!rst_n) begin
            begin_flag_r <= 1'b0;
        end else begin
            begin_flag_r <= begin_flag;
        end
    end

    always @(posedge clk) begin
        if(begin_flag & ~begin_flag_r) begin
            ls_delay_cal(1, 0);
        end else if(end_flag) begin
            ls_delay_cal(0, 1);
        end
    end

`endif

endmodule