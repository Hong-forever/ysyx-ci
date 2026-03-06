`include "defines.v"

//------------------------------------------------------------------------
// 取指单元
//------------------------------------------------------------------------

module ysyx_25110270_ifetch
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire                        I_bru_taken,        //跳转指令
    input   wire    [31:0]              I_bru_target,

    input   wire                        I_valid,
    output  wire                        O_ready,
    output  wire                        O_valid,
    input   wire                        I_ready,

    input   wire                        I_flush,            // 指令冲刷
    input   wire    [31:0]              I_flush_addr,       // 冲刷跳转地址

    output  wire    [31:0]              O_inst,
    output  wire    [31:0]              O_inst_addr,

    //to bus
    output  wire                        ibus_awvalid,
    input   wire                        ibus_awready,
    output  wire    [31:0]              ibus_awaddr,
    output  wire    [3:0]               ibus_awid,
    output  wire    [7:0]               ibus_awlen,
    output  wire    [2:0]               ibus_awsize,
    output  wire    [1:0]               ibus_awburst,
    output  wire                        ibus_wvalid,
    input   wire                        ibus_wready,
    output  wire    [31:0]              ibus_wdata,
    output  wire    [3:0]               ibus_wstrb,
    output  wire                        ibus_wlast,
    input   wire                        ibus_bvalid,
    output  wire                        ibus_bready,
    input   wire    [1:0]               ibus_bresp,
    input   wire    [3:0]               ibus_bid,
    output  wire                        ibus_arvalid,
    input   wire                        ibus_arready,
    output  wire    [31:0]              ibus_araddr,
    output  wire    [3:0]               ibus_arid,
    output  wire    [7:0]               ibus_arlen,
    output  wire    [2:0]               ibus_arsize,
    output  wire    [1:0]               ibus_arburst,
    input   wire                        ibus_rvalid,
    output  wire                        ibus_rready,
    input   wire    [31:0]              ibus_rdata,
    input   wire    [1:0]               ibus_rresp,
    input   wire                        ibus_rlast,
    input   wire    [3:0]               ibus_rid
);

    //------------------------------------------------------------------------
    // 变量定义
    //------------------------------------------------------------------------

    parameter IDLE  = 2'b00;
    parameter CACHE = 2'b01;
    parameter MISS  = 2'b10;
    parameter EXE   = 2'b11;

    reg [1:0] state, nstate;

    wire cache_valid, cache_miss;

    reg inst_reqvalid;
    reg inst_arvalid;
    reg miss_reg;

    reg  [31:0] pc;
    reg  [31:0] inst;
    reg         inst_valid;
    wire [31:0] cache_data;
    wire [31:0] npc, pc_plus4;

    always @(posedge clk) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= nstate;
        end
    end

    wire inst_reqvalid_next = (state == IDLE) || I_valid;

    wire noneed_cache = pc >= `SramAddrBase && pc < (`SramAddrBase + `SramSize);

    always @(posedge clk) begin
        if(!rst_n) begin
            inst_reqvalid <= 1'b0;
            miss_reg <= 1'b0;
        end else begin
            inst_reqvalid <= inst_reqvalid_next;
            miss_reg <= cache_miss;
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            inst_arvalid <= 1'b0;
        end else if(ibus_arvalid && ibus_arready) begin
            inst_arvalid <= 1'b0;
        end else if(cache_miss & ~miss_reg || noneed_cache & inst_reqvalid) begin
            inst_arvalid <= 1'b1;
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            inst <= 0;
        end else if(cache_valid) begin
            inst <= cache_data;
        end else if(ibus_rvalid) begin
            inst <= ibus_rdata;
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            inst_valid <= 0;
        end else if(I_ready & inst_valid) begin
            inst_valid <= 1'b0;
        end else if(cache_valid | ibus_rvalid) begin
            inst_valid <= 1'b1;
        end
    end

    always @(*) begin
        if(!rst_n) begin
            nstate = IDLE;
        end else begin
            case(state)
                IDLE: begin
                    nstate = inst_reqvalid ? (noneed_cache ? MISS : CACHE) : IDLE;
                end
                CACHE: begin
                    nstate = cache_valid ? EXE : (cache_miss ? MISS : CACHE);
                end
                MISS: begin
                    nstate = ibus_rvalid ? EXE : MISS;
                end
                EXE: begin
                    nstate = I_valid ? IDLE : EXE;
                end
                default: begin
                    nstate = IDLE;
                end 
            endcase
        end
    end

    ysyx_25110270_icache 
    #(
        .ADDR_WIDTH             (32                         ),
        .DATA_WIDTH             (32                         ),
        .SET_NUM                (16                         ),
        .N_WAYS                 (1                          ),
        .BLOCK_SIZE             (4                          )
    ) icache
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .I_addr                 (pc                         ),
        .I_wr                   (ibus_rvalid                ),
        .I_wdata                (ibus_rdata                 ),
        .I_valid                (inst_reqvalid & ~noneed_cache | (cache_miss & ibus_rvalid)),
        .O_data                 (cache_data                 ),
        .O_valid                (cache_valid                ),
        .O_miss                 (cache_miss                 )
    );

