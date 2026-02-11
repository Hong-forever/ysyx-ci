
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
    input                           I_valid,
    output      [DATA_WIDTH-1:0]    O_data,
    output                          O_valid,
    output                          O_miss,

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
    input       [1:0]               I_rresp,

    input                           I_clear
);

    parameter WORD_BYTES        = DATA_WIDTH/8;                 // 每个字的字节数
    parameter WORDS_PER_BLOCK   = BLOCK_SIZE / WORD_BYTES;     // 每个block包含的字数
    parameter BLOCK_WIDTH       = $clog2(WORDS_PER_BLOCK);      // 块内字偏移宽度
    parameter SET_WIDTH         = $clog2(SET_NUM);              // 组索引宽度
    parameter TAG_WIDTH         = ADDR_WIDTH - SET_WIDTH - BLOCK_WIDTH - 2; // 标签宽度

    parameter IDLE   = 2'b00;
    parameter LOOKUP = 2'b01;
    parameter REQ    = 2'b10;
    parameter REFILL = 2'b11;

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

    reg [ADDR_WIDTH-1:0] miss_addr;
    reg [SET_WIDTH-1:0]   miss_index;
    reg [TAG_WIDTH-1:0]   miss_tag;
    reg [BLOCK_WIDTH-1:0] miss_offset;

    wire [BLOCK_WIDTH-1:0] refill_offset = miss_offset + cnt;

     wire way_hit;
    generate
        if (N_WAYS == 1) begin
            assign way_hit = (tag_mem[index] == tag) & valid_mem[index];
        end else begin
            // 多路情况，暂不实现
            assign way_hit = 1'b0;
        end
    endgenerate

    wire hit = way_hit;
    wire miss = I_valid & ~hit;

    always @(posedge clk) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= nstate;
        end
    end

    always @(*) begin
        case(state)
            IDLE:    nstate = I_valid ? LOOKUP : IDLE;
            LOOKUP:  nstate = hit ? IDLE : REQ;
            REQ:     nstate = I_arready ? REFILL : REQ;
            REFILL:  nstate = (I_rvalid && I_rlast) ? IDLE : REFILL;
            default: nstate = IDLE;
        endcase
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
            cnt <= 0;
            miss_addr   <= 0;
            miss_index  <= 0;
            miss_tag    <= 0;
            miss_offset <= 0;
        end else if(I_clear && !clear_r) begin
            for(i = 0; i < SET_NUM*N_WAYS; i = i + 1) begin
                valid_mem[i] <= 0;
            end
        end else begin
            if(state == LOOKUP && miss) begin
                miss_addr   <= {I_addr[ADDR_WIDTH-1:2], 2'b00};
                miss_index  <= index;
                miss_tag    <= tag;
                miss_offset <= offset;
                cnt <= 0;
            end else if(state == REFILL && I_rvalid) begin
                data_mem[miss_index][refill_offset] <= I_rdata; // WRAP offset
                cnt <= I_rlast ? 0 : cnt + 1;
                if(I_rlast) begin
                    tag_mem[miss_index]   <= miss_tag;
                    valid_mem[miss_index] <= 1'b1;
                end
            end
        end
    end

    wire refill_hit = (state == REFILL) && I_rvalid && (index == miss_index) && (tag == miss_tag) && (offset == refill_offset);
    wire [DATA_WIDTH-1:0] refill_data = I_rdata;

    reg [DATA_WIDTH-1:0] odata_r;
    reg ovalid_r;

    always @(posedge clk) begin
        if(!rst_n) begin
            odata_r  <= {DATA_WIDTH{1'b0}};
            ovalid_r <= 1'b0;
        end else if(refill_hit) begin
            odata_r  <= refill_data;
            ovalid_r <= 1'b1;
        end else if((state == LOOKUP) && hit) begin
            odata_r <= data_mem[index][offset];
            ovalid_r <= 1'b1;
        end else begin
            ovalid_r <= 1'b0;
        end
    end

    assign O_data  = odata_r;
    assign O_valid = ovalid_r;
    assign O_miss  = (state == REQ) || ((state == REFILL) && !refill_hit) || miss;

    assign O_arvalid = (state == REQ);
    assign O_araddr  = miss_addr;
    assign O_arlen   = WORDS_PER_BLOCK[7:0] - 8'b1;
    assign O_arsize  = $clog2(WORD_BYTES)[2:0];
    assign O_arburst = 2'b10; // WRAP
    assign O_rready  = 1'b1;

endmodule