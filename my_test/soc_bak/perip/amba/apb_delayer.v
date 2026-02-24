module apb_delayer(
    input         clock,
    input         reset,
    input  [31:0] in_paddr,
    input         in_psel,
    input         in_penable,
    input  [2:0]  in_pprot,
    input         in_pwrite,
    input  [31:0] in_pwdata,
    input  [3:0]  in_pstrb,
    output        in_pready,
    output [31:0] in_prdata,
    output        in_pslverr,

    output [31:0] out_paddr,
    output        out_psel,
    output        out_penable,
    output [2:0]  out_pprot,
    output        out_pwrite,
    output [31:0] out_pwdata,
    output [3:0]  out_pstrb,
    input         out_pready,
    input  [31:0] out_prdata,
    input         out_pslverr
);
    parameter IDLE   = 2'b00;
    parameter ACCESS = 2'b01;
    parameter WAIT   = 2'b10;

    parameter FREQ_CPU = 975;
    parameter FREQ_PER = 100;

    parameter FACTOR = 10;
    parameter RATE_FIX = 8960; // (freq - 1) * 1024  975 -> 8960, 1037 -> 10619
    
    reg [1:0] state, nstate;

    reg [31:0] rdata;

    reg [63:0] delay_counter;

    always @(posedge clock) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= nstate;
        end
    end

    always @(*) begin
        if(reset) begin
            nstate = IDLE;
        end else begin
            case(state)
                IDLE: begin
                    if(in_psel) begin
                        nstate = ACCESS;
                    end else begin
                        nstate = IDLE;
                    end
                end
                ACCESS: begin
                    if(out_pready) begin
                        nstate = WAIT;
                    end else begin
                        nstate = ACCESS;
                    end
                end
                WAIT: begin
                    if(delay_counter == 1) begin
                        nstate = IDLE;
                    end else begin
                        nstate = WAIT;
                    end
                end
                default: begin
                    nstate = IDLE;
                end
            endcase
        end
    end
    
    always @(posedge clock) begin
        if(reset) begin
            delay_counter <= 0;
        end else begin
            case(state)
                IDLE: begin
                    delay_counter <= 0;
                end
                ACCESS: begin
                    if(!out_pready) begin
                        delay_counter <= delay_counter + RATE_FIX;
                    end else begin
                        delay_counter <= delay_counter >> FACTOR;
                    end
                end
                WAIT: begin
                    delay_counter <= delay_counter - 1;
                end
                default: begin
                    delay_counter <= 0;
                end
            endcase
        end
    end

    always @(posedge clock) begin
        if(reset) begin
            rdata <= 0;
        end else if(state == ACCESS && out_pready) begin
            rdata <= out_prdata;
        end
    end

    reg psel, penable;
    always @(posedge clock) begin
        if(reset) begin
            psel <= 0;
            penable <= 0;
        end else if(out_pready) begin
            psel <= 0;
            penable <= 0;
        end else begin
            psel <= (state == ACCESS || (state == IDLE && in_psel));
            penable <= (state == ACCESS);
        end
    end

    

    assign out_paddr   = in_paddr;
    assign out_psel    = RATE_FIX == 0 ? in_psel : psel;
    assign out_penable = RATE_FIX == 0 ? in_penable : penable;
    assign out_pprot   = in_pprot;
    assign out_pwrite  = in_pwrite;
    assign out_pwdata  = in_pwdata;
    assign out_pstrb   = in_pstrb;
    assign in_pready   = RATE_FIX == 0 ? out_pready : (state == WAIT) && (delay_counter == 1);
    assign in_prdata   = RATE_FIX == 0 ? out_prdata : rdata;
    assign in_pslverr  = out_pslverr;

endmodule
