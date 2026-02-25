`include "defines.v"

//------------------------------------------------------------------------
// 分支预测模块
//------------------------------------------------------------------------

module ysyx_25110270_branch_predictor
#(
    parameter SRC_WIDTH = 32
)(
    input   wire                        clk,
    input   wire                        rst,

    input   wire                        update,              // 来自EX阶段的分支预测更新信号
    input   wire    [SRC_WIDTH-1:0]     update_src,          // 来自EX阶段的指令地址
    input   wire    [31:0]              update_dst,          // 来自EX阶段的分支目标地址

    input   wire    [31:0]              inst,
    input   wire    [SRC_WIDTH-1:0]     pc,           // 来自IF阶段的指令地址
    output  wire                        taken,        // 输出到IF阶段的分支是否被预测为采取
    output  wire    [31:0]              target        // 输出到IF阶段的分支目标地址
);

    wire valid;
    wire [31:0] branch_target;

    assign taken = (((inst[6:0] == 7'h63) & inst[31]) | (inst[6:0] == 7'h6f)) & valid;
    assign target = branch_target;

    ysyx_25110270_branch_target_buffer 
    #(
        .SRC_WIDTH              (SRC_WIDTH                  )
    ) btb 
    (
        .clk                    (clk                        ),
        .rst                    (rst                        ),
        .update                 (update                     ),
        .update_src             (update_src                 ),
        .update_dst             (update_dst                 ),
        .source                 (pc                         ),
        .valid                  (valid                      ),
        .target                 (branch_target              )
    );

endmodule

module ysyx_25110270_branch_target_buffer
#(
    parameter SRC_WIDTH = 32
)(
    input   wire                        clk,
    input   wire                        rst,

    input   wire                        update,
    input   wire    [SRC_WIDTH-1:0]     update_src,
    input   wire    [31:0]              update_dst,

    input   wire    [SRC_WIDTH-1:0]     source,
    output  wire                        valid,
    output  wire    [31:0]              target
);

    reg [31:0] btb [0:(1<<SRC_WIDTH)-1];
    reg btb_valid [0:(1<<SRC_WIDTH)-1];

    integer i;
    always @(posedge clk) begin
        if(rst) begin
            for(i = 0; i < (1<<SRC_WIDTH); i = i + 1) begin
                btb_valid[i] <= 0;
            end
        end else if(update) begin
            btb[update_src] <= update_dst;
            btb_valid[update_src] <= 1;
        end
    end

    assign valid = btb_valid[source];
    assign target = btb[source];

endmodule