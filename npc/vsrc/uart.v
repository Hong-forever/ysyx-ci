// `include "defines.v"

// //------------------------------------------------------------------------
// // UART模块
// //------------------------------------------------------------------------

// module uart
// #(
//     parameter ADDR_WIDTH = 32,                  //地址总线宽度
//     parameter DATA_WIDTH = 8,                   //数据总线宽度
//     parameter BAUD_RATE  = 115200,              //波特率
//     parameter CLOCK_FREQ = 50_000_000           //时钟频率
// )(
//     input   wire                        clk,        //时钟输入
//     input   wire                        rst_n,      //复位输入

//     // AXI接口
//     input   wire                        awvalid_i,
//     output  wire                        awready_o,
//     input   wire    [ADDR_WIDTH-1:0 ]   awaddr_i,
//     input   wire                        wvalid_i,
//     output  wire                        wready_o,
//     input   wire    [DATA_WIDTH-1:0 ]   wdata_i,
//     input   wire    [DATA_WIDTH/8-1:0]  wstrb_i,
//     output  wire                        bvalid_o,
//     input   wire                        bready_i,
//     output  wire    [1:0 ]              bresp_o,
//     input   wire                        arvalid_i,
//     output  wire                        arready_o,
//     input   wire    [ADDR_WIDTH-1:0 ]   araddr_i,
//     output  wire                        rvalid_o,
//     input   wire                        rready_i,
//     output  wire    [DATA_WIDTH-1:0 ]   rdata_o,
//     output  wire    [1:0 ]              rresp_o

// );

//     reg                    arready;
//     reg                    awready;
//     reg                    wready;
//     always @(posedge clk or negedge rst_n) begin
//         if(!rst_n) begin
//             arready <= 1'b1;
//             awready <= 1'b1;
//             wready  <= 1'b1;
//         end else begin
//             if(arvalid_i && arready) begin
//                 arready <= 1'b0;
//             end else if(rvalid_o && rready_i) begin
//                 arready <= 1'b1;
//             end
//             if(awvalid_i && awready) begin
//                 awready <= 1'b0;
//             end else if(bvalid_o && bready_i) begin
//                 awready <= 1'b1;
//             end
//             if(wvalid_i && wready) begin
//                 wready <= 1'b0;
//             end else if(bvalid_o && bready_i) begin
//                 wready <= 1'b1;
//             end
//         end
//     end

//     wire [`RAMDOM_WIDTH-1:0] random;
//     reg [`RAMDOM_WIDTH-1:0] random_r;
//     reg [`RAMDOM_WIDTH-1:0] random_w;

//     reg [`MemDataBus] rdata;
//     reg               rdata_valid;
//     always @(posedge clk or negedge rst_n) begin
//         if(!rst_n) begin
//             rdata <= `Zero;
//             rdata_valid <= 1'b0;
//         end else begin
//             if(rvalid_o && rready_i) begin
//                 rdata <= `Zero;
//                 rdata_valid <= 1'b0;
//             end else if(rhandshake) begin
//                 rdata <= paddr_read(araddr_i);
//                 rdata_valid <= 1'b1;
//             end
//         end
//     end

//     reg wdata_valid;
//     always @(posedge clk or negedge rst_n) begin
//         if(!rst_n) begin
//             wdata_valid <= 1'b0;
//         end else begin
//             if(bvalid_o && bready_i) begin
//                 wdata_valid <= 1'b0;
//             end else if(whandshake) begin
//                 paddr_write(awaddr_i, wdata_i, {28'b0, wstrb_i});
//                 wdata_valid <= 1'b1;
//             end
//         end
//     end

// `else
//     reg [`MemDataBus] rdata;
//     reg               rdata_valid;
//     always @(posedge clk or negedge rst_n) begin
//         if(!rst_n) begin
//             rdata <= `Zero;
//             rdata_valid <= 1'b0;
//         end else begin
//             if(rvalid_o && rready_i) begin
//                 rdata <= `Zero;
//                 rdata_valid <= 1'b0;
//             end else if(rhandshake) begin
//                 rdata <= mem_array[araddr_i[$clog2(MEM_DEPTH)-1:2]];
//                 rdata_valid <= 1'b1;
//             end
//         end
//     end

//     wire [DATA_WIDTH-1:0] wdata_mask = 
//     {
//         (wstrb_i[3] ? wdata_i[31:24] : mem_array[awaddr_i[$clog2(MEM_DEPTH)-1:2]][31:24]),
//         (wstrb_i[2] ? wdata_i[23:16] : mem_array[awaddr_i[$clog2(MEM_DEPTH)-1:2]][23:16]),
//         (wstrb_i[1] ? wdata_i[15:8 ] : mem_array[awaddr_i[$clog2(MEM_DEPTH)-1:2]][15:8 ]),
//         (wstrb_i[0] ? wdata_i[7 :0 ] : mem_array[awaddr_i[$clog2(MEM_DEPTH)-1:2]][7 :0 ])
//     };

//     reg wdata_valid;
//     always @(posedge clk or negedge rst_n) begin
//         if(!rst_n) begin
//             wdata_valid <= 1'b0;
//             for(int i = 0; i < MEM_DEPTH; i = i + 1) begin
//                 mem_array[i] <= `Zero;
//             end
//         end else begin
//             if(bvalid_o && bready_i) begin
//                 wdata_valid <= 1'b0;
//             end else if(whandshake) begin
//                 mem_array[awaddr_i[$clog2(MEM_DEPTH)-1:2]] <= wdata_mask;
//                 wdata_valid <= 1'b1;
//             end
//         end
//     end

// `endif

//     assign awready_o = awready;
//     assign wready_o  = wready;
//     assign bvalid_o  = wdata_valid;
//     assign bresp_o   = 2'b00;
//     assign arready_o = arready;
//     assign rvalid_o  = rdata_valid;
//     assign rdata_o   = rdata;
//     assign rresp_o   = 2'b00;


// endmodule