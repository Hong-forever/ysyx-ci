module sdram
#(
    parameter NUM = 0
)(
    input        clk,
    input        cke,
    input        cs,
    input        ras,
    input        cas,
    input        we,
    input [12:0] a,
    input [ 1:0] ba,
    input [ 1:0] dqm,
    inout [15:0] dq
);

    localparam SDRAM_MHZ             = 100;
    localparam SDRAM_BANK_W          = 2;
    localparam SDRAM_DQM_W           = 2;
    localparam SDRAM_BANKS           = 2 ** SDRAM_BANK_W;
    localparam SDRAM_ROW_W           = 13;
    localparam SDRAM_COL_W           = 9;

    localparam CMD_W             = 4;
    localparam CMD_NOP           = 4'b0111;
    localparam CMD_ACTIVE        = 4'b0011;
    localparam CMD_READ          = 4'b0101;
    localparam CMD_WRITE         = 4'b0100;
    localparam CMD_TERMINATE     = 4'b0110;
    localparam CMD_PRECHARGE     = 4'b0010;
    localparam CMD_REFRESH       = 4'b0001;
    localparam CMD_LOAD_MODE     = 4'b0000;

    parameter STATE_IDLE         = 0;
    parameter STATE_NOP          = 1;
    parameter STATE_ACTIVE       = 2;
    parameter STATE_READ         = 3;
    parameter STATE_WRITE        = 4;
    parameter STATE_TERMINATE    = 5;
    parameter STATE_PRECHARGE    = 6;
    parameter STATE_REFRESH      = 7;
    parameter STATE_LOAD_MODE    = 8;

    reg [SDRAM_ROW_W-1:0] mode;
    reg [3:0]  state, nstate;

    reg [SDRAM_BANK_W-1:0] bank_active;
    reg [SDRAM_ROW_W-1:0] row_active[SDRAM_BANKS-1:0];
    reg [SDRAM_COL_W-1:0] col_active;

    reg [2:0] burst_cnt;
    reg [2:0] cas_cnt;

    wire [15:0] dq_in;
    reg [15:0] dq_out;

    wire [SDRAM_COL_W-1:0] col_addr = a[SDRAM_COL_W-1:0];

    wire [2:0] burst_len = 2 ** mode[2:0];
    wire [2:0] cas_len   = mode[6:4];

    wire [CMD_W-1:0] cmd = {cs, ras, cas, we};


    always @(posedge clk) begin
        if(!cke) begin
            state <= STATE_IDLE;
        end else begin
            state <= nstate;
        end
    end

    always @(*) begin
        if(!cke) begin
            nstate = STATE_IDLE;
        end else begin
            case(state)
                STATE_IDLE: begin
                    case(cmd)
                        CMD_ACTIVE: begin
                            nstate = STATE_ACTIVE;
                        end
                        CMD_READ: begin
                            nstate = STATE_READ;
                        end
                        CMD_WRITE: begin
                            nstate = STATE_WRITE;
                        end
                        CMD_PRECHARGE: begin
                            nstate = STATE_PRECHARGE;
                        end
                        CMD_REFRESH: begin
                            nstate = STATE_REFRESH;
                        end
                        CMD_LOAD_MODE: begin
                            nstate = STATE_LOAD_MODE;
                        end
                        default: begin
                            nstate = STATE_IDLE;
                        end
                    endcase
                end
                STATE_ACTIVE: begin
                    case(cmd)
                        CMD_READ: begin
                            nstate = STATE_READ;
                        end
                        CMD_WRITE: begin
                            nstate = STATE_WRITE;
                        end
                        default: begin
                            nstate = STATE_IDLE;
                        end
                    endcase
                end
                STATE_READ: begin
                    if(burst_cnt == burst_len) begin
                        nstate = STATE_IDLE;
                    end else begin
                        nstate = STATE_READ;
                    end
                end
                STATE_WRITE: begin
                    if(burst_cnt == burst_len) begin
                        nstate = STATE_IDLE;
                    end else begin
                        nstate = STATE_WRITE;
                    end
                end
                STATE_TERMINATE: begin
                    nstate = STATE_IDLE;
                end
                STATE_PRECHARGE: begin
                    nstate = STATE_NOP;
                end
                STATE_REFRESH: begin
                    nstate = STATE_NOP;
                end
                STATE_LOAD_MODE: begin
                    nstate = STATE_IDLE;
                end
                default: begin
                    nstate = STATE_IDLE;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if(!cke) begin
            row_active[0]  <= 0;
            row_active[1]  <= 0;
            row_active[2]  <= 0;
            row_active[3]  <= 0;
            bank_active  <= 0;
            mode        <= 0;
            col_active  <= 0;
        end else begin
            if(nstate == STATE_ACTIVE || nstate == STATE_PRECHARGE) begin
                row_active[ba]  <= a;
            end
            if(nstate == STATE_LOAD_MODE) begin
                mode <= a;
            end
            if(cmd == CMD_READ || cmd == CMD_WRITE) begin
                bank_active  <= ba;
                col_active <= col_addr;
            end
        end
    end

    always @(posedge clk) begin
        if(!cke) begin
            burst_cnt <= 0;
            cas_cnt   <= 0;
        end else begin
            case(nstate)
                STATE_READ: begin
                    if(cas_cnt < cas_len - 1) begin
                        cas_cnt <= cas_cnt + 1;
                    end else if(cas_cnt >= cas_len - 1) begin
                        cas_cnt <= 0;
                        if(burst_cnt < burst_len) begin
                            burst_cnt <= burst_cnt + 1;
                        end
                    end
                end
                STATE_WRITE: begin
                    if(burst_cnt < burst_len) begin
                        burst_cnt <= burst_cnt + 1;
                    end
                end
                default: begin
                    cas_cnt   <= 0;
                    burst_cnt <= 0;
                end
            endcase
        end
    end


import "DPI-C" function void sdram_read(input int addr, output int data, input int num);
import "DPI-C" function void sdram_write(input int addr, input int data, input int mask, input int num);

    wire [SDRAM_ROW_W+SDRAM_COL_W+SDRAM_BANK_W+1:0] full_addr_active, full_addr;
    assign full_addr_active = {row_active[bank_active], bank_active, col_active[SDRAM_COL_W-1:0], 2'b0};
    assign full_addr = {row_active[ba], ba, col_addr[SDRAM_COL_W-1:0], 2'b0};

    always @(posedge clk) begin
        if(cas_cnt == cas_len - 1 && burst_cnt < burst_len) begin
            if(nstate == STATE_READ) begin
                sdram_read(full_addr_active, dq_out, NUM);
            end
        end else if(nstate == STATE_WRITE && burst_cnt < burst_len) begin
            sdram_write(full_addr, dq_in, dqm, NUM);
        end
    end

    assign dq_in = dq;
    assign dq = (state == STATE_READ) ? dq_out : 16'bz;

endmodule
