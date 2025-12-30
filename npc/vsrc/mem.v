`include "defines.v"

//------------------------------------------------------------------------
// 存储器模块
//------------------------------------------------------------------------

module mem 
#(
    parameter DATA_WIDTH = 32,                  //数据总线宽度
    parameter ADDR_WIDTH = 32,                  //地址总线宽度
    parameter MEM_DEPTH  = 4096,                //MEM深度
    parameter LFSR_SEED  = 8'd0                 //LFSR初始值
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

`ifdef DPIC
    import "DPI-C" function int paddr_read(input int raddr);
    import "DPI-C" function void paddr_write(input int waddr, input int wdata, input int wmask);
`else
    // 内存数组
    reg [DATA_WIDTH-1:0] mem_array [0:MEM_DEPTH-1];
`endif

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

    wire [`RAMDOM_WIDTH-1:0] random;
    reg [`RAMDOM_WIDTH-1:0] random_r;
    reg [`RAMDOM_WIDTH-1:0] random_w;

    reg rflag, wflag;
    reg rhandshake, whandshake;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rflag <= 1'b0;
            random_r <= 0;
            rhandshake <= 1'b0;
            wflag <= 1'b0;
            random_w <= 0;
            whandshake <= 1'b0;
        end else begin
            if(rflag) begin
                random_r <= random_r - 1;
                if(random_r == 0) begin
                    rhandshake <= 1'b1;
                    rflag <= 1'b0;
                end
            end else if(arvalid_i && arready) begin
                rflag <= 1'b1;
                random_r <= random;
                rhandshake <= 1'b0;
            end else if(rvalid_o && rready_i) begin
                rhandshake <= 1'b0;
            end

            if(wflag) begin
                random_w <= random_w - 1;
                if(random_w == 0) begin
                    whandshake <= 1'b1;
                    wflag <= 1'b0;
                end
            end else if(awvalid_i && awready && wvalid_i && wready) begin
                wflag <= 1'b1;
                random_w <= random;
                whandshake <= 1'b0;
            end else if(bvalid_o && bready_i) begin
                whandshake <= 1'b0;
            end
        end
    end

`ifdef DPIC
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
            end else if(rhandshake) begin
                rdata <= paddr_read(araddr_i);
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
            end else if(whandshake) begin
                paddr_write(awaddr_i, wdata_i, {28'b0, wstrb_i});
                wdata_valid <= 1'b1;
            end
        end
    end

`else
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
            end else if(rhandshake) begin
                rdata <= mem_array[araddr_i[$clog2(MEM_DEPTH)-1:2]];
                rdata_valid <= 1'b1;
            end
        end
    end

    wire [DATA_WIDTH-1:0] wdata_mask = 
    {
        (wstrb_i[3] ? wdata_i[31:24] : mem_array[awaddr_i[$clog2(MEM_DEPTH)-1:2]][31:24]),
        (wstrb_i[2] ? wdata_i[23:16] : mem_array[awaddr_i[$clog2(MEM_DEPTH)-1:2]][23:16]),
        (wstrb_i[1] ? wdata_i[15:8 ] : mem_array[awaddr_i[$clog2(MEM_DEPTH)-1:2]][15:8 ]),
        (wstrb_i[0] ? wdata_i[7 :0 ] : mem_array[awaddr_i[$clog2(MEM_DEPTH)-1:2]][7 :0 ])
    };

    reg wdata_valid;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            wdata_valid <= 1'b0;
            for(int i = 0; i < MEM_DEPTH; i = i + 1) begin
                mem_array[i] <= `Zero;
            end
        end else begin
            if(bvalid_o && bready_i) begin
                wdata_valid <= 1'b0;
            end else if(whandshake) begin
                mem_array[awaddr_i[$clog2(MEM_DEPTH)-1:2]] <= wdata_mask;
                wdata_valid <= 1'b1;
            end
        end
    end

`endif

    assign awready_o = awready;
    assign wready_o  = wready;
    assign bvalid_o  = wdata_valid;
    assign bresp_o   = 2'b00;
    assign arready_o = arready;
    assign rvalid_o  = rdata_valid;
    assign rdata_o   = rdata;
    assign rresp_o   = 2'b00;


    lfsr #(
        .WIDTH                  (`RAMDOM_WIDTH              )      
    ) ilfsr_inst
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .I_seed                 (LFSR_SEED                  ),
        .O_random               (random                     )
    );

endmodule