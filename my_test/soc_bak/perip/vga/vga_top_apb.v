module vga_top_apb(
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

    output [7:0]  vga_r,
    output [7:0]  vga_g,
    output [7:0]  vga_b,
    output        vga_hsync,
    output        vga_vsync,
    output        vga_valid
);

    parameter MEM_SIZE = 22'h20_0000;

    parameter h_frontporch = 96;
    parameter h_active = 144;
    parameter h_backporch = 784;
    parameter h_total = 800;

    parameter v_frontporch = 2;
    parameter v_active = 35;
    parameter v_backporch = 515;
    parameter v_total = 525;

    reg [23:0] vga_mem [MEM_SIZE-1:0];

    reg [9:0] x_cnt;
    reg [9:0] y_cnt;
    wire h_valid;
    wire v_valid;

    wire [9:0] h_addr;
    wire [9:0] v_addr;

    reg ack;
    wire en = in_psel && in_penable && (in_paddr >= 32'h2100_0000) && (in_paddr < 32'h2120_0000);
    wire write = en && in_pwrite;

    integer i;
    always @(posedge clock) begin
        if(reset) begin
            ack <= 0;
            for(i=0; i<MEM_SIZE; i=i+1) begin
                vga_mem[i] <= 24'h000000; //initial green screen
            end
        end else begin
            if(write && ~ack) begin
                vga_mem[in_paddr[22:2]] <= in_pwdata[23:0];
                ack <= 1;
            end else begin
                ack <= 0;
            end
        end
    end

    always @(posedge clock) begin
        if(reset == 1'b1) begin
            x_cnt <= 1;
            y_cnt <= 1;
        end else begin
            if(x_cnt == h_total)begin
                x_cnt <= 1;
                if(y_cnt == v_total) y_cnt <= 1;
                else y_cnt <= y_cnt + 1;
                
            end else begin
                x_cnt <= x_cnt + 1;
            end
        end
    end

    assign h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
    assign v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);

    assign vga_hsync = (x_cnt > h_frontporch);
    assign vga_vsync = (y_cnt > v_frontporch);
    assign vga_valid = h_valid & v_valid;

    assign in_pready = ack;
    assign in_prdata = 32'b0;
    assign in_pslverr = 1'b0;


    assign h_addr = h_valid ? (x_cnt - 10'd145) : 10'd0;
    assign v_addr = v_valid ? (y_cnt - 10'd36) : 10'd0;

    wire [19:0] vga_addr = v_addr * 10'd640 + h_addr;

    assign {vga_r, vga_g, vga_b} = vga_mem[vga_addr];

endmodule
