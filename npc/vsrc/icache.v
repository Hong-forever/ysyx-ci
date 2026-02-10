
//------------------------------------------------------------------------
// icache
//------------------------------------------------------------------------

module ysyx_25110270_icache
#(
    parameter DATA_WIDTH  = 32,
    parameter ADDR_WIDTH  = 32,
    parameter SET_NUM     = 16,     // direct mapped cache sets
    parameter N_WAYS      = 1,      // number of ways, 1, 2, 4, 8
    parameter BLOCK_SIZE  = 8       // in bytes
)
(
    input                           clk,
    input                           rst_n,
    input       [ADDR_WIDTH-1:0]    I_addr,
    input                           I_wr,
    input       [DATA_WIDTH-1:0]    I_wdata,
    input                           I_wlast,
    input                           I_valid,
    output      [DATA_WIDTH-1:0]    O_data,
    output                          O_valid,
    output                          O_miss
);

    parameter WORD_BYTES        = DATA_WIDTH/8;                 // 每个字的字节数
    parameter WORDS_PER_BLOCK   = BLOCK_SIZE / WORD_BYTES;     // 每个block包含的字数
    parameter BLOCK_WIDTH       = $clog2(WORDS_PER_BLOCK);      // 块内字偏移宽度
    parameter SET_WIDTH         = $clog2(SET_NUM);              // 组索引宽度
    parameter TAG_WIDTH         = ADDR_WIDTH - SET_WIDTH - BLOCK_WIDTH - 2; // 标签宽度

    parameter IDLE = 2'b00;
    parameter READ = 2'b01;
    parameter MISS = 2'b10;

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


    reg [1:0] state, nstate;
    reg [BLOCK_WIDTH-1:0] cnt;

    reg hit;
    reg miss;

    always @(posedge clk) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= nstate;
        end
    end

    always @(*) begin
        if(!rst_n) begin
            nstate = IDLE;
            hit = 1'b0;
            miss = 1'b0;
        end else begin
            case(state)
                IDLE: begin
                    hit = 1'b0;
                    miss = 1'b0;
                    nstate = I_valid ? READ : IDLE;
                end
                READ: begin
                    if((tag_mem[index] == tag) & valid_mem[index]) begin
                        hit = 1'b1;
                        miss = 1'b0;
                        nstate = IDLE;
                    end else begin
                        hit = 1'b0;
                        miss = 1'b1;
                        nstate = MISS;
                    end
                end
                MISS: begin
                    hit = 1'b0;
                    miss = 1'b1;
                    nstate = I_valid & I_wr & I_wlast ? IDLE : MISS;
                end
                default: begin
                    hit = 1'b0;
                    miss = 1'b0;
                    nstate = IDLE;
                end
            endcase
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
            cnt <= 0;
        end else if(I_valid && I_wr) begin
            data_mem[index][cnt] <= I_wdata;
            tag_mem[index] <= tag;
            valid_mem[index] <= 1'b1;
            cnt <= I_wlast ? 0 : cnt + 1;
        end
    end

    generate
        if(BLOCK_WIDTH > 0) begin
            assign O_data = data_mem[index][offset];
        end else begin
            assign O_data = data_mem[index][0];
        end
    endgenerate
    assign O_valid = hit;
    assign O_miss = miss;

endmodule