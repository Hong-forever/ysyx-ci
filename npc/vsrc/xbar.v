module ysyx_25110270_xbar
#(
    parameter S0_BASE = 32'h0200_0000,
    parameter S0_SIZE = 32'h0001_0000
)(
    input   wire                        clk,
    input   wire                        rst,

    input   wire                        S_awvalid,
    output  wire                        S_awready,
    input   wire    [31:0]              S_awaddr,
    input   wire    [3:0]               S_awid,
    input   wire    [7:0]               S_awlen,
    input   wire    [2:0]               S_awsize,
    input   wire    [1:0]               S_awburst,
    input   wire                        S_wvalid,
    output  wire                        S_wready,
    input   wire    [31:0]              S_wdata,
    input   wire    [3:0]               S_wstrb,
    input   wire                        S_wlast,
    output  wire                        S_bvalid,
    input   wire                        S_bready,
    output  wire    [1:0]               S_bresp,
    output  wire    [3:0]               S_bid,
    input   wire                        S_arvalid,
    output  wire                        S_arready,
    input   wire    [31:0]              S_araddr,
    input   wire    [3:0]               S_arid,
    input   wire    [7:0]               S_arlen,
    input   wire    [2:0]               S_arsize,
    input   wire    [1:0]               S_arburst,
    output  wire                        S_rvalid,
    input   wire                        S_rready,
    output  wire    [31:0]              S_rdata,
    output  wire    [1:0]               S_rresp,
    output  wire                        S_rlast,
    output  wire    [3:0]               S_rid,

    // slave0
    output  wire                        M0_awvalid,
    input   wire                        M0_awready,
    output  wire    [31:0]              M0_awaddr,
    output  wire    [3:0]               M0_awid,
    output  wire    [7:0]               M0_awlen,
    output  wire    [2:0]               M0_awsize,
    output  wire    [1:0]               M0_awburst,
    output  wire                        M0_wvalid,
    input   wire                        M0_wready,
    output  wire    [31:0]              M0_wdata,
    output  wire    [3:0]               M0_wstrb,
    output  wire                        M0_wlast,
    input   wire                        M0_bvalid,
    output  wire                        M0_bready,
    input   wire    [1:0]               M0_bresp,
    input   wire    [3:0]               M0_bid,
    output  wire                        M0_arvalid,
    input   wire                        M0_arready,
    output  wire    [31:0]              M0_araddr,
    output  wire    [3:0]               M0_arid,
    output  wire    [7:0]               M0_arlen,
    output  wire    [2:0]               M0_arsize,
    output  wire    [1:0]               M0_arburst,
    input   wire                        M0_rvalid,
    output  wire                        M0_rready,
    input   wire    [31:0]              M0_rdata,
    input   wire    [1:0]               M0_rresp,
    input   wire                        M0_rlast,
    input   wire    [3:0]               M0_rid,

    // slave1
    output  wire                        M1_awvalid,
    input   wire                        M1_awready,
    output  wire    [31:0]              M1_awaddr,
    output  wire    [3:0]               M1_awid,
    output  wire    [7:0]               M1_awlen,
    output  wire    [2:0]               M1_awsize,
    output  wire    [1:0]               M1_awburst,
    output  wire                        M1_wvalid,
    input   wire                        M1_wready,
    output  wire    [31:0]              M1_wdata,
    output  wire    [3:0]               M1_wstrb,
    output  wire                        M1_wlast,
    input   wire                        M1_bvalid,
    output  wire                        M1_bready,
    input   wire    [1:0]               M1_bresp,
    input   wire    [3:0]               M1_bid,
    output  wire                        M1_arvalid,
    input   wire                        M1_arready,
    output  wire    [31:0]              M1_araddr,
    output  wire    [3:0]               M1_arid,
    output  wire    [7:0]               M1_arlen,
    output  wire    [2:0]               M1_arsize,
    output  wire    [1:0]               M1_arburst,
    input   wire                        M1_rvalid,
    output  wire                        M1_rready,
    input   wire    [31:0]              M1_rdata,
    input   wire    [1:0]               M1_rresp,
    input   wire                        M1_rlast,
    input   wire    [3:0]               M1_rid
);

`ifdef __ICARUS__
    wire sel_slave0   = (S0_BASE <= S_araddr && S_araddr < S0_BASE + S0_SIZE) ||
                        (S0_BASE <= S_awaddr && S_awaddr < S0_BASE + S0_SIZE);
`else
    wire sel_slave0   = (S0_BASE <= S_araddr && S_araddr < S0_BASE + S0_SIZE);
