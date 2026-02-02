`include "defines.v"

//------------------------------------------------------------------------
// 执行分支跳转模块
//------------------------------------------------------------------------

module ysyx_25110270_exe_bru
(
    input   wire                        I_src_eq,
    input   wire                        I_src_lt,
    input   wire    [`BRUCTL_WIDTH-1:0] I_bru_ctrl,
    
    output  wire                        O_bru_taken
);
    reg bru_taken;

    always @(*) begin
        case(I_bru_ctrl)
            `BRUCTL_JAL, `BRUCTL_JALR:  bru_taken = `Enable;
            `BRUCTL_BEQ:                bru_taken = I_src_eq;
            `BRUCTL_BNE:                bru_taken = ~I_src_eq;
            `BRUCTL_BLT, `BRUCTL_BLTU:  bru_taken = I_src_lt;
            `BRUCTL_BGE:                bru_taken = ~I_src_lt;
            `BRUCTL_BGEU:               bru_taken = ~I_src_lt;
            default:                    bru_taken = `Disable;
        endcase
    end

    assign O_bru_taken = bru_taken;


endmodule
