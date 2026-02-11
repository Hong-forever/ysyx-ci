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

    parameter IDLE      = 2'b00;
    parameter M0_ACCESS = 2'b01;
    parameter M1_ACCESS = 2'b10;

    wire m0_write_req = M0_awvalid & M0_wvalid;
    wire m0_read_req = M0_arvalid;
    wire m1_write_req = M1_awvalid & M1_wvalid;
    wire m1_read_req = M1_arvalid;

    wire m0_req = m0_write_req | m0_read_req;
    wire m1_req = m1_write_req | m1_read_req;

    wire m_resp = (M_awready & M_wready) | M_arready;

    reg [1:0] state, nstate;                                

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
                IDLE: begin
                    if(m0_req && m_resp) begin
                        nstate = M0_ACCESS;
                    end else if(!m0_req && m1_req && m_resp) begin
                        nstate = M1_ACCESS;
                    end else begin
                        nstate = IDLE;
                    end
                end
                M0_ACCESS: begin
                    if((M_rvalid && M0_rready && M_rlast) || (M_bvalid && M0_bready)) begin
                        nstate = m1_req && m_resp ? M1_ACCESS : IDLE;
                    end else begin
                        nstate = M0_ACCESS;
                    end
                end
                M1_ACCESS: begin
                    if((M_rvalid && M1_rready && M_rlast) || (M_bvalid && M1_bready)) begin
                        nstate = m0_req && m_resp ? M0_ACCESS : IDLE;
                    end else begin
                        nstate = M1_ACCESS;
                    end
                end
                default: nstate = IDLE;
            endcase
        end
    end

    wire access_m0 = state == M0_ACCESS;
    wire access_m1 = state == M1_ACCESS;

    // AXI信号连接
    assign M_awvalid  = access_m0 ? M0_awvalid :
                        access_m1 ? M1_awvalid : 0;
    assign M_awaddr   = access_m0 ? M0_awaddr  :
                        access_m1 ? M1_awaddr  : 0;
    assign M_awid     = access_m0 ? M0_awid    :
                        access_m1 ? M1_awid    : 0;
    assign M_awlen    = access_m0 ? M0_awlen   :
                        access_m1 ? M1_awlen   : 0;
    assign M_awsize   = access_m0 ? M0_awsize  :
                        access_m1 ? M1_awsize  : 0;
    assign M_awburst  = access_m0 ? M0_awburst :
                        access_m1 ? M1_awburst : 0;
    assign M_wvalid   = access_m0 ? M0_wvalid  :
                        access_m1 ? M1_wvalid  : 0;
    assign M_wdata    = access_m0 ? M0_wdata   :
                        access_m1 ? M1_wdata   : 0;
    assign M_wstrb    = access_m0 ? M0_wstrb   :
                        access_m1 ? M1_wstrb   : 0;
    assign M_wlast    = access_m0 ? M0_wlast   :
                        access_m1 ? M1_wlast   : 0;
    assign M_bready   = access_m0 ? M0_bready  :
                        access_m1 ? M1_bready  : 0;
    assign M_arvalid  = access_m0 ? M0_arvalid :
                        access_m1 ? M1_arvalid : 0;
    assign M_araddr   = access_m0 ? M0_araddr  :
                        access_m1 ? M1_araddr  : 0;
    assign M_arid     = access_m0 ? M0_arid    :
                        access_m1 ? M1_arid    : 0;
    assign M_arlen    = access_m0 ? M0_arlen   :
                        access_m1 ? M1_arlen   : 0;
    assign M_arsize   = access_m0 ? M0_arsize  :
                        access_m1 ? M1_arsize  : 0;
    assign M_arburst  = access_m0 ? M0_arburst :
                        access_m1 ? M1_arburst : 0;
    assign M_rready   = access_m0 ? M0_rready  :
                        access_m1 ? M1_rready  : 0;

    assign M0_awready = access_m0 ? M_awready  : 0;
    assign M0_wready  = access_m0 ? M_wready   : 0;
    assign M0_bvalid  = access_m0 ? M_bvalid   : 0;
    assign M0_bresp   = access_m0 ? M_bresp    : 0;
    assign M0_bid     = access_m0 ? M_bid      : 0;
    assign M0_arready = access_m0 ? M_arready  : 0;
    assign M0_rvalid  = access_m0 ? M_rvalid   : 0;
    assign M0_rdata   = access_m0 ? M_rdata    : 0;
    assign M0_rresp   = access_m0 ? M_rresp    : 0;
    assign M0_rlast   = access_m0 ? M_rlast    : 0;
    assign M0_rid     = access_m0 ? M_rid      : 0;

    assign M1_awready = access_m1 ? M_awready  : 0;
    assign M1_wready  = access_m1 ? M_wready   : 0;
    assign M1_bvalid  = access_m1 ? M_bvalid   : 0;
    assign M1_bresp   = access_m1 ? M_bresp    : 0;
    assign M1_bid     = access_m1 ? M_bid      : 0;
    assign M1_arready = access_m1 ? M_arready  : 0;
    assign M1_rvalid  = access_m1 ? M_rvalid   : 0;
    assign M1_rdata   = access_m1 ? M_rdata    : 0;
    assign M1_rresp   = access_m1 ? M_rresp    : 0;
    assign M1_rlast   = access_m1 ? M_rlast    : 0;
    assign M1_rid     = access_m1 ? M_rid      : 0;

endmodule