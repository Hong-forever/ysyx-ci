`include "defines.v"
//------------------------------------------------------------------------
// icache
//------------------------------------------------------------------------

module ysyx_25110270_icache
#(
    parameter DATA_WIDTH  = 32,
    parameter ADDR_WIDTH  = 32,
    parameter SET_NUM     = 8,     // direct mapped cache sets
    parameter N_WAYS      = 1,      // number of ways, 1, 2, 4, 8
    parameter BLOCK_SIZE  = 8       // in bytes
)
(
    input                           clk,
    input                           rst,
    input                           I_valid,
    output                          O_valid,
    input       [ADDR_WIDTH-1:0]    I_addr,
    output      [DATA_WIDTH-1:0]    O_data,
    input                           I_clear,

    output                          O_arvalid,
    input                           I_arready,
    output      [ADDR_WIDTH-1:0]    O_araddr,
    output      [7:0]               O_arlen,
    output      [2:0]               O_arsize,
    output      [1:0]               O_arburst,
    input                           I_rvalid,
    output                          O_rready,
    input       [DATA_WIDTH-1:0]    I_rdata,
    input                           I_rlast,
    input       [1:0]               I_rresp

);

    parameter WORD_BYTES        = DATA_WIDTH/8;             
    parameter WORDS_PER_BLOCK   = BLOCK_SIZE / WORD_BYTES;      // 每个block包含的字数
    parameter BLOCK_WIDTH       = $clog2(WORDS_PER_BLOCK);      // 块内字偏移宽度
    parameter SET_WIDTH         = $clog2(SET_NUM);              // 组索引宽度
    parameter TAG_WIDTH         = ADDR_WIDTH - SET_WIDTH - BLOCK_WIDTH - 2; // 标签宽度

    parameter IDLE   = 3'b00;
    parameter REQ    = 3'b01;
    parameter REFILL = 3'b10;

    // 存储器定义
    reg [TAG_WIDTH-1:0] tag_mem [0:SET_NUM*N_WAYS-1];
    reg [DATA_WIDTH-1:0] data_mem [0:SET_NUM*N_WAYS-1][0:WORDS_PER_BLOCK-1];
    reg valid_mem [0:SET_NUM*N_WAYS-1];

    wire [TAG_WIDTH-1:0]               tag;      // 标签位
    wire [SET_WIDTH-1:0]               index;    // 组索引
    wire [BLOCK_WIDTH-1:0]             offset;   // 块内字偏移

    assign tag     = I_addr[ADDR_WIDTH-1 : SET_WIDTH + BLOCK_WIDTH + 2];
    assign index   = I_addr[SET_WIDTH + BLOCK_WIDTH + 1 : BLOCK_WIDTH + 2];
    assign offset  = I_addr[BLOCK_WIDTH + 1 : 2];


    reg [2:0] state;

    wire hit;
    generate
        if(N_WAYS == 1) begin
            assign hit = (tag_mem[index] == tag) & valid_mem[index];
        end else begin
            // 多路情况，暂不实现
        end
    endgenerate


    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
        end else begin
            case(state)
                IDLE:    state <= I_valid ? (hit ? IDLE : REQ) : IDLE;
                REQ:     state <= I_arready ? REFILL : REQ;
                REFILL:  state <= (I_rvalid && I_rlast) ? IDLE : REFILL;
                default: state <= IDLE;
            endcase
        end
    end

    reg clear_r;
    always @(posedge clk) begin
        if(rst) begin
            clear_r <= 1'b0;
        end else begin
            clear_r <= I_clear;
        end
    end

    integer i, j;
    always @(posedge clk) begin
        if(rst) begin
            for(i = 0; i < SET_NUM*N_WAYS; i = i + 1) begin
                valid_mem[i] <= 0;
            end
        end else if(I_clear && !clear_r) begin
            for(i = 0; i < SET_NUM*N_WAYS; i = i + 1) begin
                valid_mem[i] <= 0;
            end
        end else begin
            if(state[1] && I_rvalid) begin
                data_mem[index][I_rlast] <= I_rdata;
                tag_mem[index] <= tag;
                valid_mem[index] <= I_rlast;
            end
        end
    end

    reg [DATA_WIDTH-1:0] odata_r;
    reg ovalid_r;

    // always @(*) begin
    //     if(rst) begin
    //         ovalid_r = 1'b0;
    //         odata_r = 0;
    //     end else if(I_valid && hit) begin
    //         ovalid_r = 1'b1;
    //         odata_r = data_mem[index][offset];
    //     end else begin
    //         ovalid_r = 1'b0;
    //         odata_r = 0;
    //     end
    // end

    always @(posedge clk) begin
        if(rst) begin
            ovalid_r <= 1'b0;
        end else if(I_valid & hit & !ovalid_r) begin
            odata_r <= data_mem[index][offset];
            ovalid_r <= 1'b1;
        end else begin
            ovalid_r <= 1'b0;
        end
    end

    assign O_data  = odata_r;
    assign O_valid = ovalid_r;

    assign O_arvalid = state[0]; // REQ state
    assign O_araddr  = {I_addr[ADDR_WIDTH-1:3], 3'b000};
    assign O_arlen   = WORDS_PER_BLOCK[7:0] - 8'b1;
    assign O_arsize  = 3'b010; // 4 bytes
    assign O_arburst = 2'b01; // INCR
    // assign O_arburst = 2'b10; // WRAP
    assign O_rready  = 1'b1;

endmodule