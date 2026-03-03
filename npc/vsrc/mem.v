
`ifdef __ICARUS__
module mem 
#(
    parameter MEM_DEPTH  = 32'h01000000                //MEM深度
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

    reg [7:0] mem_array0 [0 : 32'h0200_0000-1];
    reg [7:0] mem_array1 [0 : 32'h0200_0000-1];
    reg [7:0] mem_array2 [0 : 32'h0200_0000-1];
    reg [7:0] mem_array3 [0 : 32'h0200_0000-1];

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
                case(araddr_i[26:25])
                    2'b00: rdata <= {mem_array0[araddr_i[24:0]+3+4*cnt], mem_array0[araddr_i[24:0]+2+4*cnt], mem_array0[araddr_i[24:0]+1+4*cnt], mem_array0[araddr_i[24:0]+0+4*cnt]};
                    2'b01: rdata <= {mem_array1[araddr_i[24:0]+3+4*cnt], mem_array1[araddr_i[24:0]+2+4*cnt], mem_array1[araddr_i[24:0]+1+4*cnt], mem_array1[araddr_i[24:0]+0+4*cnt]};
                    2'b10: rdata <= {mem_array2[araddr_i[24:0]+3+4*cnt], mem_array2[araddr_i[24:0]+2+4*cnt], mem_array2[araddr_i[24:0]+1+4*cnt], mem_array2[araddr_i[24:0]+0+4*cnt]};
                    2'b11: rdata <= {mem_array3[araddr_i[24:0]+3+4*cnt], mem_array3[araddr_i[24:0]+2+4*cnt], mem_array3[araddr_i[24:0]+1+4*cnt], mem_array3[araddr_i[24:0]+0+4*cnt]};
                endcase
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


    reg bvalid;
    always @(posedge clk) begin
        if(rst) begin
            bvalid <= 1'b0;
        end else begin
            if(bvalid_o && bready_i) begin
                bvalid <= 1'b0;
            end else if(wvalid_i && wready) begin
                case(awaddr_i[26:25])
                    2'b00: begin
                        if(wstrb_i[3]) mem_array0[awaddr_i[24:0]+3] <= wdata_i[31:24];
                        if(wstrb_i[2]) mem_array0[awaddr_i[24:0]+2] <= wdata_i[24:16];
                        if(wstrb_i[1]) mem_array0[awaddr_i[24:0]+1] <= wdata_i[15:8];
                        if(wstrb_i[0]) mem_array0[awaddr_i[24:0]+0] <= wdata_i[7:0];
                    end
                    2'b01: begin
                        if(wstrb_i[3]) mem_array1[awaddr_i[24:0]+3] <= wdata_i[31:24];
                        if(wstrb_i[2]) mem_array1[awaddr_i[24:0]+2] <= wdata_i[24:16];
                        if(wstrb_i[1]) mem_array1[awaddr_i[24:0]+1] <= wdata_i[15:8];
                        if(wstrb_i[0]) mem_array1[awaddr_i[24:0]+0] <= wdata_i[7:0];
                    end
                    2'b10: begin
                        if(wstrb_i[3]) mem_array2[awaddr_i[24:0]+3] <= wdata_i[31:24];
                        if(wstrb_i[2]) mem_array2[awaddr_i[24:0]+2] <= wdata_i[24:16];
                        if(wstrb_i[1]) mem_array2[awaddr_i[24:0]+1] <= wdata_i[15:8];
                        if(wstrb_i[0]) mem_array2[awaddr_i[24:0]+0] <= wdata_i[7:0];
                    end
                    2'b11: begin
                        if(wstrb_i[3]) mem_array3[awaddr_i[24:0]+3] <= wdata_i[31:24];
                        if(wstrb_i[2]) mem_array3[awaddr_i[24:0]+2] <= wdata_i[24:16];
                        if(wstrb_i[1]) mem_array3[awaddr_i[24:0]+1] <= wdata_i[15:8];
                        if(wstrb_i[0]) mem_array3[awaddr_i[24:0]+0] <= wdata_i[7:0];
                    end
                endcase
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
    assign rlast_o   = rlast;

    wire [31:0] mem0 = {mem_array0[0+3], mem_array0[0+2], mem_array0[0+1], mem_array0[0+0]};
    wire [31:0] mem_test = {mem_array0[32'h0000_016c+3], mem_array0[32'h0000_016c+2], mem_array0[32'h0000_016c+1], mem_array0[32'h0000_016c+0]};
    wire [31:0] mem_test2 = {mem_array0[32'h0000_0170+3], mem_array0[32'h0000_0170+2], mem_array0[32'h0000_0170+1], mem_array0[32'h0000_0170+0]};
    wire [31:0] mem_test3 = {mem_array0[32'h0000_0174+3], mem_array0[32'h0000_0174+2], mem_array0[32'h0000_0174+1], mem_array0[32'h0000_0174+0]};
    wire [31:0] mem_test4 = {mem_array0[32'h0000_0178+3], mem_array0[32'h0000_0178+2], mem_array0[32'h0000_0178+1], mem_array0[32'h0000_0178+0]};
    wire [31:0] mem_test5 = {mem_array0[32'h0000_017c+3], mem_array0[32'h0000_017c+2], mem_array0[32'h0000_017c+1], mem_array0[32'h0000_017c+0]};
    wire [31:0] mem_test6 = {mem_array0[32'h0000_0180+3], mem_array0[32'h0000_0180+2], mem_array0[32'h0000_0180+1], mem_array0[32'h0000_0180+0]};
    wire [31:0] mem_test7 = {mem_array0[32'h0000_0184+3], mem_array0[32'h0000_0184+2], mem_array0[32'h0000_0184+1], mem_array0[32'h0000_0184+0]};
    wire [31:0] mem_test8 = {mem_array0[32'h0000_0188+3], mem_array0[32'h0000_0188+2], mem_array0[32'h0000_0188+1], mem_array0[32'h0000_0188+0]};
    wire [31:0] mem_test9 = {mem_array0[32'h0000_018c+3], mem_array0[32'h0000_018c+2], mem_array0[32'h0000_018c+1], mem_array0[32'h0000_018c+0]};
    wire [31:0] mem_test10 = {mem_array0[32'h0000_0190+3], mem_array0[32'h0000_0190+2], mem_array0[32'h0000_0190+1], mem_array0[32'h0000_0190+0]};
    wire [31:0] mem_test11 = {mem_array0[32'h0000_0194+3], mem_array0[32'h0000_0194+2], mem_array0[32'h0000_0194+1], mem_array0[32'h0000_0194+0]};
    wire [31:0] mem_test12 = {mem_array0[32'h0000_0198+3], mem_array0[32'h0000_0198+2], mem_array0[32'h0000_0198+1], mem_array0[32'h0000_0198+0]};
    wire [31:0] mem_test13 = {mem_array0[32'h0000_019c+3], mem_array0[32'h0000_019c+2], mem_array0[32'h0000_019c+1], mem_array0[32'h0000_019c+0]};
    wire [31:0] mem_test14 = {mem_array0[32'h0000_01a0+3], mem_array0[32'h0000_01a0+2], mem_array0[32'h0000_01a0+1], mem_array0[32'h0000_01a0+0]};
    wire [31:0] mem_test15 = {mem_array0[32'h0000_01a4+3], mem_array0[32'h0000_01a4+2], mem_array0[32'h0000_01a4+1], mem_array0[32'h0000_01a4+0]};

    initial begin
        $readmemh("/home/hhh/Public/ysyx/ysyx-workbench/npc/build/test.data", mem_array0);
    end

endmodule

`endif