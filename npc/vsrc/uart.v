`ifdef __ICARUS__
module uart
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

    reg                    arready;
    reg                    awready;
    reg                    wready;

    reg rvalid;
    reg [31:0] rdata;

    always @(posedge clk) begin
        if(rst) begin
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

    always @(posedge clk) begin
        if(rst) begin
            rvalid <= 1'b0;
        end else begin
            if(arvalid_i && arready_o) begin
                rvalid <= 1'b1;
                rdata <= 32'h0;
            end else if(rvalid_o && rready_i && rlast_o) begin
                rvalid <= 1'b0;
            end
        end
    end

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

    always @(*) begin
        if(wvalid_i && wready_o) begin
            $write("%c", wdata_i[7:0]);
            $fflush();
        end
    end

    assign awready_o = awready;
    assign wready_o  = wready;
    assign bvalid_o  = bvalid;
    assign bresp_o   = 2'b00;
    assign arready_o = arready;
    assign rvalid_o  = rvalid;
    assign rdata_o   = rdata;
    assign rresp_o   = 2'b00;
    assign rlast_o   = 1'b1;

endmodule
`endif
