`include "defines.v"

module ysyx_25110270_div
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire                        I_signed_div,   //是否是有符号除法
    input   wire    [1:0]               I_op_div,       //除法类型，00:除法，01:无符号除法，10:取余，11:无符号取余
    input   wire    [`RegDataBus    ]   I_opdata1,      //被除数
    input   wire    [`RegDataBus    ]   I_opdata2,      //除数
    input   wire                        I_start,        //开始除法
    input   wire                        I_annul,        //是否取消

    output  wire    [`DoubleRegDataBus] O_result,       //低32位为商，高32位为余数
    output  wire                        O_ready         //是否结束除法
);


    parameter DivFree   = 2'b00;
    parameter DivByZero = 2'b01;
    parameter DivOn     = 2'b10;
    parameter DivEnd    = 2'b11;

    reg [5:0] cnt;
    reg [64:0] dividend;
    reg [1:0] state;
    reg [31:0] divisor;

    reg [63:0] result;
    reg ready;

    wire [32:0] div_temp = {1'b0, dividend[63:32]} - {1'b0, divisor};

    wire [31:0] temp_op1 = (I_signed_div && I_opdata1[31]) ? (~I_opdata1 + 1) : I_opdata1;
    wire [31:0] temp_op2 = (I_signed_div && I_opdata2[31]) ? (~I_opdata2 + 1) : I_opdata2;

    always @(posedge clk) begin
        if(!rst_n) begin
            state    <= DivFree;
            cnt      <= 0;
            dividend <= 0;
            divisor  <= 0;
            ready    <= 0;
            result   <= 0;
        end else begin
            case(state)
                DivFree: begin
                    if(I_start && !I_annul) begin
                        if(I_opdata2 == 0) begin
                            state <= DivByZero;
                        end else begin
                            state <= DivOn;
                            cnt   <= 0;
                        end
                        dividend  <= {31'b0, temp_op1, 1'b0};
                        divisor   <= temp_op2;
                    end else begin
                        ready <= 0;
                    end
                end
                DivByZero: begin
                    case(I_op_div)
                        2'b00: result <= -1;
                        2'b01: result <= -1;
                        2'b10: result <= {I_opdata1, 32'b0};
                        2'b11: result <= {I_opdata1, 32'b0};
                    endcase
                    ready <= 1;
                    state <= DivFree;
                end
                DivOn: begin
                    if(!I_annul) begin
                        if(cnt == 6'b100000) begin
                            if(I_signed_div && (I_opdata1[31] ^ I_opdata2[31])) begin
                                dividend[31:0] <= (~dividend[31:0] + 1);
                            end
                            if(I_signed_div && (I_opdata1[31] ^ dividend[64])) begin
                                dividend[64:33] <= (~dividend[64:33] + 1);
                            end
                            state <= DivEnd;
                            cnt <= 0;
                        end else begin
                            if(div_temp[32]) begin
                                dividend <= {dividend[63:0], 1'b0};
                            end else begin
                                dividend <= {div_temp[31:0], dividend[31:0], 1'b1};
                            end
                            cnt <= cnt + 1;
                        end
                    end else begin
                        state <= DivFree;
                    end
                end
                DivEnd: begin
                    result <= {dividend[64:33], dividend[31:0]};
                    ready  <= 1;
                    state  <= DivFree;
                end
            endcase
        end
    end

    assign O_result = result;
    assign O_ready = ready;

endmodule