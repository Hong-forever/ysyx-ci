`include "defines.v"

//------------------------------------------------------------------------
// UART模块
//------------------------------------------------------------------------

module uart
#(
    parameter ADDR_WIDTH = 32,                  //地址总线宽度
    parameter DATA_WIDTH = 8,                   //数据总线宽度
    parameter BAUD_RATE  = 115200,              //波特率
    parameter CLOCK_FREQ = 50_000_000           //时钟频率
)(
    input   wire                        clk,        //时钟输入
    input   wire                        rst_n,      //复位输入

    // AXI接口
    input   wire                        awvalid_i,
    output  wire                        awready_o,
    input   wire    [ADDR_WIDTH-1:0 ]   awaddr_i,
    input   wire                        wvalid_i,
    output  wire                        wready_o,
    input   wire    [DATA_WIDTH-1:0 ]   wdata_i,
    input   wire    [DATA_WIDTH/8-1:0]  wstrb_i,
    output  wire                        bvalid_o,
    input   wire                        bready_i,
    output  wire    [1:0 ]              bresp_o,
    input   wire                        arvalid_i,
    output  wire                        arready_o,
    input   wire    [ADDR_WIDTH-1:0 ]   araddr_i,
    output  wire                        rvalid_o,
    input   wire                        rready_i,
    output  wire    [DATA_WIDTH-1:0 ]   rdata_o,
    output  wire    [1:0 ]              rresp_o

);

    reg                    arready;
    reg                    awready;
    reg                    wready;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            arready <= 1'b1;
            awready <= 1'b1;
            wready  <= 1'b1;
        end else begin
            if(arvalid_i && arready) begin
                arready <= 1'b0;
            end else if(rvalid_o && rready_i) begin
                arready <= 1'b1;
            end
            if(awvalid_i && awready) begin
                awready <= 1'b0;
            end else if(bvalid_o && bready_i) begin
                awready <= 1'b1;
            end
            if(wvalid_i && wready) begin
                wready <= 1'b0;
            end else if(bvalid_o && bready_i) begin
                wready <= 1'b1;
            end
        end
    end


    reg [`MemDataBus] rdata;
    reg               rdata_valid;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rdata <= `Zero;
            rdata_valid <= 1'b0;
        end else begin
            if(rvalid_o && rready_i) begin
                rdata <= `Zero;
                rdata_valid <= 1'b0;
            end else if(arvalid_i && arready_o) begin
                rdata <= `Zero;
                rdata_valid <= 1'b1;
            end
        end
    end

    reg wdata_valid;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            wdata_valid <= 1'b0;
        end else begin
            if(bvalid_o && bready_i) begin
                wdata_valid <= 1'b0;
            end else if(wvalid_i && wready_o) begin
                wdata_valid <= 1'b1;
            end
        end
    end

    always @(*) begin
        if(arvalid_i) begin
            $error("UART read is not supported!");
        end
        if(wvalid_i && wready_o) begin
            $write("%c", wdata_i[7:0]);
            $fflush();
        end
    end

    assign awready_o = awready;
    assign wready_o  = wready;
    assign bvalid_o  = wdata_valid;
    assign bresp_o   = 2'b00;
    assign arready_o = arready;
    assign rvalid_o  = rdata_valid;
    assign rdata_o   = rdata;
    assign rresp_o   = 2'b00;


endmodule