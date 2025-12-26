`include "defines.v"

//------------------------------------------------------------------------
// 存储器模块
//------------------------------------------------------------------------

module mem 
#(
    parameter DATA_WIDTH = 32,                  //数据总线宽度
    parameter ADDR_WIDTH = 32,                  //地址总线宽度
    parameter ROM_DEPTH  = 4096,                //ROM深度
    parameter LFSR_SEED  = 0                    //LFSR初始值
)(
    input   wire                        clk,        //时钟输入
    input   wire                        rst_n,      //复位输入

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

    import "DPI-C" function int paddr_read(input int raddr);
    import "DPI-C" function void paddr_write(input int waddr, input int wdata, input int wmask);

    reg                    arready;
    reg                    awready;
    reg                    wready;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            arready <= 1'b1;
            awready <= 1'b1;
            wready  <= 1'b1;
        end else begin
            arready <= ~(arvalid_i & arready);
            awready <= ~(awvalid_i & awready);
            wready  <= ~(wvalid_i  & wready );
        end
    end


    reg [`MemDataBus] rdata;
    reg               rdata_valid;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rdata <= `ZeroWord;
            rdata_valid <= 1'b0;
        end else begin
            if(arvalid_i && arready) begin
                rdata <= paddr_read(araddr_i);
                rdata_valid <= 1'b1;
            end else if(rready_i && rdata_valid) begin
                rdata <= `ZeroWord;
                rdata_valid <= 1'b0;
            end
        end
    end

    reg wdata_valid;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            wdata_valid <= 1'b0;
        end else begin
            if(awvalid_i && awready && wvalid_i && wready) begin
                paddr_write(awaddr_i, wdata_i, {28'b0, wstrb_i});
                wdata_valid <= 1'b1;
            end else if(bvalid_o && bready_i) begin
                wdata_valid <= 1'b0;
            end
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