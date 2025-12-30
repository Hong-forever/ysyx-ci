`include "defines.v"

//------------------------------------------------------------------------
// AXI xbar模块
//------------------------------------------------------------------------

module xbar
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter SLAVE_NUM  = 2
)(
    input   wire                        clk,
    input   wire                        rst_n,

    // master (from arbiter)
    input   wire                        S_awvalid,
    output  reg                         S_awready,
    input   wire    [ADDR_WIDTH-1:0]    S_awaddr,
    input   wire                        S_wvalid,
    output  reg                         S_wready,
    input   wire    [DATA_WIDTH-1:0]    S_wdata,
    input   wire    [DATA_WIDTH/8-1:0]  S_wstrb,
    output  reg                         S_bvalid,
    input   wire                        S_bready,
    output  reg     [1:0]               S_bresp,
    input   wire                        S_arvalid,
    output  reg                         S_arready,
    input   wire    [ADDR_WIDTH-1:0]    S_araddr,
    output  reg                         S_rvalid,
    input   wire                        S_rready,
    output  reg     [DATA_WIDTH-1:0]    S_rdata,
    output  reg     [1:0]               S_rresp,

    // slave0
    output  reg                         M0_awvalid,
    input   wire                        M0_awready,
    output  reg     [ADDR_WIDTH-1:0]    M0_awaddr,
    output  reg                         M0_wvalid,
    input   wire                        M0_wready,
    output  reg     [DATA_WIDTH-1:0]    M0_wdata,
    output  reg     [DATA_WIDTH/8-1:0]  M0_wstrb,
    input   wire                        M0_bvalid,
    output  reg                         M0_bready,
    input   wire    [1:0]               M0_bresp,
    output  reg                         M0_arvalid,
    input   wire                        M0_arready,
    output  reg     [ADDR_WIDTH-1:0]    M0_araddr,
    input   wire                        M0_rvalid,
    output  reg                         M0_rready,
    input   wire    [DATA_WIDTH-1:0]    M0_rdata,
    input   wire    [1:0]               M0_rresp,

    // slave1
    output  reg                         M1_awvalid,
    input   wire                        M1_awready,
    output  reg     [ADDR_WIDTH-1:0]    M1_awaddr,
    output  reg                         M1_wvalid,
    input   wire                        M1_wready,
    output  reg     [DATA_WIDTH-1:0]    M1_wdata,
    output  reg     [DATA_WIDTH/8-1:0]  M1_wstrb,
    input   wire                        M1_bvalid,
    output  reg                         M1_bready,
    input   wire    [1:0]               M1_bresp,
    output  reg                         M1_arvalid,
    input   wire                        M1_arready,
    output  reg     [ADDR_WIDTH-1:0]    M1_araddr,
    input   wire                        M1_rvalid,
    output  reg                         M1_rready,
    input   wire    [DATA_WIDTH-1:0]    M1_rdata,
    input   wire    [1:0]               M1_rresp
);
    // Address decoding
    wire sel_slave0   = (32'h8000_0000 <= S_araddr && S_araddr < 32'h8100_0000) ||
                        (32'h8000_0000 <= S_awaddr && S_awaddr < 32'h8100_0000) ||
                        (32'h1000_0000 <= S_araddr && S_araddr < 32'h1000_1000) ||
                        (32'h1000_0000 <= S_awaddr && S_awaddr < 32'h1000_1000) ;

    wire sel_slave1 = 1'b0;
    // wire sel_slave1   = (32'h1000_0000 <= S_araddr && S_araddr < 32'h1000_1000) ||
    //                     (32'h1000_0000 <= S_awaddr && S_awaddr < 32'h1000_1000) ;
    
    always @(*) begin
        case(1'b1)
            sel_slave0: begin
                M0_awvalid = S_awvalid;
                M0_awaddr  = S_awaddr;
                M0_wvalid  = S_wvalid;
                M0_wdata   = S_wdata;
                M0_wstrb   = S_wstrb;
                M0_bready  = S_bready;
                M0_arvalid = S_arvalid;
                M0_araddr  = S_araddr;
                M0_rready  = S_rready;
                S_awready  = M0_awready;
                S_wready   = M0_wready;
                S_bvalid   = M0_bvalid;
                S_bresp    = M0_bresp;
                S_arready  = M0_arready;
                S_rvalid   = M0_rvalid;
                S_rdata    = M0_rdata;
                S_rresp    = M0_rresp;
            end
            sel_slave1: begin
                M1_awvalid = S_awvalid;
                M1_awaddr  = S_awaddr;
                M1_wvalid  = S_wvalid;
                M1_wdata   = S_wdata;
                M1_wstrb   = S_wstrb;
                M1_bready  = S_bready;
                M1_arvalid = S_arvalid;
                M1_araddr  = S_araddr;
                M1_rready  = S_rready;
                S_awready  = M1_awready;
                S_wready   = M1_wready;
                S_bvalid   = M1_bvalid;
                S_bresp    = M1_bresp;
                S_arready  = M1_arready;
                S_rvalid   = M1_rvalid;
                S_rdata    = M1_rdata;
                S_rresp    = M1_rresp;
            end
            default: begin
                M0_awvalid = 0;
                M0_awaddr  = 0;
                M0_wvalid  = 0;
                M0_wdata   = 0;
                M0_wstrb   = 0;
                M0_bready  = 0;
                M0_arvalid = 0;
                M0_araddr  = 0;
                M0_rready  = 0;
                M1_awvalid = 0;
                M1_awaddr  = 0;
                M1_wvalid  = 0;
                M1_wdata   = 0;
                M1_wstrb   = 0;
                M1_bready  = 0;
                M1_arvalid = 0;
                M1_araddr  = 0;
                M1_rready  = 0;
                S_awready  = M0_awready | M1_awready;
                S_wready   = M0_wready  | M1_wready;
                S_bvalid   = 0;
                S_bresp    = 0;
                S_arready  = M0_arready | M1_arready;
                S_rvalid   = 0;
                S_rdata    = 0;
                S_rresp    = 0;
            end
        endcase
    end


endmodule
