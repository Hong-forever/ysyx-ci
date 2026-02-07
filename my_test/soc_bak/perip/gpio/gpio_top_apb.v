module gpio_top_apb
(
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

    output [15:0] gpio_out,
    input  [15:0] gpio_in,
    output [7:0]  gpio_seg_0,
    output [7:0]  gpio_seg_1,
    output [7:0]  gpio_seg_2,
    output [7:0]  gpio_seg_3,
    output [7:0]  gpio_seg_4,
    output [7:0]  gpio_seg_5,
    output [7:0]  gpio_seg_6,
    output [7:0]  gpio_seg_7
);

    parameter LED_ADDR = 4'h0;
    parameter SW_ADDR = 4'h4;
    parameter SEG_ADDR = 4'h8;

    reg [15:0] LED;
    reg [15:0] SW;
    reg [31:0] SEG;

    wire en = in_psel && in_penable;

    integer i;
    always @(posedge clock) begin
        if(reset) begin
            LED <= 0;
            SEG <= 0;
        end else if(en && in_pwrite) begin
            case(in_paddr[3:0])
                LED_ADDR: begin
                    for(i=0; i<2; i=i+1) begin
                        LED[i*8+:8] <= in_pstrb[i] ? in_pwdata[i*8+:8] : LED[i*8+:8];
                    end
                end
                SEG_ADDR: begin
                    for(i=0; i<4; i=i+1) begin
                        SEG[i*8+:8] <= in_pstrb[i] ? in_pwdata[i*8+:8] : SEG[i*8+:8];
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end

    always @(posedge clock) begin
        if(reset) begin
            SW <= 0;
        end else if(en && !in_pwrite) begin
            SW <= in_paddr[3:0] == SW_ADDR ? gpio_in : SW;
        end
    end

    wire [7:0] seg[15:0];
    assign  seg[0]   = 8'b0000_0011;  // 0 - 03
    assign  seg[1]   = 8'b1001_1111;  // 1 - 9F
    assign  seg[2]   = 8'b0010_0101;  // 2 - 25
    assign  seg[3]   = 8'b0000_1101;  // 3 - 0D
    assign  seg[4]   = 8'b1001_1001;  // 4 - 99
    assign  seg[5]   = 8'b0100_1001;  // 5 - 49
    assign  seg[6]   = 8'b0100_0001;  // 6 - 41
    assign  seg[7]   = 8'b0001_1111;  // 7 - 1F
    assign  seg[8]   = 8'b0000_0001;  // 8 - 01
    assign  seg[9]   = 8'b0000_1001;  // 9 - 09
    assign  seg[10]  = 8'b0001_0001;  // A - 11
    assign  seg[11]  = 8'b1100_0001;  // b - C1
    assign  seg[12]  = 8'b0110_0011;  // C - 63
    assign  seg[13]  = 8'b1000_0101;  // d - 85
    assign  seg[14]  = 8'b0110_0001;  // E - 61
    assign  seg[15]  = 8'b0111_0001;  // F - 71

    reg ack;
    always @(posedge clock) begin
        if(reset) begin
            ack <= 1'b0;
        end else begin
            ack <= en;
        end
    end

    assign in_pready = ack;
    assign in_pslverr = 1'b0;

    assign in_prdata = (in_paddr[3:0] == LED_ADDR) ? {16'b0, LED} :
                       (in_paddr[3:0] == SW_ADDR)  ? {16'b0, SW}  :
                       (in_paddr[3:0] == SEG_ADDR) ? SEG :
                       32'b0;

    assign gpio_out = LED;
    assign gpio_seg_0 = seg[SEG[3:0]];
    assign gpio_seg_1 = seg[SEG[7:4]];
    assign gpio_seg_2 = seg[SEG[11:8]];
    assign gpio_seg_3 = seg[SEG[15:12]];
    assign gpio_seg_4 = seg[SEG[19:16]];
    assign gpio_seg_5 = seg[SEG[23:20]];
    assign gpio_seg_6 = seg[SEG[27:24]];
    assign gpio_seg_7 = seg[SEG[31:28]];

endmodule
