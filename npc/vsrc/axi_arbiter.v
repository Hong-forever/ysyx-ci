`include "defines.v"

//------------------------------------------------------------------------
// AXI仲裁器模块
//------------------------------------------------------------------------

module axi_arbiter
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input   wire                        clk,
    input   wire                        rst_n,

    // master0 (ibus)
    input   wire                        M0_awvalid,
    output  wire                        M0_awready,
    input   wire    [ADDR_WIDTH-1:0]    M0_awaddr,
    input   wire                        M0_wvalid,
    output  wire                        M0_wready,
    input   wire    [DATA_WIDTH-1:0]    M0_wdata,
    input   wire    [DATA_WIDTH/8-1:0]  M0_wstrb,
    output  wire                        M0_bvalid,
    input   wire                        M0_bready,
    output  wire    [1:0]               M0_bresp,
    input   wire                        M0_arvalid,
    output  wire                        M0_arready,
    input   wire    [ADDR_WIDTH-1:0]    M0_araddr,
    output  wire                        M0_rvalid,
    input   wire                        M0_rready,
    output  wire    [DATA_WIDTH-1:0]    M0_rdata,
    output  wire    [1:0]               M0_rresp,

    // master1 (dbus)
    input   wire                        M1_awvalid,
    output  wire                        M1_awready,
    input   wire    [ADDR_WIDTH-1:0]    M1_awaddr,
    input   wire                        M1_wvalid,
    output  wire                        M1_wready,
    input   wire    [DATA_WIDTH-1:0]    M1_wdata,
    input   wire    [DATA_WIDTH/8-1:0]  M1_wstrb,
    output  wire                        M1_bvalid,
    input   wire                        M1_bready,
    output  wire    [1:0]               M1_bresp,
    input   wire                        M1_arvalid,
    output  wire                        M1_arready,
    input   wire    [ADDR_WIDTH-1:0]    M1_araddr,
    output  wire                        M1_rvalid,
    input   wire                        M1_rready,
    output  wire    [DATA_WIDTH-1:0]    M1_rdata,
    output  wire    [1:0]               M1_rresp,

    // slave (mem)
    output  wire                        S_awvalid,
    input   wire                        S_awready,
    output  wire    [ADDR_WIDTH-1:0]    S_awaddr,
    output  wire                        S_wvalid,
    input   wire                        S_wready,
    output  wire    [DATA_WIDTH-1:0]    S_wdata,
    output  wire    [DATA_WIDTH/8-1:0]  S_wstrb,
    input   wire                        S_bvalid,
    output  wire                        S_bready,
    input   wire    [1:0]               S_bresp,
    output  wire                        S_arvalid,
    input   wire                        S_arready,
    output  wire    [ADDR_WIDTH-1:0]    S_araddr,
    input   wire                        S_rvalid,
    output  wire                        S_rready,
    input   wire    [DATA_WIDTH-1:0]    S_rdata,
    input   wire    [1:0]               S_rresp
);

    parameter IDLE      = 2'b00;
    parameter ARBITRATE = 2'b01;
    parameter M0_ACCESS = 2'b10;
    parameter M1_ACCESS = 2'b11;

    wire m0_write_req = M0_awvalid & M0_wvalid;
    wire m0_read_req = M0_arvalid;
    wire m1_write_req = M1_awvalid & M1_wvalid;
    wire m1_read_req = M1_arvalid;

    wire m0_req = m0_write_req | m0_read_req;
    wire m1_req = m1_write_req | m1_read_req;

    wire s_resp = (S_awready & S_wready) | S_arready;

    reg [1:0] state, nstate;

    always @(posedge clk or negedge rst_n) begin
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
                    if(m0_req && s_resp && !m1_req) begin
                        nstate = M0_ACCESS;
                    end else if(!m0_req && m1_req && s_resp) begin
                        nstate = M1_ACCESS;
                    end else if(m0_req && m1_req && s_resp) begin
                        nstate = ARBITRATE;
                    end else begin
                        nstate = IDLE;
                    end
                end
                ARBITRATE: begin
                    if(m0_req) begin
                        nstate = M0_ACCESS;
                    end else if(m1_req) begin
                        nstate = M1_ACCESS;
                    end else begin
                        nstate = IDLE;
                    end
                end
                M0_ACCESS: begin
                    if((M0_rready && M0_rvalid) || (M0_bready && M0_bvalid)) begin
                        if(m1_req && s_resp) begin
                            nstate = M1_ACCESS;
                        end else begin
                            nstate = IDLE;
                        end
                    end else begin 
                        nstate = M0_ACCESS;
                    end
                end
                M1_ACCESS: begin
                    if((M1_rready && M1_rvalid) || (M1_bready && M1_bvalid)) begin
                        if(m0_req && s_resp) begin
                            nstate = M0_ACCESS;
                        end else begin
                            nstate = IDLE;
                        end
                    end else begin
                        nstate = M1_ACCESS;
                    end
                end
                default: nstate = IDLE;
            endcase
        end
    end

    // AXI信号连接
    assign S_awvalid  = (state == M0_ACCESS) ? M0_awvalid :
                        (state == M1_ACCESS) ? M1_awvalid : 0;
    assign S_awaddr   = (state == M0_ACCESS) ? M0_awaddr  :
                        (state == M1_ACCESS) ? M1_awaddr  : 0;
    assign S_wvalid   = (state == M0_ACCESS) ? M0_wvalid  :
                        (state == M1_ACCESS) ? M1_wvalid  : 0;
    assign S_wdata    = (state == M0_ACCESS) ? M0_wdata   :
                        (state == M1_ACCESS) ? M1_wdata   : 0;
    assign S_wstrb    = (state == M0_ACCESS) ? M0_wstrb   :
                        (state == M1_ACCESS) ? M1_wstrb   : 0;
    assign S_bready   = (state == M0_ACCESS) ? M0_bready  :
                        (state == M1_ACCESS) ? M1_bready  : 1;
    assign S_arvalid  = (state == M0_ACCESS) ? M0_arvalid :
                        (state == M1_ACCESS) ? M1_arvalid : 0;
    assign S_araddr   = (state == M0_ACCESS) ? M0_araddr  :
                        (state == M1_ACCESS) ? M1_araddr  : 0;
    assign S_rready   = (state == M0_ACCESS) ? M0_rready  :
                        (state == M1_ACCESS) ? M1_rready  : 1;

    assign M0_awready = (state == M0_ACCESS) ? S_awready  : 1;
    assign M0_wready  = (state == M0_ACCESS) ? S_wready   : 1;
    assign M0_bvalid  = (state == M0_ACCESS) ? S_bvalid   : 0;
    assign M0_bresp   = (state == M0_ACCESS) ? S_bresp    : 0;
    assign M0_arready = (state == M0_ACCESS) ? S_arready  : 1;
    assign M0_rvalid  = (state == M0_ACCESS) ? S_rvalid   : 0;
    assign M0_rdata   = (state == M0_ACCESS) ? S_rdata    : 0;
    assign M0_rresp   = (state == M0_ACCESS) ? S_rresp    : 0;

    assign M1_awready = (state == M1_ACCESS) ? S_awready  : 1;
    assign M1_wready  = (state == M1_ACCESS) ? S_wready   : 1;
    assign M1_bvalid  = (state == M1_ACCESS) ? S_bvalid   : 0;
    assign M1_bresp   = (state == M1_ACCESS) ? S_bresp    : 0;
    assign M1_arready = (state == M1_ACCESS) ? S_arready  : 1;
    assign M1_rvalid  = (state == M1_ACCESS) ? S_rvalid   : 0;
    assign M1_rdata   = (state == M1_ACCESS) ? S_rdata    : 0;
    assign M1_rresp   = (state == M1_ACCESS) ? S_rresp    : 0;

endmodule