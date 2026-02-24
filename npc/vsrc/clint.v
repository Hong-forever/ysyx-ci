//------------------------------------------------------------------------
// clint模块
//------------------------------------------------------------------------

module ysyx_25110270_clint
#(
    parameter ADDR_WIDTH = 32,                  //地址总线宽度
    parameter DATA_WIDTH = 32                   //数据总线宽度
)(
    input   wire                        clk,        //时钟输入
    input   wire                        rst,      //复位输入

    // AXI接口
    input   wire                        awvalid_i,
    output  wire                        awready_o,
    input   wire    [ADDR_WIDTH-1:0 ]   awaddr_i,
    input   wire    [3:0 ]              awid_i,
    input   wire    [7:0 ]              awlen_i,
    input   wire    [2:0 ]              awsize_i,
    input   wire    [1:0 ]              awburst_i,
    input   wire                        wvalid_i,
    output  wire                        wready_o,
    input   wire    [DATA_WIDTH-1:0 ]   wdata_i,
    input   wire    [DATA_WIDTH/8-1:0]  wstrb_i,
    input   wire                        wlast_i,
    output  wire                        bvalid_o,
    input   wire                        bready_i,
    output  wire    [1:0 ]              bresp_o,
    output  wire    [3:0 ]              bid_o,
    input   wire                        arvalid_i,
    output  wire                        arready_o,
    input   wire    [ADDR_WIDTH-1:0 ]   araddr_i,
    input   wire    [3:0 ]              arid_i,
    input   wire    [7:0 ]              arlen_i,
    input   wire    [2:0 ]              arsize_i,
    input   wire    [1:0 ]              arburst_i,
    output  wire                        rvalid_o,
    input   wire                        rready_i,
    output  wire    [DATA_WIDTH-1:0 ]   rdata_o,
    output  wire    [1:0 ]              rresp_o,
    output  wire                        rlast_o,
    output  wire    [3:0 ]              rid_o
);

    reg [2*DATA_WIDTH-1:0] mtime;

    reg rdata_valid;
    always @(posedge clk) begin
        if(rst) begin
            rdata_valid <= 1'b0;
        end else begin
            if(rvalid_o && rready_i) begin
                rdata_valid <= 1'b0;
            end else if(arvalid_i) begin
                rdata_valid <= 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if(rst) begin
            mtime <= 64'b0;
        end else begin
            mtime <= mtime + 1'b1;
        end
    end

    assign awready_o = 1'b0;
    assign wready_o  = 1'b0;
    assign bvalid_o  = 1'b0;
    assign bresp_o   = 2'b00;
    assign bid_o     = 4'b0000;
    assign arready_o = 1'b1;
    assign rvalid_o  = rdata_valid;
    assign rdata_o   = araddr_i[2] ? mtime[63:32] : mtime[31:0];
    assign rresp_o   = 2'b00;
    assign rlast_o   = 1'b1;
    assign rid_o     = 4'b0000;


endmodule