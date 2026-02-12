`include "defines.v"

//------------------------------------------------------------------------
// AXI仲裁器模块
//------------------------------------------------------------------------

module ysyx_25110270_arbiter
(
    input   wire                        clk,
    input   wire                        rst_n,

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

    wire m0_req = M0_awvalid | M0_arvalid;
    wire m1_req = M1_awvalid | M1_arvalid;

    wire m0_resp = (M0_awvalid & M0_bvalid) | (M0_arvalid & M0_rvalid);
    wire m1_resp = (M1_awvalid & M1_bvalid) | (M1_arvalid & M1_rvalid);

    reg busy, sel_m0;

    always @(posedge clk) begin
        if(!rst_n) begin
            busy <= 0;
            sel_m0 <= 0;
        end else begin
            busy <= (m0_resp | m1_resp) ? 0 : (m0_req | m1_req) ? 1 : busy;
            sel_m0 <= m0_req ? 1 : m1_req ? 0 : sel_m0;
        end
    end


    // AXI信号连接
    assign M_awvalid  = sel_m0 ? M0_awvalid  : M1_awvalid;
    assign M_awaddr   = sel_m0 ? M0_awaddr   : M1_awaddr;
    assign M_awid     = sel_m0 ? M0_awid     : M1_awid;
    assign M_awlen    = sel_m0 ? M0_awlen    : M1_awlen;
    assign M_awsize   = sel_m0 ? M0_awsize   : M1_awsize;
    assign M_awburst  = sel_m0 ? M0_awburst  : M1_awburst;
    assign M_wvalid   = sel_m0 ? M0_wvalid   : M1_wvalid;
    assign M_wdata    = sel_m0 ? M0_wdata    : M1_wdata;
    assign M_wstrb    = sel_m0 ? M0_wstrb    : M1_wstrb;
    assign M_wlast    = sel_m0 ? M0_wlast    : M1_wlast;
    assign M_bready   = sel_m0 ? M0_bready   : M1_bready;
    assign M_arvalid  = sel_m0 ? M0_arvalid  : M1_arvalid;
    assign M_araddr   = sel_m0 ? M0_araddr   : M1_araddr;
    assign M_arid     = sel_m0 ? M0_arid     : M1_arid;
    assign M_arlen    = sel_m0 ? M0_arlen    : M1_arlen;
    assign M_arsize   = sel_m0 ? M0_arsize   : M1_arsize;
    assign M_arburst  = sel_m0 ? M0_arburst  : M1_arburst;
    assign M_rready   = sel_m0 ? M0_rready   : M1_rready;
    assign M0_awready = sel_m0 ? M_awready   : 0;
    assign M0_wready  = sel_m0 ? M_wready    : 0;
    assign M0_bvalid  = sel_m0 ? M_bvalid    : 0;
    assign M0_bresp   = sel_m0 ? M_bresp     : 0;
    assign M0_bid     = sel_m0 ? M_bid       : 0;
    assign M0_arready = sel_m0 ? M_arready   : 0;
    assign M0_rvalid  = sel_m0 ? M_rvalid    : 0;
    assign M0_rdata   = sel_m0 ? M_rdata     : 0;
    assign M0_rresp   = sel_m0 ? M_rresp     : 0;
    assign M0_rlast   = sel_m0 ? M_rlast     : 0;
    assign M0_rid     = sel_m0 ? M_rid       : 0;
    assign M1_awready = sel_m0 ? 0           : M_awready;
    assign M1_wready  = sel_m0 ? 0           : M_wready;
    assign M1_bvalid  = sel_m0 ? 0           : M_bvalid;
    assign M1_bresp   = sel_m0 ? 0           : M_bresp;
    assign M1_bid     = sel_m0 ? 0           : M_bid;
    assign M1_arready = sel_m0 ? 0           : M_arready;
    assign M1_rvalid  = sel_m0 ? 0           : M_rvalid;
    assign M1_rdata   = sel_m0 ? 0           : M_rdata;
    assign M1_rresp   = sel_m0 ? 0           : M_rresp;
    assign M1_rlast   = sel_m0 ? 0           : M_rlast;
    assign M1_rid     = sel_m0 ? 0           : M_rid;


endmodule