`ifdef DEBUG
    always @(posedge clk) begin
        if(!rst_n) begin
            pc <= `RESET_VECTOR;
        end else if(ibus_arvalid && 
            !(
                (ibus_araddr >= `MromAddrBase  && ibus_araddr <= (`MromAddrBase + `MromSize - 1))   || 
                (ibus_araddr >= `SramAddrBase  && ibus_araddr <= (`SramAddrBase + `SramSize - 1))   ||
                (ibus_araddr >= `FlashAddrBase && ibus_araddr <= (`FlashAddrBase + `FlashSize - 1)) ||
                (ibus_araddr >= `PsramAddrBase && ibus_araddr <= (`PsramAddrBase + `PsramSize - 1)) ||
                (ibus_araddr >= `SdramAddrBase && ibus_araddr <= (`SdramAddrBase + `SdramSize - 1))
            )) begin
            pc <= 0;
            $error("IFETCH: PC address out of range at pc = 0x%08x", ibus_araddr);
        end else if(ibus_rresp != 2'b00) begin
            pc <= 0;
            $error("IFETCH: IBUS read error at pc = 0x%08x", ibus_araddr);
        end else if(state == EXE) begin
            pc <= npc;
        end
    end
`else
    always @(posedge clk) begin
        if(!rst_n) begin
            pc <= `RESET_VECTOR;
        end else if(state == EXE) begin
            pc <= npc;
        end
    end
`endif

    reg inst_rready;
    always @(posedge clk) begin
        if(!rst_n) begin
            inst_rready <= 1'b1;
        end else if(ibus_rvalid && ibus_rready) begin
            inst_rready <= 1'b0;
        end else begin
            inst_rready <= 1'b1;
        end
    end

    assign npc = I_flush        ? I_flush_addr    :
                 I_bru_taken    ? I_bru_target    :
                 I_valid        ? pc_plus4        :
                 pc;
    
    assign pc_plus4 = pc + 32'h4;

    reg ready;
    always @(posedge clk) begin
        if(!rst_n) begin
            ready <= 1'b1;
        end else if(I_valid) begin
            ready <= 1'b0;
        end else begin
            ready <= 1'b1;
        end
    end

    assign O_inst = inst;
    assign O_inst_addr = pc;
    assign O_valid = inst_valid;
    assign O_ready = ready;
    
    assign ibus_awvalid = 1'b0;
    assign ibus_awaddr = 0;
    assign ibus_awid = 0;
    assign ibus_awlen = 0;
    assign ibus_awsize = 0;
    assign ibus_awburst = 2'b01;

    assign ibus_wvalid = 1'b0;
    assign ibus_wdata = 0;
    assign ibus_wstrb = 0;
    assign ibus_wlast = 1'b0;

    assign ibus_bready = 1'b0;

    assign ibus_arid = 0;
    assign ibus_arlen = 8'b0000_0000;
    assign ibus_arsize = 3'b010;
    assign ibus_arburst = 2'b01;

    assign ibus_araddr = pc;

    assign ibus_rready = inst_rready;

`ifdef PERF
    import "DPI-C" function void ifetch_inst_get_nr_cal(input int inst, input int pc);
    import "DPI-C" function void iamat_cal(input int begin_flag, input int end_flag);

    always @(posedge clk) begin
        if(inst_valid && (|inst) && (|pc)) begin
            ifetch_inst_get_nr_cal(inst, pc);
        end
    end

    reg begin_flag_r;
    wire begin_flag = ibus_arvalid;
    wire end_flag   = ibus_rvalid && ibus_rready;

    always @(posedge clk) begin
        if(!rst_n) begin
            begin_flag_r <= 1'b0;
        end else begin
            begin_flag_r <= begin_flag;
        end
    end


    always @(posedge clk) begin
        if(begin_flag && !begin_flag_r) begin
            iamat_cal(1, 0);
        end else if(end_flag) begin
            iamat_cal(0, 1);
        end
    end

`endif

`ifndef LFSR
    assign ibus_arvalid = inst_arvalid;
`else
    reg arvalid_r;
    wire [`RAMDOM_WIDTH-1:0] irandom;
    reg [`RAMDOM_WIDTH-1:0] irandom_r;
    reg req_flag;
    always @(posedge clk) begin
        if(!rst_n) begin
            arvalid_r <= 1'b0;
            irandom_r <= 0;
            req_flag <= 1'b0;
        end else if(req_flag) begin
            irandom_r <= irandom_r - 1;
            if(irandom_r == 0) begin
                arvalid_r <= 1'b1;
                req_flag <= 1'b0;
            end
        end else if(state == IDLE && inst_arvalid && !arvalid_r) begin
            arvalid_r <= 1'b0;
            irandom_r <= irandom;
            req_flag <= 1'b1;
        end else if(ibus_arvalid && ibus_arready) begin
            arvalid_r <= 1'b0;
        end
    end

    assign ibus_arvalid = arvalid_r;

    lfsr #(
        .WIDTH                  (`RAMDOM_WIDTH              )      
    ) ilfsr_inst
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .I_seed                 (`SEED1                     ),
        .O_random               (irandom                    )
    );
`endif

endmodule
