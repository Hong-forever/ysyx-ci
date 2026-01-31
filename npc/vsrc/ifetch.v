`include "defines.v"

//------------------------------------------------------------------------
// 取指单元
//------------------------------------------------------------------------

module ysyx_25110270_ifetch
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire                        I_bru_taken,        //跳转指令
    input   wire    [`InstAddrBus   ]   I_bru_target,

    input   wire                        I_ready,

    input   wire                        I_flush,            // 指令冲刷
    input   wire    [`InstAddrBus   ]   I_flush_addr,       // 冲刷跳转地址

    output  wire    [`InstBus       ]   O_inst,
    output  wire    [`InstAddrBus   ]   O_inst_addr,
    output  wire                        O_valid,

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

    parameter IDLE = 0;
    parameter MEM = 1;
    parameter EXE = 2;
    reg [1:0] state, nstate;

    reg inst_arvalid;

    reg [`InstAddrBus] pc;
    wire [`InstAddrBus] pc_plus4;
    wire [`InstAddrBus] npc;

    always @(posedge clk) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= nstate;
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            inst_arvalid <= 1'b0;
        end else begin
            if(state == IDLE) begin
                inst_arvalid <= 1'b1;
            end else if(ibus_arvalid && ibus_arready) begin
                inst_arvalid <= 1'b0;
            end else begin
                inst_arvalid <= 1'b0;
            end
        end
    end

    always @(*) begin
        if(!rst_n) begin
            nstate = IDLE;
        end else begin
            case(state)
                IDLE: begin
                    nstate = ibus_arvalid & ibus_arready ? MEM : IDLE;
                end
                MEM: begin
                    nstate = ibus_rvalid & ibus_rready ? EXE : MEM;
                end
                EXE: begin
                    nstate = I_ready ? IDLE : EXE;
                end
                default: begin
                    nstate = IDLE;
                end 
            endcase
        end
    end

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

    reg [`InstBus] inst;
    always @(posedge clk) begin
        if(!rst_n) begin
            inst <= 0;
        end else if(ibus_rvalid && ibus_rready) begin
            inst <= ibus_rdata;
        end
    end

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
                 I_ready        ? pc_plus4        :
                 pc;
    
    assign pc_plus4 = pc + 32'h4;

    assign O_inst = inst;
    assign O_inst_addr = pc;
    assign O_valid = I_ready & state == EXE;
    
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

    assign ibus_arvalid = inst_arvalid;
    assign ibus_araddr = pc;

    assign ibus_rready = inst_rready;

    // reg arvalid_r;
    // wire [`RAMDOM_WIDTH-1:0] irandom;
    // reg [`RAMDOM_WIDTH-1:0] irandom_r;
    // reg req_flag;
    // always @(posedge clk) begin
    //     if(!rst_n) begin
    //         arvalid_r <= 1'b0;
    //         irandom_r <= 0;
    //         req_flag <= 1'b0;
    //     end else if(req_flag) begin
    //         irandom_r <= irandom_r - 1;
    //         if(irandom_r == 0) begin
    //             arvalid_r <= 1'b1;
    //             req_flag <= 1'b0;
    //         end
    //     end else if(state == IDLE && inst_arvalid && !arvalid_r) begin
    //         arvalid_r <= 1'b0;
    //         irandom_r <= irandom;
    //         req_flag <= 1'b1;
    //     end else if(ibus_arvalid && ibus_arready) begin
    //         arvalid_r <= 1'b0;
    //     end
    // end

    // assign ibus_arvalid = arvalid_r;

    // lfsr #(
    //     .WIDTH                  (`RAMDOM_WIDTH              )      
    // ) ilfsr_inst
    // (
    //     .clk                    (clk                        ),
    //     .rst_n                  (rst_n                      ),
    //     .I_seed                 (`SEED1                     ),
    //     .O_random               (irandom                    )
    // );

endmodule
