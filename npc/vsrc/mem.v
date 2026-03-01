`ifdef __ICARUS__

module mem 
#(
    parameter MEM_DEPTH  = 4096                 //MEM深度
)(
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

    reg [31:0] mem_array [32'h8000_0000 : 32'h8000_0000 + (MEM_DEPTH-1)];

    reg                    arready;
    reg                    awready;
    reg                    wready;

    reg [31:0] rdata;
    reg rvalid;
    reg rlast;
    reg flag;
    reg [7:0] cnt;

    always @(posedge clk) begin
        if(rst) begin
            arready <= 1'b1;
            awready <= 1'b1;
            wready  <= 1'b1;
        end else begin
            if(arvalid_i && arready) begin
                arready <= 1'b0;
            end else if(rvalid_o && rready_i && rlast) begin
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
            rlast <= 1'b0;
            cnt <= 0;
            flag <= 1'b0;
        end else begin
            if(rvalid_o && rready_i) begin
                rvalid <= 1'b0;
                rlast <= 1'b0;
            end else if(arvalid_i && arready || flag) begin
                rdata <= mem_array[araddr_i[$clog2(MEM_DEPTH)-1:2] + cnt];
                rvalid <= 1'b1;
                if(cnt == arlen_i) begin
                    rlast <= 1'b1;
                    cnt <= 0;
                    flag <= 1'b0;
                end else begin
                    rlast <= 1'b0;
                    cnt <= cnt + 1;
                    flag <= 1'b1;
                end
            end
        end
    end

    wire [31:0] wdata_mask = 
    {
        (wstrb_i[3] ? wdata_i[31:24] : mem_array[awaddr_i[$clog2(MEM_DEPTH)-1:2]][31:24]),
        (wstrb_i[2] ? wdata_i[23:16] : mem_array[awaddr_i[$clog2(MEM_DEPTH)-1:2]][23:16]),
        (wstrb_i[1] ? wdata_i[15:8 ] : mem_array[awaddr_i[$clog2(MEM_DEPTH)-1:2]][15:8 ]),
        (wstrb_i[0] ? wdata_i[7 :0 ] : mem_array[awaddr_i[$clog2(MEM_DEPTH)-1:2]][7 :0 ])
    };

    reg bvalid;
    always @(posedge clk) begin
        if(rst) begin
            bvalid <= 1'b0;
        end else begin
            if(bvalid_o && bready_i) begin
                bvalid <= 1'b0;
            end else if(wvalid_i && wready) begin
                mem_array[awaddr_i[$clog2(MEM_DEPTH)-1:2]] <= wdata_mask;
                bvalid <= 1'b1;
            end
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

    initial begin
        $readmemh("/home/hhh/Public/ysyx/ysyx-workbench/npc/build/test.data", mem_array);
    end

endmodule

`endif