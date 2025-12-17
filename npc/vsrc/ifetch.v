`include "defines.v"

//------------------------------------------------------------------------
// 取指单元
//------------------------------------------------------------------------

module ifetch
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire                        I_bru_taken,        //跳转指令
    input   wire    [`InstAddrBus   ]   I_bru_target,

    input   wire                        I_ready,

    input   wire                        I_flush,            // 指令冲刷
    input   wire    [`InstAddrBus   ]   I_flush_addr,       // 冲刷跳转地址

    output  wire    [`InstBus       ]   O_inst,
    output  wire    [`InstAddrBus   ]   O_inst_addr,
    output  wire                        O_valid,

    //to bus
    output  wire                        O_ibus_req,
    output  wire                        O_ibus_we,
    output  wire    [`InstAddrBus   ]   O_ibus_addr,
    output  wire    [`InstBus       ]   O_ibus_data,
    output  wire    [`DBUS_MASK-1:0 ]   O_ibus_mask,
    input   wire    [`InstBus       ]   I_ibus_data

);

    //------------------------------------------------------------------------
    // 变量定义
    //------------------------------------------------------------------------

    parameter IDLE = 0;
    parameter WAIT = 1;
    reg state, nstate;

    reg ibus_req;

    reg [`InstAddrBus] pc;
    wire [`InstAddrBus] pc_plus4;
    wire [`InstAddrBus] npc;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= nstate;
        end
    end

    always @(*) begin
        if(!rst_n) begin
            ibus_req = 1'b0;
            nstate = IDLE;
        end else begin
            case(state)
                IDLE: begin
                    ibus_req = 1'b1;
                    nstate = WAIT;
                end
                WAIT: begin
                    ibus_req = 1'b0;
                    nstate = I_ready ? IDLE : WAIT;
                end
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pc <= `RomAddrBase;
        end else if(state == WAIT | (state == IDLE & (I_bru_taken | I_flush))) begin
            pc <= npc;
        end
    end

    assign npc = I_flush        ? I_flush_addr    :
                 I_bru_taken    ? I_bru_target    :
                 I_ready        ? pc_plus4        :
                 pc;
    
    assign pc_plus4 = pc + 32'h4;

    assign O_inst = I_ibus_data;
    assign O_inst_addr = pc;
    assign O_valid = I_ready & state == WAIT;
    

    assign O_ibus_req = ibus_req;
    assign O_ibus_we = `False;
    assign O_ibus_addr = pc;
    assign O_ibus_data = `ZeroWord;
    assign O_ibus_mask = 4'b1111;


endmodule
