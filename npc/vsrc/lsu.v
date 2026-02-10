`include "defines.v"

//------------------------------------------------------------------------
// 访存单元
//------------------------------------------------------------------------

module ysyx_25110270_lsu
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire    [`InstBus       ]   I_inst,             //指令内容
    input   wire    [`InstAddrBus   ]   I_inst_addr,

    input   wire                        I_valid,
    output  wire                        O_ready,
    output  wire                        O_valid,
    input   wire                        I_ready,

    input   wire                        I_rd_we,
    input   wire    [`RegAddrBus    ]   I_rd_waddr,
    input   wire    [`RegDataBus    ]   I_rd_wdata,
    input   wire    [`MemAddrBus    ]   I_memory_addr,
    input   wire    [`MemDataBus    ]   I_store_data,
    input   wire                        I_ls_valid,
    input   wire    [`ls_diff_bus   ]   I_ls_type,
    input   wire                        I_csr_we,
    input   wire    [`CSRAddrBus    ]   I_csr_waddr,
    input   wire    [`CSRDataBus    ]   I_csr_wdata,
    input   wire    [`ExceptBus     ]   I_except,

    input   wire                        I_is_ldst,          //是否为访存指令

    output  wire    [`InstBus       ]   O_inst,
    output  wire    [`InstAddrBus   ]   O_inst_addr,

    output  wire                        O_rd_we,
    output  wire    [`RegAddrBus    ]   O_rd_waddr,
    output  wire    [`RegDataBus    ]   O_rd_wdata,
    output  wire                        O_csr_we,
    output  wire    [`CSRAddrBus    ]   O_csr_waddr,
    output  wire    [`CSRDataBus    ]   O_csr_wdata,
    output  wire    [`ExceptBus     ]   O_except,

    output  wire                        O_device_skip,

    //to bus
    output  wire                        dbus_awvalid,
    input   wire                        dbus_awready,
    output  wire    [31:0]              dbus_awaddr,
    output  wire    [3:0]               dbus_awid,
    output  wire    [7:0]               dbus_awlen,
    output  wire    [2:0]               dbus_awsize,
    output  wire    [1:0]               dbus_awburst,
    output  wire                        dbus_wvalid,
    input   wire                        dbus_wready,
    output  wire    [31:0]              dbus_wdata,
    output  wire    [3:0]               dbus_wstrb,
    output  wire                        dbus_wlast,
    input   wire                        dbus_bvalid,
    output  wire                        dbus_bready,
    input   wire    [1:0]               dbus_bresp,
    input   wire    [3:0]               dbus_bid,
    output  wire                        dbus_arvalid,
    input   wire                        dbus_arready,
    output  wire    [31:0]              dbus_araddr,
    output  wire    [3:0]               dbus_arid,
    output  wire    [7:0]               dbus_arlen,
    output  wire    [2:0]               dbus_arsize,
    output  wire    [1:0]               dbus_arburst,
    input   wire                        dbus_rvalid,
    output  wire                        dbus_rready,
    input   wire    [31:0]              dbus_rdata,
    input   wire    [1:0]               dbus_rresp,
    input   wire                        dbus_rlast,
    input   wire    [3:0]               dbus_rid
);

    //------------------------------------------------------------------------
    // 存取结果
    //------------------------------------------------------------------------
    reg [`MemDataBus] rdata;
    always @(posedge clk) begin
        if (!rst_n) begin
            rdata <= 0;
        end else if(dbus_rvalid && dbus_rready) begin
            rdata <= dbus_rdata;
        end
    end

    wire [`MemDataBus] lb_00_res = {{24{rdata[7]}},  rdata[7:0]};
    wire [`MemDataBus] lb_01_res = {{24{rdata[15]}}, rdata[15:8]};
    wire [`MemDataBus] lb_10_res = {{24{rdata[23]}}, rdata[23:16]};
    wire [`MemDataBus] lb_11_res = {{24{rdata[31]}}, rdata[31:24]};

    wire [`MemDataBus] lh_00_res = {{16{rdata[15]}}, rdata[15:0]};
    wire [`MemDataBus] lh_10_res = {{16{rdata[31]}}, rdata[31:16]};

    wire [`MemDataBus] lw_res = rdata;

    wire [`MemDataBus] lbu_00_res = {{24{1'b0}}, rdata[7:0]};
    wire [`MemDataBus] lbu_01_res = {{24{1'b0}}, rdata[15:8]};
    wire [`MemDataBus] lbu_10_res = {{24{1'b0}}, rdata[23:16]};
    wire [`MemDataBus] lbu_11_res = {{24{1'b0}}, rdata[31:24]};

    wire [`MemDataBus] lhu_00_res = {{16{1'b0}}, rdata[15:0]};
    wire [`MemDataBus] lhu_10_res = {{16{1'b0}}, rdata[31:16]};

    wire [`MemDataBus] sb_00_res = {24'b0, I_store_data[7:0]};
    wire [`MemDataBus] sb_01_res = {16'b0, I_store_data[7:0], 8'b0};
    wire [`MemDataBus] sb_10_res = {8'b0, I_store_data[7:0], 16'b0};
    wire [`MemDataBus] sb_11_res = {I_store_data[7:0], 24'b0};

    wire [`MemDataBus] sh_00_res = {16'b0, I_store_data[15:0]};
    wire [`MemDataBus] sh_10_res = {I_store_data[15:0], 16'b0};

    wire [`MemDataBus] sw_res = I_store_data;

    // 地址明辨
    wire [1:0] memory_byte_addr = I_memory_addr[1:0];

    //------------------------------------------------------------------------
    // 访存逻辑
    //------------------------------------------------------------------------
    reg [`RegDataBus] rd_data;
    always @(*) begin
        rd_data = I_rd_wdata;
        case(I_ls_type)
            `ls_lb: begin
                case(memory_byte_addr)
                    2'b00: rd_data = lb_00_res;
                    2'b01: rd_data = lb_01_res;
                    2'b10: rd_data = lb_10_res;
                    2'b11: rd_data = lb_11_res;
                    default: begin end
                endcase
            end
            `ls_lh: begin
                case(memory_byte_addr[1])
                    1'b0: rd_data = lh_00_res;
                    1'b1: rd_data = lh_10_res;
                    default: begin end
                endcase
            end
            `ls_lw: begin
                rd_data = lw_res;
            end
            `ls_lbu: begin
                case(memory_byte_addr)
                    2'b00: rd_data = lbu_00_res;
                    2'b01: rd_data = lbu_01_res;
                    2'b10: rd_data = lbu_10_res;
                    2'b11: rd_data = lbu_11_res;
                    default: begin end
                endcase
            end
            `ls_lhu: begin
                case(memory_byte_addr[1])
                    1'b0: rd_data = lhu_00_res;
                    1'b1: rd_data = lhu_10_res;
                    default: begin end
                endcase
            end
            default: begin end
        endcase
    end

    //------------------------------------------------------------------------
    // 存储逻辑
    //------------------------------------------------------------------------

    reg [`MemDataBus] wdata;
    reg [3:0] data_mask;
    always @(posedge clk) begin
        if(!rst_n) begin
            wdata     <= 0;
            data_mask <= 0;
        end else begin
            case({I_ls_type, memory_byte_addr})
                {`ls_sb, 2'b00}: begin
                    wdata     <= sb_00_res;
                    data_mask <= 4'b0001;
                end
                {`ls_sb, 2'b01}: begin
                    wdata     <= sb_01_res;
                    data_mask <= 4'b0010;
                end
                {`ls_sb, 2'b10}: begin
                    wdata     <= sb_10_res;
                    data_mask <= 4'b0100;
                end
                {`ls_sb, 2'b11}: begin
                    wdata     <= sb_11_res;
                    data_mask <= 4'b1000;
                end
                {`ls_sh, 2'b00}: begin
                    wdata     <= sh_00_res;
                    data_mask <= 4'b0011;
                end
                {`ls_sh, 2'b10}: begin
                    wdata     <= sh_10_res;
                    data_mask <= 4'b1100;
                end
                {`ls_sw, 2'b00}: begin
                    wdata     <= sw_res;
                    data_mask <= 4'b1111;
                end
                default: begin
                    wdata     <= 0;
                    data_mask <= 0;
                end
            endcase
        end
    end
    
    reg [2:0] data_awsize;
    reg [2:0] data_arsize;
    always @(posedge clk) begin
        if(!rst_n) begin
            data_awsize <= 3'b000;
            data_arsize <= 3'b000;
        end else begin
            case(I_ls_type)
                `ls_sb:             data_awsize <= 3'b000;
                `ls_sh:             data_awsize <= 3'b001;
                `ls_sw:             data_awsize <= 3'b010;
                `ls_lb, `ls_lbu:    data_arsize <= 3'b000;
                `ls_lh, `ls_lhu:    data_arsize <= 3'b001;
                `ls_lw:             data_arsize <= 3'b010;
                default:            data_awsize <= 3'b000;
            endcase
        end
    end

    reg req_valid;
    always @(posedge clk) begin
        if(!rst_n) begin
            req_valid <= 1'b0;
        end else if(I_valid) begin
            req_valid <= 1'b1;
        end else if(I_ls_valid & (dbus_arready | dbus_awready)) begin
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

    wire ls_req = I_ls_valid & req_valid;
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
                IDLE:    nstate = data_avalid & (dbus_awready | dbus_arready) ? MEM : IDLE;
                MEM:     nstate = (dbus_bvalid | dbus_rvalid) ? WB : MEM;
                WB:      nstate = IDLE;
                default: nstate = IDLE;
            endcase
        end
    end


    reg data_bready;
    always @(posedge clk) begin
        if(!rst_n) begin
            data_bready <= 1'b1;
        end else if(dbus_bvalid && dbus_bready) begin
            data_bready <= 1'b0;
        end else begin
            data_bready <= 1'b1;
        end
    end

    reg data_rready;
    always @(posedge clk) begin
        if(!rst_n) begin
            data_rready <= 1'b1;
        end else if(dbus_rvalid && dbus_rready) begin
            data_rready <= 1'b0;
        end else begin
            data_rready <= 1'b1;
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

    assign O_csr_we = I_csr_we;
    assign O_csr_waddr = I_csr_waddr;
    assign O_csr_wdata = I_csr_wdata;

    assign O_except = I_except;

    assign O_device_skip = I_ls_valid & 
    (
        (I_memory_addr >= `SERIAL_BASE & I_memory_addr < (`SERIAL_BASE + `SERIAL_SIZE)) |
        (I_memory_addr >= `CLINT_BASE  & I_memory_addr < (`CLINT_BASE  + `CLINT_SIZE )) |
        (I_memory_addr >= `SPI_BASE    & I_memory_addr < (`SPI_BASE    + `SPI_SIZE   )) |
        (I_memory_addr >= `GPIO_BASE   & I_memory_addr < (`GPIO_BASE   + `GPIO_SIZE  )) |
        (I_memory_addr >= `PS2_BASE    & I_memory_addr < (`PS2_BASE    + `PS2_SIZE   )) |
        (I_memory_addr >= `VGA_BASE    & I_memory_addr < (`VGA_BASE    + `VGA_SIZE   )) |
        (I_memory_addr >= `CHIPL_BASE  /*& I_memory_addr < (`CHIPL_BASE  + `CHIPL_SIZE )*/)
    );


    assign dbus_awaddr = I_memory_addr;
    assign dbus_awid = 4'b0000;
    assign dbus_awlen = 8'b0000_0000;
    assign dbus_awsize = data_awsize;
    assign dbus_awburst = 2'b01;

    assign dbus_wdata = wdata;
    assign dbus_wstrb = data_mask;
    assign dbus_wlast = 1'b1;

    assign dbus_bready = data_bready;

    assign dbus_araddr = I_memory_addr;
    assign dbus_arid = 4'b0000;
    assign dbus_arlen = 8'b0000_0000;
    assign dbus_arsize = data_arsize;
    assign dbus_arburst = 2'b01;

    assign dbus_rready = data_rready;

`ifdef DEBUG
    wire not_in_mrom   = (I_memory_addr < `MromAddrBase ) | (I_memory_addr >= (`MromAddrBase  + `MromSize   ));
    wire not_in_sram   = (I_memory_addr < `SramAddrBase ) | (I_memory_addr >= (`SramAddrBase  + `SramSize   ));
    wire not_in_flash  = (I_memory_addr < `FlashAddrBase) | (I_memory_addr >= (`FlashAddrBase + `FlashSize  ));
    wire not_in_psram  = (I_memory_addr < `PsramAddrBase) | (I_memory_addr >= (`PsramAddrBase + `PsramSize  ));
    wire not_in_sdram  = (I_memory_addr < `SdramAddrBase) | (I_memory_addr >= (`SdramAddrBase + `SdramSize  ));
    wire not_in_clint  = (I_memory_addr < `CLINT_BASE   ) | (I_memory_addr >= (`CLINT_BASE    + `CLINT_SIZE ));
    wire not_in_serial = (I_memory_addr < `SERIAL_BASE  ) | (I_memory_addr >= (`SERIAL_BASE   + `SERIAL_SIZE));
    wire not_in_spi    = (I_memory_addr < `SPI_BASE     ) | (I_memory_addr >= (`SPI_BASE      + `SPI_SIZE   ));
    wire not_in_gpio   = (I_memory_addr < `GPIO_BASE    ) | (I_memory_addr >= (`GPIO_BASE     + `GPIO_SIZE  ));
    wire not_in_ps2    = (I_memory_addr < `PS2_BASE     ) | (I_memory_addr >= (`PS2_BASE      + `PS2_SIZE   ));
    wire not_in_vga    = (I_memory_addr < `VGA_BASE     ) | (I_memory_addr >= (`VGA_BASE      + `VGA_SIZE   ));
    wire not_in_chipl  = (I_memory_addr < `CHIPL_BASE   )/* | (I_memory_addr >= (`CHIPL_BASE    + `CHIPL_SIZE ))*/;

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

`ifndef LFSR
    assign dbus_awvalid = data_avalid & I_ls_type[`ls_diff_width-1];
    assign dbus_wvalid = data_avalid & I_ls_type[`ls_diff_width-1];
    assign dbus_arvalid = data_avalid & ~I_ls_type[`ls_diff_width-1];
`else
    reg avalid_r;
    wire [`RAMDOM_WIDTH-1:0] drandom;
    reg [`RAMDOM_WIDTH-1:0] drandom_r;
    reg req_flag;
    always @(posedge clk) begin
        if(!rst_n) begin
            avalid_r <= 1'b0;
            drandom_r <= 0;
            req_flag <= 1'b0;
        end else if(req_flag) begin
            drandom_r <= drandom_r - 1;
            if(drandom_r == 0) begin
                avalid_r <= 1'b1;
                req_flag <= 1'b0;
            end
        end else if(state == IDLE && data_avalid && !avalid_r) begin
            avalid_r <= 1'b0;
            drandom_r <= drandom;
            req_flag <= 1'b1;
        end else if((dbus_awvalid && dbus_awready) || (dbus_arvalid && dbus_arready)) begin
            avalid_r <= 1'b0;
        end
    end

    assign dbus_awvalid = avalid_r & I_ls_type[`ls_diff_width-1];
    assign dbus_wvalid = avalid_r & I_ls_type[`ls_diff_width-1];
    assign dbus_arvalid = avalid_r & ~I_ls_type[`ls_diff_width-1];

    lfsr #(
        .WIDTH                  (`RAMDOM_WIDTH              )      
    ) ilfsr_inst
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .I_seed                 (`SEED2                     ),
        .O_random               (drandom                    )
    );
`endif

endmodule