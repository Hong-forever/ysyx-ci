module ysyx_25110270_uart
(
    input   wire                        clk,        //时钟输入
    input   wire                        rst,      //复位输入

    input   wire                        awvalid_i,
    output  wire                        awready_o,
    input   wire    [31:0]              awaddr_i,
    input   wire    [3:0 ]              awid_i,
    input   wire    [7:0 ]              awlen_i,
    input   wire    [2:0 ]              awsize_i,
    input   wire    [1:0 ]              awburst_i,
    input   wire                        wvalid_i,
    output  wire                        wready_o,
    input   wire    [31:0]              wdata_i,
    input   wire    [3:0]               wstrb_i,
    input   wire                        wlast_i,
    output  wire                        bvalid_o,
    input   wire                        bready_i,
    output  wire    [1:0 ]              bresp_o,
    output  wire    [3:0 ]              bid_o,
    input   wire                        arvalid_i,
    output  wire                        arready_o,
    input   wire    [31:0]              araddr_i,
    input   wire    [3:0 ]              arid_i,
    input   wire    [7:0 ]              arlen_i,
    input   wire    [2:0 ]              arsize_i,
    input   wire    [1:0 ]              arburst_i,
    output  wire                        rvalid_o,
    input   wire                        rready_i,
    output  wire    [31:0]              rdata_o,
    output  wire    [1:0 ]              rresp_o,
    output  wire                        rlast_o,
    output  wire    [3:0 ]              rid_o
);


    reg bvalid;
    always @(posedge clk) begin
        if(rst) begin
            bvalid <= 1'b0;
        end else begin
            if(bvalid_o && bready_i) begin
                bvalid <= 1'b0;
            end else if(wvalid_i && wready_o) begin
                bvalid <= 1'b1;
            end
        end
    end

`ifdef __ICARUS__
    reg last_write;

    always @(posedge clk) begin
        if(rst) begin
            last_write <= 1'b0;
        end else begin
            last_write <= wvalid_i;

            if((wvalid_i) & !last_write) begin
                $write("%c", wdata_i[7:0]);
                $fflush();
            end
        end
    end

`endif
`ifdef ysyx_25110270_DPIC
    always @(*) begin
        if(wvalid_i && wready_o) begin
            $write("%c", wdata_i[7:0]);
            $fflush();
        end
    end
`endif
    assign awready_o = 1'b1;
    assign wready_o  = 1'b1;
    assign bvalid_o  = bvalid;
    assign bresp_o   = 2'b00;
    assign arready_o = 1'b1;
    assign rvalid_o  = 1'b0;
    assign rdata_o   = 0;
    assign rresp_o   = 2'b00;
    assign rlast_o   = 1'b1;

endmodule