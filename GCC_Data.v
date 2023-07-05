module GCC_Data ( input clk , input poll , input enable , 
output [80:0] data
);

//parameters depending on FPGA dev board
parameter LCvalue = 80; // for pico-ice
//parameter LCvalue = 50; // for Tang Nano 9k

parameter bit_value = 80;
reg [80:0] data = 0; reg [1:0] t = 2'b00; 
reg [7:0] bits = 8'd80; 
reg [7:0] HC = 8'b0; 
reg [7:0] LC = 8'b0; 
reg prev_poll; reg prev_enable;
assign each = data[bits]; //( (prev_poll && ~poll) && ~enable );

always @ ( posedge clk ) begin
    prev_poll <= poll; prev_enable <= enable;
    if ( enable == 1 ) begin
        bits <= bit_value;
    end
    else begin
        if ( prev_poll && ~poll ) begin //negedge detected
            bits <= bits - 1;
        end
    end
    
    if ( poll && ~prev_poll ) begin //posedge detected
        if ( LC > LCvalue ) begin
            data[bits] <= 0;
        end
        else begin
            data[bits] <= 1;
        end
    end
    
    if ( poll == 0 ) begin
        LC <= LC + 1;
        if ( LC > 2 ) begin
            HC <= 0;
        end
        if ( LC > 250 ) begin
            LC <= 250; //LC should never get this large!
        end
    end
   
    if ( poll == 1 ) begin
        HC <= HC + 1;
        if ( HC > 2 ) begin
            LC <= 0;
        end
        if ( HC > 250 ) begin
            HC <= 250;
        end
    end
end

endmodule