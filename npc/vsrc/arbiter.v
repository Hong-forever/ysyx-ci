`include "defines.v"

//------------------------------------------------------------------------
// AXI仲裁器模块
//------------------------------------------------------------------------

module arbiter
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

    // master (output to slave) 
    output  wire                        M_awvalid,
    input   wire                        M_awready,
    output  wire    [ADDR_WIDTH-1:0]    M_awaddr,
    output  wire                        M_wvalid,
    input   wire                        M_wready,
    output  wire    [DATA_WIDTH-1:0]    M_wdata,
    output  wire    [DATA_WIDTH/8-1:0]  M_wstrb,
    input   wire                        M_bvalid,
    output  wire                        M_bready,
    input   wire    [1:0]               M_bresp,
    output  wire                        M_arvalid,
    input   wire                        M_arready,
    output  wire    [ADDR_WIDTH-1:0]    M_araddr,
    input   wire                        M_rvalid,
    output  wire                        M_rready,
    input   wire    [DATA_WIDTH-1:0]    M_rdata,
    input   wire    [1:0]               M_rresp
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

    wire m_resp = (M_awready & M_wready) | M_arready;

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
                    if(m0_req && m_resp && !m1_req) begin
                        nstate = M0_ACCESS;
                    end else if(!m0_req && m1_req && m_resp) begin
                        nstate = M1_ACCESS;
                    end else if(m0_req && m1_req && m_resp) begin
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
                    if((M_rvalid && M0_rready) || (M_bvalid && M0_bready)) begin
                        if(m1_req && m_resp) begin
                            nstate = M1_ACCESS;
                        end else begin
                            nstate = IDLE;
                        end
                    end else begin 
                        nstate = M0_ACCESS;
                    end
                end
                M1_ACCESS: begin
                    if((M_rvalid && M1_rready) || (M_bvalid && M1_bready)) begin
                        if(m0_req && m_resp) begin
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
    assign M_awvalid  = (state == M0_ACCESS) ? M0_awvalid :
                        (state == M1_ACCESS) ? M1_awvalid : 0;
    assign M_awaddr   = (state == M0_ACCESS) ? M0_awaddr  :
                        (state == M1_ACCESS) ? M1_awaddr  : 0;
    assign M_wvalid   = (state == M0_ACCESS) ? M0_wvalid  :
                        (state == M1_ACCESS) ? M1_wvalid  : 0;
    assign M_wdata    = (state == M0_ACCESS) ? M0_wdata   :
                        (state == M1_ACCESS) ? M1_wdata   : 0;
    assign M_wstrb    = (state == M0_ACCESS) ? M0_wstrb   :
                        (state == M1_ACCESS) ? M1_wstrb   : 0;
    assign M_bready   = (state == M0_ACCESS) ? M0_bready  :
                        (state == M1_ACCESS) ? M1_bready  : 0;
    assign M_arvalid  = (state == M0_ACCESS) ? M0_arvalid :
                        (state == M1_ACCESS) ? M1_arvalid : 0;
    assign M_araddr   = (state == M0_ACCESS) ? M0_araddr  :
                        (state == M1_ACCESS) ? M1_araddr  : 0;
    assign M_rready   = (state == M0_ACCESS) ? M0_rready  :
                        (state == M1_ACCESS) ? M1_rready  : 0;

    assign M0_awready = (state == M0_ACCESS) ? M_awready  : 0;
    assign M0_wready  = (state == M0_ACCESS) ? M_wready   : 0;
    assign M0_bvalid  = (state == M0_ACCESS) ? M_bvalid   : 0;
    assign M0_bresp   = (state == M0_ACCESS) ? M_bresp    : 0;
    assign M0_arready = (state == M0_ACCESS) ? M_arready  : 0;
    assign M0_rvalid  = (state == M0_ACCESS) ? M_rvalid   : 0;
    assign M0_rdata   = (state == M0_ACCESS) ? M_rdata    : 0;
    assign M0_rresp   = (state == M0_ACCESS) ? M_rresp    : 0;

    assign M1_awready = (state == M1_ACCESS) ? M_awready  : 0;
    assign M1_wready  = (state == M1_ACCESS) ? M_wready   : 0;
    assign M1_bvalid  = (state == M1_ACCESS) ? M_bvalid   : 0;
    assign M1_bresp   = (state == M1_ACCESS) ? M_bresp    : 0;
    assign M1_arready = (state == M1_ACCESS) ? M_arready  : 0;
    assign M1_rvalid  = (state == M1_ACCESS) ? M_rvalid   : 0;
    assign M1_rdata   = (state == M1_ACCESS) ? M_rdata    : 0;
    assign M1_rresp   = (state == M1_ACCESS) ? M_rresp    : 0;

endmodule