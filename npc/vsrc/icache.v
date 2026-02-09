
//------------------------------------------------------------------------
// icache
//------------------------------------------------------------------------

module ysyx_25110270_icache
#(
    parameter DATA_WIDTH  = 32,
    parameter ADDR_WIDTH  = 32,
    parameter SET_NUM     = 16,     // direct mapped cache sets
    parameter N_WAYS      = 1,      // number of ways, 1, 2, 4, 8
    parameter BLOCK_SIZE  = 4       // in bytes
)
(
    input                           clk,
    input                           rst_n,
    input       [ADDR_WIDTH-1:0]    I_addr,
    input                           I_wr,
    input       [DATA_WIDTH-1:0]    I_wdata,
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
    reg [DATA_WIDTH-1:0] data_mem [0:SET_NUM*N_WAYS*WORDS_PER_BLOCK-1];
    reg valid_mem [0:SET_NUM*N_WAYS-1];

    wire [TAG_WIDTH-1:0]               tag;      // 标签位
    wire [SET_WIDTH-1:0]               index;    // 组索引
    // wire [BLOCK_WIDTH-1:0]             offset;   // 组内偏移（字）
    
    assign tag     = I_addr[ADDR_WIDTH-1 : SET_WIDTH + BLOCK_WIDTH + 2];
    assign index   = I_addr[SET_WIDTH + BLOCK_WIDTH + 1 : BLOCK_WIDTH + 2];
    // assign offset  = I_addr[BLOCK_WIDTH+1 : 2];

    reg [1:0] state, nstate;

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
                    if(I_valid) begin
                        nstate = READ;
                    end else begin
                        nstate = IDLE;
                    end
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
                    if(I_valid & I_wr) begin
                        nstate = IDLE;
                    end else begin
                        nstate = MISS;
                    end
                end
                default: begin
                    hit = 1'b0;
                    miss = 1'b0;
                    nstate = IDLE;
                end
            endcase
        end
    end

    integer i;
    always @(posedge clk) begin
        if(!rst_n) begin
            for(i = 0; i < SET_NUM*N_WAYS; i = i + 1) begin
                data_mem[i] <= 0;
                valid_mem[i] <= 0;
                tag_mem[i] <= 0;
            end
        end else if(I_valid && I_wr) begin
            data_mem[index] <= I_wdata; // 简化为写入同一数据
            tag_mem[index] <= tag;
            valid_mem[index] <= 1'b1;
        end
    end

    assign O_data = data_mem[index];
    assign O_valid = hit;
    assign O_miss = miss;

endmodule