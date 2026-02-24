`include "defines.v"

//------------------------------------------------------------------------
// AXI仲裁器模块
//------------------------------------------------------------------------

module ysyx_25110270_arbiter
(
    input   wire                        clk,
    input   wire                        rst,

    input   wire                        M0_awvalid,
    output  wire                        M0_awready,
    input   wire    [31:0]              M0_awaddr,
    input   wire    [3:0]               M0_awid,
    input   wire    [7:0]               M0_awlen,
    input   wire    [2:0]               M0_awsize,
    input   wire    [1:0]               M0_awburst,
    input   wire                        M0_wvalid,
    output  wire                        M0_wready,
    input   wire    [31:0]              M0_wdata,
    input   wire    [3:0]               M0_wstrb,
    input   wire                        M0_wlast,
    output  wire                        M0_bvalid,
    input   wire                        M0_bready,
    output  wire    [1:0]               M0_bresp,
    output  wire    [3:0]               M0_bid,
    input   wire                        M0_arvalid,
    output  wire                        M0_arready,
    input   wire    [31:0]              M0_araddr,
    input   wire    [3:0]               M0_arid,
    input   wire    [7:0]               M0_arlen,
    input   wire    [2:0]               M0_arsize,
    input   wire    [1:0]               M0_arburst,
    output  wire                        M0_rvalid,
    input   wire                        M0_rready,
    output  wire    [31:0]              M0_rdata,
    output  wire    [1:0]               M0_rresp,
    output  wire                        M0_rlast,
    output  wire    [3:0]               M0_rid,

    input   wire                        M1_awvalid,
    output  wire                        M1_awready,
    input   wire    [31:0]              M1_awaddr,
    input   wire    [3:0]               M1_awid,
    input   wire    [7:0]               M1_awlen,
    input   wire    [2:0]               M1_awsize,
    input   wire    [1:0]               M1_awburst,
    input   wire                        M1_wvalid,
    output  wire                        M1_wready,
    input   wire    [31:0]              M1_wdata,
    input   wire    [3:0]               M1_wstrb,
    input   wire                        M1_wlast,
    output  wire                        M1_bvalid,
    input   wire                        M1_bready,
    output  wire    [1:0]               M1_bresp,
    output  wire    [3:0]               M1_bid,
    input   wire                        M1_arvalid,
    output  wire                        M1_arready,
    input   wire    [31:0]              M1_araddr,
    input   wire    [3:0]               M1_arid,
    input   wire    [7:0]               M1_arlen,
    input   wire    [2:0]               M1_arsize,
    input   wire    [1:0]               M1_arburst,
    output  wire                        M1_rvalid,
    input   wire                        M1_rready,
    output  wire    [31:0]              M1_rdata,
    output  wire    [1:0]               M1_rresp,
    output  wire                        M1_rlast,
    output  wire    [3:0]               M1_rid,

    output  wire                        M_awvalid,
    input   wire                        M_awready,
    output  wire    [31:0]              M_awaddr,
    output  wire    [3:0]               M_awid,
    output  wire    [7:0]               M_awlen,
    output  wire    [2:0]               M_awsize,
    output  wire    [1:0]               M_awburst,
    output  wire                        M_wvalid,
    input   wire                        M_wready,
    output  wire    [31:0]              M_wdata,
    output  wire    [3:0]               M_wstrb,
    output  wire                        M_wlast,
    input   wire                        M_bvalid,
    output  wire                        M_bready,
    input   wire    [1:0]               M_bresp,
    input   wire    [3:0]               M_bid,
    output  wire                        M_arvalid,
    input   wire                        M_arready,
    output  wire    [31:0]              M_araddr,
    output  wire    [3:0]               M_arid,
    output  wire    [7:0]               M_arlen,
    output  wire    [2:0]               M_arsize,
    output  wire    [1:0]               M_arburst,
    input   wire                        M_rvalid,
    output  wire                        M_rready,
    input   wire    [31:0]              M_rdata,
    input   wire    [1:0]               M_rresp,
    input   wire                        M_rlast,
    input   wire    [3:0]               M_rid
);

    parameter IDLE = 2'b00;
    parameter M0   = 2'b01;
    parameter M1   = 2'b10;

    wire m0_req = M0_awvalid | M0_arvalid;
    wire m1_req = M1_awvalid | M1_arvalid;

    wire m0_resp = M0_bvalid | (M0_rvalid & M0_rlast);
    wire m1_resp = M1_bvalid | (M1_rvalid & M1_rlast);

    reg [1:0] state;

    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
        end else begin
            case(state)
                IDLE: begin
                    if(m0_req) state <= M0;
                    else if(m1_req) state <= M1;
                end
                M0: begin
                    if(m0_resp) state <= (m1_req) ? M1 : IDLE;
                end
                M1: begin
                    if(m1_resp) state <= (m0_req) ? M0 : IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

    wire state_m0 = state[0];
    wire state_m1 = state[1];


    // AXI信号连接
    assign M_awvalid  = state_m0 ? M0_awvalid :
                        state_m1 ? M1_awvalid : 0;
    assign M_awaddr   = state_m0 ? M0_awaddr  :
                        state_m1 ? M1_awaddr  : 0;
    assign M_awid     = state_m0 ? M0_awid    :
                        state_m1 ? M1_awid    : 0;
    assign M_awlen    = state_m0 ? M0_awlen   :
                        state_m1 ? M1_awlen   : 0;
    assign M_awsize   = state_m0 ? M0_awsize  :
                        state_m1 ? M1_awsize  : 0;
    assign M_awburst  = state_m0 ? M0_awburst :
                        state_m1 ? M1_awburst : 0;
    assign M_wvalid   = state_m0 ? M0_wvalid  :
                        state_m1 ? M1_wvalid  : 0;
    assign M_wdata    = state_m0 ? M0_wdata   :
                        state_m1 ? M1_wdata   : 0;
    assign M_wstrb    = state_m0 ? M0_wstrb   :
                        state_m1 ? M1_wstrb   : 0;
    assign M_wlast    = state_m0 ? M0_wlast   :
                        state_m1 ? M1_wlast   : 0;
    assign M_bready   = state_m0 ? M0_bready  :
                        state_m1 ? M1_bready  : 0;
    assign M_arvalid  = state_m0 ? M0_arvalid :
                        state_m1 ? M1_arvalid : 0;
    assign M_araddr   = state_m0 ? M0_araddr  :
                        state_m1 ? M1_araddr  : 0;
    assign M_arid     = state_m0 ? M0_arid    :
                        state_m1 ? M1_arid    : 0;
    assign M_arlen    = state_m0 ? M0_arlen   :
                        state_m1 ? M1_arlen   : 0;
    assign M_arsize   = state_m0 ? M0_arsize  :
                        state_m1 ? M1_arsize  : 0;
    assign M_arburst  = state_m0 ? M0_arburst :
                        state_m1 ? M1_arburst : 0;
    assign M_rready   = state_m0 ? M0_rready  :
                        state_m1 ? M1_rready  : 0;

    assign M0_awready = state_m0 ? M_awready  : 0;
    assign M0_wready  = state_m0 ? M_wready   : 0;
    assign M0_bvalid  = state_m0 ? M_bvalid   : 0;
    assign M0_bresp   = state_m0 ? M_bresp    : 0;
    assign M0_bid     = state_m0 ? M_bid      : 0;
    assign M0_arready = state_m0 ? M_arready  : 0;
    assign M0_rvalid  = state_m0 ? M_rvalid   : 0;
    assign M0_rdata   = state_m0 ? M_rdata    : 0;
    assign M0_rresp   = state_m0 ? M_rresp    : 0;
    assign M0_rlast   = state_m0 ? M_rlast    : 0;
    assign M0_rid     = state_m0 ? M_rid      : 0;

    assign M1_awready = state_m1 ? M_awready  : 0;
    assign M1_wready  = state_m1 ? M_wready   : 0;
    assign M1_bvalid  = state_m1 ? M_bvalid   : 0;
    assign M1_bresp   = state_m1 ? M_bresp    : 0;
    assign M1_bid     = state_m1 ? M_bid      : 0;
    assign M1_arready = state_m1 ? M_arready  : 0;
    assign M1_rvalid  = state_m1 ? M_rvalid   : 0;
    assign M1_rdata   = state_m1 ? M_rdata    : 0;
    assign M1_rresp   = state_m1 ? M_rresp    : 0;
    assign M1_rlast   = state_m1 ? M_rlast    : 0;
    assign M1_rid     = state_m1 ? M_rid      : 0;


endmodule