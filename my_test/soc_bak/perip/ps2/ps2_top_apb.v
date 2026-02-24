module ps2_top_apb(
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

  input         ps2_clk,
  input         ps2_data
);

    reg [9:0] buffer;
    reg [7:0] fifo[7:0];
    reg [2:0] w_ptr, r_ptr;   
    reg [3:0] count;  
    reg [2:0] ps2_clk_sync;
    reg ready;
    reg [7:0] rdata;
    reg ack;

    always @(posedge clock) begin
        ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};
    end

    wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

    wire en = in_psel && in_penable && (in_paddr[7:0] == 8'h00);
    wire read = en && !in_pwrite;

    always @(posedge clock) begin
        if(reset) begin // reset
            count <= 0; 
            w_ptr <= 0; 
            r_ptr <= 0; 
            ready <= 0;
            rdata <= 0;
        end else begin
            if(read & ~ack) begin // ready to output next data
                if(ready) begin
                    r_ptr <= r_ptr + 3'b1;
                    if(w_ptr == (r_ptr + 3'b1)) begin
                        ready <= 1'b0;
                    end
                    rdata <= fifo[r_ptr];
                end else begin
                    rdata <= 8'b0;
                end
            end
            if(sampling) begin
                if(count == 4'd10) begin
                    if((buffer[0] == 0) &&  // start bit
                            (ps2_data)   &&  // stop bit
                            (^buffer[9:1])) begin      // odd  parity
                        // received one byte
                        fifo[w_ptr] <= buffer[8:1];
                        w_ptr <= w_ptr+3'b1;
                        ready <= 1'b1;
                    end
                    count <= 0;     // for next
                end else begin
                    buffer[count] <= ps2_data;  // store ps2_data
                    count <= count + 3'b1;
                end
            end
        end
    end

    always @(posedge clock) begin
        if(reset) begin
            ack <= 0;
        end else begin
            if(read & ~ack) begin
                ack <= 1;
            end else begin
                ack <= 0;
            end
        end
    end

    assign in_prdata = {24'b0, rdata};
    assign in_pready = ack;
    assign in_pslverr = 1'b0;

endmodule
