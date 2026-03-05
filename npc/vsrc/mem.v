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

    reg [31:0] rdata;
    reg rvalid;
    reg rlast;
    reg flag;
    reg [7:0] cnt;

    reg bvalid;

`ifdef __ICARUS__

    reg [7:0] mem_array0 [0 : 32'h0200_0000-1];
    reg [7:0] mem_array1 [0 : 32'h0200_0000-1];
    reg [7:0] mem_array2 [0 : 32'h0200_0000-1];
    reg [7:0] mem_array3 [0 : 32'h0200_0000-1];

    initial begin
        $readmemh("/home/hhh/Public/ysyx/ysyx-workbench/npc/build/test.data", mem_array0);
    end
    wire [31:0] araddr_align = {araddr_i[31:2], 2'b00};

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
            end else if(arvalid_i || flag) begin
                case(araddr_align[26:25])
                    2'b00: rdata <= {mem_array0[araddr_align[24:0]+3+4*cnt], mem_array0[araddr_align[24:0]+2+4*cnt], mem_array0[araddr_align[24:0]+1+4*cnt], mem_array0[araddr_align[24:0]+0+4*cnt]};
                    2'b01: rdata <= {mem_array1[araddr_align[24:0]+3+4*cnt], mem_array1[araddr_align[24:0]+2+4*cnt], mem_array1[araddr_align[24:0]+1+4*cnt], mem_array1[araddr_align[24:0]+0+4*cnt]};
                    2'b10: rdata <= {mem_array2[araddr_align[24:0]+3+4*cnt], mem_array2[araddr_align[24:0]+2+4*cnt], mem_array2[araddr_align[24:0]+1+4*cnt], mem_array2[araddr_align[24:0]+0+4*cnt]};
                    2'b11: rdata <= {mem_array3[araddr_align[24:0]+3+4*cnt], mem_array3[araddr_align[24:0]+2+4*cnt], mem_array3[araddr_align[24:0]+1+4*cnt], mem_array3[araddr_align[24:0]+0+4*cnt]};
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

    wire [31:0] awaddr_align = {awaddr_i[31:2], 2'b00};

    always @(posedge clk) begin
        if(rst) begin
            bvalid <= 1'b0;
        end else begin
            if(bvalid_o && bready_i) begin
                bvalid <= 1'b0;
            end else if(wvalid_i) begin
                case(awaddr_align[26:25])
                    2'b00: begin
                        if(wstrb_i[3]) mem_array0[awaddr_align[24:0]+3] <= wdata_i[31:24];
                        if(wstrb_i[2]) mem_array0[awaddr_align[24:0]+2] <= wdata_i[24:16];
                        if(wstrb_i[1]) mem_array0[awaddr_align[24:0]+1] <= wdata_i[15:8];
                        if(wstrb_i[0]) mem_array0[awaddr_align[24:0]+0] <= wdata_i[7:0];
                    end
                    2'b01: begin
                        if(wstrb_i[3]) mem_array1[awaddr_align[24:0]+3] <= wdata_i[31:24];
                        if(wstrb_i[2]) mem_array1[awaddr_align[24:0]+2] <= wdata_i[24:16];
                        if(wstrb_i[1]) mem_array1[awaddr_align[24:0]+1] <= wdata_i[15:8];
                        if(wstrb_i[0]) mem_array1[awaddr_align[24:0]+0] <= wdata_i[7:0];
                    end
                    2'b10: begin
                        if(wstrb_i[3]) mem_array2[awaddr_align[24:0]+3] <= wdata_i[31:24];
                        if(wstrb_i[2]) mem_array2[awaddr_align[24:0]+2] <= wdata_i[24:16];
                        if(wstrb_i[1]) mem_array2[awaddr_align[24:0]+1] <= wdata_i[15:8];
                        if(wstrb_i[0]) mem_array2[awaddr_align[24:0]+0] <= wdata_i[7:0];
                    end
                    2'b11: begin
                        if(wstrb_i[3]) mem_array3[awaddr_align[24:0]+3] <= wdata_i[31:24];
                        if(wstrb_i[2]) mem_array3[awaddr_align[24:0]+2] <= wdata_i[24:16];
                        if(wstrb_i[1]) mem_array3[awaddr_align[24:0]+1] <= wdata_i[15:8];
                        if(wstrb_i[0]) mem_array3[awaddr_align[24:0]+0] <= wdata_i[7:0];
                    end
                endcase
                bvalid <= 1'b1;
            end
        end
    end

`else
    
    import "DPI-C" function int paddr_read(input int raddr);
    import "DPI-C" function void paddr_write(input int waddr, input int wdata, input int wmask);

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
            end else if(arvalid_i || flag) begin
                rdata <= paddr_read(araddr_i + 4*cnt);
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

    always @(posedge clk) begin
        if(rst) begin
            bvalid <= 1'b0;
        end else begin
            if(bvalid_o && bready_i) begin
                bvalid <= 1'b0;
            end else if(wvalid_i) begin
                paddr_write(awaddr_i, wdata_i, wstrb_i);
                bvalid <= 1'b1;
            end
        end
    end

`endif

    assign awready_o = 1'b1;
    assign wready_o  = 1'b1;
    assign bvalid_o  = bvalid;
    assign bresp_o   = 2'b00;
    assign arready_o = 1'b1;
    assign rvalid_o  = rvalid;
    assign rdata_o   = rdata;
    assign rresp_o   = 2'b00;
    assign rlast_o   = rlast;


endmodule
