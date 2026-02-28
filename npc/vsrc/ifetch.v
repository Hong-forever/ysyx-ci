`include "defines.v"

//------------------------------------------------------------------------
// 取指单元
//------------------------------------------------------------------------

module ysyx_25110270_ifetch
(
    input   wire                        clk,
    input   wire                        rst,

    input   wire                        I_bru_taken,        //跳转指令
    input   wire    [31:0]              I_bru_target,

    input   wire                        I_ready,
    output  wire                        O_valid,

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

    parameter IDLE  = 1'b0;
    parameter WAIT  = 1'b1;

    wire resp_valid;
    wire valid;

    reg  [31:0] pc;
    wire [31:0] inst;
    wire [31:0] pc_plus4;

    wire icache_clear = (inst == `ysyx_25110270_RV_FENCE_I) & valid;

    assign valid = I_ready & resp_valid;

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
        .rst                    (rst                        ),

        .I_valid                (I_ready                    ),
        .O_valid                (resp_valid                 ),

        .I_addr                 (pc                         ),
        .O_data                 (inst                       ),

        .I_clear                (icache_clear               ),

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
        .I_rresp                (ibus_rresp                 )
    );

    always @(posedge clk) begin
        if(rst) begin
            pc <= `ysyx_25110270_RESET_VECTOR;
        end else if(valid) begin     // WAIT
            if(I_flush) begin
                pc <= I_flush_addr;
            end else if(I_bru_taken) begin
                pc <= I_bru_target;
            end else begin
                pc <= pc_plus4;
            end
        end
    end

    assign pc_plus4 = pc + 32'h4;

    assign O_inst = inst;
    assign O_inst_addr = pc;
    assign O_valid = valid;
    
    assign ibus_awvalid = 1'b0;
    assign ibus_awaddr  = 0;
    assign ibus_awid    = 0;
    assign ibus_awlen   = 0;
    assign ibus_awsize  = 0;
    assign ibus_awburst = 2'b00;

    assign ibus_wvalid = 1'b0;
    assign ibus_wdata  = 0;
    assign ibus_wstrb  = 0;
    assign ibus_wlast  = 1'b0;

    assign ibus_bready = 1'b0;

    assign ibus_arid = 0;

`ifdef PERF
    import "DPI-C" function void iamat_cal(input int begin_flag, input int end_flag);

    reg begin_flag_r;
    wire begin_flag = ibus_arvalid;
    wire end_flag   = ibus_rvalid && ibus_rready && ibus_rlast;

    always @(posedge clk) begin
        if(rst) begin
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
