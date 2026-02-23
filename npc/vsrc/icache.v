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
    input                           rst_n,
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
    parameter WORDS_PER_BLOCK   = BLOCK_SIZE / WORD_BYTES;     // 每个block包含的字数
    parameter BLOCK_WIDTH       = $clog2(WORDS_PER_BLOCK);      // 块内字偏移宽度
    parameter SET_WIDTH         = $clog2(SET_NUM);              // 组索引宽度
    parameter TAG_WIDTH         = ADDR_WIDTH - SET_WIDTH - BLOCK_WIDTH - 2; // 标签宽度

    parameter IDLE   = 3'b000;
    parameter LOOKUP = 3'b001;
    parameter REQ    = 3'b010;
    parameter REFILL = 3'b100;

    // 存储器定义
    reg [TAG_WIDTH-1:0] tag_mem [0:SET_NUM*N_WAYS-1];
    reg [DATA_WIDTH-1:0] data_mem [0:SET_NUM*N_WAYS-1][0:WORDS_PER_BLOCK-1];
    reg valid_mem [0:SET_NUM*N_WAYS-1];

    wire [TAG_WIDTH-1:0]               tag, miss_tag;      // 标签位
    wire [SET_WIDTH-1:0]               index, miss_index;    // 组索引
    wire [BLOCK_WIDTH-1:0]             offset, miss_offset;   // 块内字偏移

    assign tag     = I_addr[ADDR_WIDTH-1 : SET_WIDTH + BLOCK_WIDTH + 2];
    assign index   = I_addr[SET_WIDTH + BLOCK_WIDTH + 1 : BLOCK_WIDTH + 2];
    assign offset  = I_addr[BLOCK_WIDTH + 1 : 2];


    reg [2:0] state;
    reg [BLOCK_WIDTH-1:0] cnt;

    reg [ADDR_WIDTH-1:0]  miss_addr;
    assign miss_tag  = miss_addr[ADDR_WIDTH-1 : SET_WIDTH + BLOCK_WIDTH + 2];
    assign miss_index = miss_addr[SET_WIDTH + BLOCK_WIDTH + 1 : BLOCK_WIDTH + 2];
    assign miss_offset = miss_addr[BLOCK_WIDTH + 1 : 2];

    wire [BLOCK_WIDTH-1:0] refill_offset = miss_offset + cnt;

    reg way_hit;
    generate
        if (N_WAYS == 1) begin
            always @(posedge clk) begin
                way_hit <= (tag_mem[index] == tag) & valid_mem[index];
            end
        end else begin
            // 多路情况，暂不实现
        end
    endgenerate

    wire hit = way_hit;

    always @(posedge clk) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            case(state)
                IDLE:    state <= I_valid ? LOOKUP : IDLE;
                LOOKUP:  state <= hit ? IDLE : REQ;
                REQ:     state <= (O_arvalid && I_arready) ? REFILL : REQ;
                REFILL:  state <= (I_rvalid && I_rlast) ? IDLE : REFILL;
                default: state <= IDLE;
            endcase
        end
    end

    reg clear_r;
    always @(posedge clk) begin
        if(!rst_n) begin
            clear_r <= 1'b0;
        end else begin
            clear_r <= I_clear;
        end
    end

    integer i, j;
    always @(posedge clk) begin
        if(!rst_n) begin
            for(i = 0; i < SET_NUM*N_WAYS; i = i + 1) begin
                valid_mem[i] <= 0;
                tag_mem[i] <= 0;
                for(j=0; j < WORDS_PER_BLOCK; j = j + 1) begin
                    data_mem[i][j] <= 0;
                end
            end
            miss_addr <= 0;
            cnt <= 0;
        end else if(I_clear && !clear_r) begin
            for(i = 0; i < SET_NUM*N_WAYS; i = i + 1) begin
                valid_mem[i] <= 0;
            end
        end else begin
            if(state[0] & ~hit) begin
                miss_addr <= I_addr;
                cnt <= 0;
            end else if(state[2] && I_rvalid) begin
                data_mem[miss_index][refill_offset] <= I_rdata; // WRAP offset
                cnt <= I_rlast ? 0 : cnt + 1;
                tag_mem[miss_index] <= miss_tag;
                valid_mem[miss_index] <= 1'b1;
            end
        end
    end

    wire refill_hit = state[2] && I_rvalid && I_addr[BLOCK_WIDTH+1:2] == refill_offset;
    wire [DATA_WIDTH-1:0] refill_data = I_rdata;

    reg [DATA_WIDTH-1:0] odata_r;
    reg ovalid_r;

    always @(*) begin
        if(!rst_n) begin
            odata_r  = 0;
            ovalid_r = 1'b0;
        end else if(refill_hit) begin
            odata_r  = refill_data;
            ovalid_r = 1'b1;
        end else if(state[0] & hit) begin
            odata_r = data_mem[index][offset];
            ovalid_r = 1'b1;
        end else begin
            odata_r  = 0;
            ovalid_r = 1'b0;
        end
    end

    assign O_data  = odata_r;
    assign O_valid = ovalid_r;

    assign O_arvalid = state[1]; // REQ state
    assign O_araddr  = miss_addr;
    assign O_arlen   = WORDS_PER_BLOCK[7:0] - 8'b1;
    assign O_arsize  = 3'b010; // 4 bytes
    assign O_arburst = 2'b10; // WRAP
    assign O_rready  = 1'b1;

endmodule