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

    input   wire                        I_fence_i,           // 指令同步

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

    reg  [31:0] pc;
    reg  [31:0] inst;
    reg         inst_valid;
    wire [31:0] cache_data;
    wire [31:0] npc, pc_plus4;

    wire inst_reqvalid_next = (state == IDLE) || (state == MISS) || I_valid;

    always @(posedge clk) begin
        if(!rst_n) begin
            inst_reqvalid <= 1'b0;
        end else begin
            inst_reqvalid <= inst_reqvalid_next;
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            inst <= 0;
        end else if(cache_valid) begin
            inst <= cache_data;
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            inst_valid <= 0;
        end else if(I_ready & inst_valid) begin
            inst_valid <= 1'b0;
        end else if(cache_valid) begin
            inst_valid <= 1'b1;
        end
    end


    always @(posedge clk) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= nstate;
        end
    end    
    
    always @(*) begin
        if(!rst_n) begin
            nstate = IDLE;
        end else begin
            case(state)
                IDLE:    nstate = inst_reqvalid ? CACHE : IDLE;
                CACHE:   nstate = cache_valid ? EXE : (cache_miss ? MISS : CACHE);
                MISS:    nstate = cache_valid ? EXE : MISS;
                EXE:     nstate = I_valid ? IDLE : EXE;
                default: nstate = IDLE;
            endcase
        end
    end

    ysyx_25110270_icache 
    #(
        .ADDR_WIDTH             (32                         ),
        .DATA_WIDTH             (32                         ),
        .SET_NUM                (8                          ),
        .N_WAYS                 (1                          ),
        .BLOCK_SIZE             (8                          )
    ) icache
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .I_addr                 (pc                         ),
        .I_valid                (inst_reqvalid              ),
        .O_data                 (cache_data                 ),
        .O_valid                (cache_valid                ),
        .O_miss                 (cache_miss                 ),

        .O_arvalid              (ibus_arvalid               ),
        .I_arready              (ibus_arready               ),
        .O_araddr               (ibus_araddr                ),
        .O_arlen                (ibus_arlen                 ),
        .O_arsize               (ibus_arsize                ),
        .O_arburst              (ibus_arburst               ),
        .I_rvalid               (ibus_rvalid                ),
        .O_rready               (ibus_rready                ),
        .I_rdata                (ibus_rdata                 ),
        .I_rlast                (ibus_rlast                 ),
        .I_rresp                (ibus_rresp                 ),

        .I_clear                (I_fence_i                  )
    );

`ifdef DEBUG
    always @(posedge clk) begin
        if(!rst_n) begin
            pc <= `ysyx_25110270_RESET_VECTOR;
        end else if(ibus_arvalid && 
            !(
                (ibus_araddr >= `ysyx_25110270_MromAddrBase  && ibus_araddr <= (`ysyx_25110270_MromAddrBase + `ysyx_25110270_MromSize - 1))   || 
                (ibus_araddr >= `ysyx_25110270_SramAddrBase  && ibus_araddr <= (`ysyx_25110270_SramAddrBase + `ysyx_25110270_SramSize - 1))   ||
                (ibus_araddr >= `ysyx_25110270_FlashAddrBase && ibus_araddr <= (`ysyx_25110270_FlashAddrBase + `ysyx_25110270_FlashSize - 1)) ||
                (ibus_araddr >= `ysyx_25110270_PsramAddrBase && ibus_araddr <= (`ysyx_25110270_PsramAddrBase + `ysyx_25110270_PsramSize - 1)) ||
                (ibus_araddr >= `ysyx_25110270_SdramAddrBase && ibus_araddr <= (`ysyx_25110270_SdramAddrBase + `ysyx_25110270_SdramSize - 1))
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
            pc <= `ysyx_25110270_RESET_VECTOR;
        end else if(state == EXE) begin
            pc <= npc;
        end
    end
`endif

    assign npc =    I_flush        ? I_flush_addr    :
                    I_bru_taken    ? I_bru_target    :
                    I_valid        ? pc_plus4        :
                    pc;
    
    assign pc_plus4 = pc + 32'h4;

    assign O_inst = inst;
    assign O_inst_addr = pc;
    assign O_valid = inst_valid;
    assign O_ready = 1'b1;
    
    assign ibus_awvalid = 1'b0;
    assign ibus_awaddr  = 0;
    assign ibus_awid    = 0;
    assign ibus_awlen   = 0;
    assign ibus_awsize  = 0;
    assign ibus_awburst = 2'b01;

    assign ibus_wvalid = 1'b0;
    assign ibus_wdata  = 0;
    assign ibus_wstrb  = 0;
    assign ibus_wlast  = 1'b0;

    assign ibus_bready = 1'b0;

    assign ibus_arid = 0;

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
    wire end_flag   = ibus_rvalid && ibus_rready && ibus_rlast;

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


endmodule