`endif

`ifdef __ICARUS__    
    assign M0_awvalid = sel_slave0 ? S_awvalid  : 0 ;
    assign M0_awaddr  = sel_slave0 ? S_awaddr   : 0 ;
    assign M0_awid    = sel_slave0 ? S_awid     : 0 ;
    assign M0_awlen   = sel_slave0 ? S_awlen    : 0 ;
    assign M0_awsize  = sel_slave0 ? S_awsize   : 0 ;
    assign M0_awburst = sel_slave0 ? S_awburst  : 0 ;
    assign M0_wvalid  = sel_slave0 ? S_wvalid   : 0 ;
    assign M0_wdata   = sel_slave0 ? S_wdata    : 0 ;
    assign M0_wstrb   = sel_slave0 ? S_wstrb    : 0 ;
    assign M0_wlast   = sel_slave0 ? S_wlast    : 0 ;
    assign M0_bready  = sel_slave0 ? S_bready   : 0 ;
`else
    assign M0_awvalid = 0;  //只读
    assign M0_awaddr  = 0;
    assign M0_awid    = 0;
    assign M0_awlen   = 0;
    assign M0_awsize  = 0;
    assign M0_awburst = 0;
    assign M0_wvalid  = 0;
    assign M0_wdata   = 0;
    assign M0_wstrb   = 0;
    assign M0_wlast   = 0;
    assign M0_bready  = 0;
`endif 
    assign M0_arvalid = sel_slave0 ? S_arvalid  : 0 ;
    assign M0_araddr  = sel_slave0 ? S_araddr   : 0 ;
    assign M0_arid    = sel_slave0 ? S_arid     : 0 ;
    assign M0_arlen   = sel_slave0 ? S_arlen    : 0 ;
    assign M0_arsize  = sel_slave0 ? S_arsize   : 0 ;
    assign M0_arburst = sel_slave0 ? S_arburst  : 0 ;
    assign M0_rready  = 1'b1;

    assign M1_awvalid = sel_slave0 ? 0 : S_awvalid  ;
    assign M1_awaddr  = sel_slave0 ? 0 : S_awaddr   ;
    assign M1_awid    = sel_slave0 ? 0 : S_awid     ;
    assign M1_awlen   = sel_slave0 ? 0 : S_awlen    ;
    assign M1_awsize  = sel_slave0 ? 0 : S_awsize   ;
    assign M1_awburst = sel_slave0 ? 0 : S_awburst  ;
    assign M1_wvalid  = sel_slave0 ? 0 : S_wvalid   ;
    assign M1_wdata   = sel_slave0 ? 0 : S_wdata    ;
    assign M1_wstrb   = sel_slave0 ? 0 : S_wstrb    ;
    assign M1_wlast   = sel_slave0 ? 0 : S_wlast    ;
    assign M1_bready  = 1'b1;
    assign M1_arvalid = sel_slave0 ? 0 : S_arvalid  ;
    assign M1_araddr  = sel_slave0 ? 0 : S_araddr   ;
    assign M1_arid    = sel_slave0 ? 0 : S_arid     ;
    assign M1_arlen   = sel_slave0 ? 0 : S_arlen    ;
    assign M1_arsize  = sel_slave0 ? 0 : S_arsize   ;
    assign M1_arburst = sel_slave0 ? 0 : S_arburst  ;
    assign M1_rready  = 1'b1;

    assign S_awready  = sel_slave0 ? M0_awready : M1_awready ;
    assign S_wready   = sel_slave0 ? M0_wready  : M1_wready  ;
    assign S_bvalid   = sel_slave0 ? M0_bvalid  : M1_bvalid  ;
    assign S_bresp    = sel_slave0 ? M0_bresp   : M1_bresp   ;
    assign S_bid      = sel_slave0 ? M0_bid     : M1_bid     ;
    assign S_arready  = sel_slave0 ? M0_arready : M1_arready ;
    assign S_rvalid   = sel_slave0 ? M0_rvalid  : M1_rvalid  ;
    assign S_rdata    = sel_slave0 ? M0_rdata   : M1_rdata   ;
    assign S_rresp    = sel_slave0 ? M0_rresp   : M1_rresp   ;
    assign S_rlast    = sel_slave0 ? M0_rlast   : M1_rlast   ;
    assign S_rid      = sel_slave0 ? M0_rid     : M1_rid     ;

endmodule