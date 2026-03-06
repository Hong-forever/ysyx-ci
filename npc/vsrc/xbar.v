`include "defines.v"

//------------------------------------------------------------------------
// AXI xbar模块
//------------------------------------------------------------------------

module ysyx_25110270_xbar
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire                        S_awvalid,
    output  reg                         S_awready,
    input   wire    [31:0]              S_awaddr,
    input   wire    [3:0]               S_awid,
    input   wire    [7:0]               S_awlen,
    input   wire    [2:0]               S_awsize,
    input   wire    [1:0]               S_awburst,
    input   wire                        S_wvalid,
    output  reg                         S_wready,
    input   wire    [31:0]              S_wdata,
    input   wire    [3:0]               S_wstrb,
    input   wire                        S_wlast,
    output  reg                         S_bvalid,
    input   wire                        S_bready,
    output  reg     [1:0]               S_bresp,
    output  reg     [3:0]               S_bid,
    input   wire                        S_arvalid,
    output  reg                         S_arready,
    input   wire    [31:0]              S_araddr,
    input   wire    [3:0]               S_arid,
    input   wire    [7:0]               S_arlen,
    input   wire    [2:0]               S_arsize,
    input   wire    [1:0]               S_arburst,
    output  reg                         S_rvalid,
    input   wire                        S_rready,
    output  reg     [31:0]              S_rdata,
    output  reg     [1:0]               S_rresp,
    output  reg                         S_rlast,
    output  reg     [3:0]               S_rid,

    // slave0
    output  reg                         M0_awvalid,
    input   wire                        M0_awready,
    output  reg     [31:0]              M0_awaddr,
    output  reg     [3:0]               M0_awid,
    output  reg     [7:0]               M0_awlen,
    output  reg     [2:0]               M0_awsize,
    output  reg     [1:0]               M0_awburst,
    output  reg                         M0_wvalid,
    input   wire                        M0_wready,
    output  reg     [31:0]              M0_wdata,
    output  reg     [3:0]               M0_wstrb,
    output  reg                         M0_wlast,
    input   wire                        M0_bvalid,
    output  reg                         M0_bready,
    input   wire    [1:0]               M0_bresp,
    input   wire    [3:0]               M0_bid,
    output  reg                         M0_arvalid,
    input   wire                        M0_arready,
    output  reg     [31:0]              M0_araddr,
    output  reg     [3:0]               M0_arid,
    output  reg     [7:0]               M0_arlen,
    output  reg     [2:0]               M0_arsize,
    output  reg     [1:0]               M0_arburst,
    input   wire                        M0_rvalid,
    output  reg                         M0_rready,
    input   wire    [31:0]              M0_rdata,
    input   wire    [1:0]               M0_rresp,
    input   wire                        M0_rlast,
    input   wire    [3:0]               M0_rid,

    // slave1
    output  reg                         M1_awvalid,
    input   wire                        M1_awready,
    output  reg     [31:0]              M1_awaddr,
    output  reg     [3:0]               M1_awid,
    output  reg     [7:0]               M1_awlen,
    output  reg     [2:0]               M1_awsize,
    output  reg     [1:0]               M1_awburst,
    output  reg                         M1_wvalid,
    input   wire                        M1_wready,
    output  reg     [31:0]              M1_wdata,
    output  reg     [3:0]               M1_wstrb,
    output  reg                         M1_wlast,
    input   wire                        M1_bvalid,
    output  reg                         M1_bready,
    input   wire    [1:0]               M1_bresp,
    input   wire    [3:0]               M1_bid,
    output  reg                         M1_arvalid,
    input   wire                        M1_arready,
    output  reg     [31:0]              M1_araddr,
    output  reg     [3:0]               M1_arid,
    output  reg     [7:0]               M1_arlen,
    output  reg     [2:0]               M1_arsize,
    output  reg     [1:0]               M1_arburst,
    input   wire                        M1_rvalid,
    output  reg                         M1_rready,
    input   wire    [31:0]              M1_rdata,
    input   wire    [1:0]               M1_rresp,
    input   wire                        M1_rlast,
    input   wire    [3:0]               M1_rid
);
    wire sel_slave0   = (`CLINT_BASE <= S_araddr && S_araddr < `CLINT_BASE + `CLINT_SIZE) ||
                        (`CLINT_BASE <= S_awaddr && S_awaddr < `CLINT_BASE + `CLINT_SIZE) ;
    

    always @(*) begin
        if(sel_slave0) begin
            M0_awvalid = S_awvalid;
            M0_awaddr  = S_awaddr;
            M0_awid    = S_awid;
            M0_awlen   = S_awlen;
            M0_awsize  = S_awsize;
            M0_awburst = S_awburst;
            M0_wvalid  = S_wvalid;
            M0_wdata   = S_wdata;
            M0_wstrb   = S_wstrb;
            M0_wlast   = S_wlast;
            M0_bready  = S_bready;
            M0_arvalid = S_arvalid;
            M0_araddr  = S_araddr;
            M0_arid    = S_arid;
            M0_arlen   = S_arlen;
            M0_arsize  = S_arsize;
            M0_arburst = S_arburst;
            M0_rready  = S_rready;
            S_awready  = M0_awready;
            S_wready   = M0_wready;
            S_bvalid   = M0_bvalid;
            S_bresp    = M0_bresp;
            S_bid      = M0_bid;
            S_arready  = M0_arready;
            S_rvalid   = M0_rvalid;
            S_rdata    = M0_rdata;
            S_rresp    = M0_rresp;
            S_rlast    = M0_rlast;
            S_rid      = M0_rid;
            M1_awvalid = 0;
            M1_awaddr  = 0;
            M1_awid    = 0;
            M1_awlen   = 0;
            M1_awsize  = 0;
            M1_awburst = 0;
            M1_wvalid  = 0;
            M1_wdata   = 0;
            M1_wstrb   = 0;
            M1_wlast   = 0;
            M1_bready  = 0;
            M1_arvalid = 0;
            M1_araddr  = 0;
            M1_arid    = 0;
            M1_arlen   = 0;
            M1_arsize  = 0;
            M1_arburst = 0;
            M1_rready  = 0;
        end else begin
            M1_awvalid = S_awvalid;
            M1_awaddr  = S_awaddr;
            M1_awid    = S_awid;
            M1_awlen   = S_awlen;
            M1_awsize  = S_awsize;
            M1_awburst = S_awburst;
            M1_wvalid  = S_wvalid;
            M1_wdata   = S_wdata;
            M1_wstrb   = S_wstrb;
            M1_wlast   = S_wlast;
            M1_bready  = S_bready;
            M1_arvalid = S_arvalid;
            M1_araddr  = S_araddr;
            M1_arid    = S_arid;
            M1_arlen   = S_arlen;
            M1_arsize  = S_arsize;
            M1_arburst = S_arburst;
            M1_rready  = S_rready;
            S_awready  = M1_awready;
            S_wready   = M1_wready;
            S_bvalid   = M1_bvalid;
            S_bresp    = M1_bresp;
            S_bid      = M1_bid;
            S_arready  = M1_arready;
            S_rvalid   = M1_rvalid;
            S_rdata    = M1_rdata;
            S_rresp    = M1_rresp;
            S_rlast    = M1_rlast;
            S_rid      = M1_rid;
            M0_awvalid = 0;
            M0_awaddr  = 0;
            M0_awid    = 0;
            M0_awlen   = 0;
            M0_awsize  = 0;
            M0_awburst = 0;
            M0_wvalid  = 0;
            M0_wdata   = 0;
            M0_wstrb   = 0;
            M0_wlast   = 0;
            M0_bready  = 0;
            M0_arvalid = 0;
            M0_araddr  = 0;
            M0_arid    = 0;
            M0_arlen   = 0;
            M0_arsize  = 0;
            M0_arburst = 0;
            M0_rready  = 0;
        end
    end


endmodule
