module GC_PollGen ( input clk , input Rumble , output reg GC_enable , output reg GC_poll
);
    //reg [35:0] Connect =    36'b0001_0001_0001_0001_0001_0001_0001_0001_0111;
    //reg [35:0] Sync =       36'b0001_0111_0001_0001_0001_0001_0001_0111_0111;
	reg [3:0] L; reg [3:0] H; reg [3:0] M; reg [3:0] F; reg [99:0] Controller; 

	initial begin
	L = 4'h1; H = 4'h7; M = 4'h3; F = 4'hF; 
    //Controller =    //{L,H,L,L,L,L,L,L,L,L,L,L,L,L,H,H,L,L,L,L,L,L,L,0,R,1,H};
	Controller = 100'b0001_0111_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0111_0111_0001_0001_0001_0001_0001_0001_0001_0001_0111;
    end
	reg [10:0] bit_counter = 2047; 
	reg [4:0] clk_counter = 0; 
	reg [2:0] clk12_counter = 0; 
    reg GC = 0; reg clk12 = 0;

//always @ ( posedge clk ) begin //divides the 48MHz clk to 12MHz
	//clk_counter <= clk_counter + 1; //if you uncomment this code, clk_counter must only be 2 bits in the reg declaration
	//clk12 <= 1'b0;
	//if ( clk_counter == 3 ) begin 
		//clk12 <= 1'b1;
	//end
//end

//always @( posedge clk ) begin
	//if ( clk12 ) begin 
		//if ( clk12_counter > 6 ) begin
			//clk12_counter <= 2;
			//GC <= ~GC;
		//end
		//else begin
			//clk12_counter <= clk12_counter + 1; 
		//end    
		//if ( bit_counter < 104 ) begin
			//GC_enable <= 1;
		//end
		//else begin
			//GC_enable <= 0;
		//end
	//end
//end

parameter clk_counter_value = 22; //for pico ice
//parameter clk_counter_value = 12; //for Tang Nano 9k
always @ ( posedge clk ) begin //divides the 27MHz or 48MHz clk to 1MHz
	clk_counter <= clk_counter + 1; 
    if ( clk_counter == clk_counter_value ) begin
        GC <= ~ GC;
		clk_counter <= 0;
        if ( bit_counter < 104 ) begin
			GC_enable <= 1;
        end 
		else begin
            GC_enable <= 0; //FPGA gives control of the data line to Gamecube controller
        end
	end
end


always @ ( posedge GC ) begin
	//if ( t == 0 ) begin -> IDK if I should bother with the other GC controller commands.
	if ( bit_counter < 101 ) begin 
		GC_poll <= Controller[bit_counter];
		bit_counter <= bit_counter - 1;
	end
	else begin
		if ( bit_counter == 2047 ) begin // counter wrapped from 0 to 1023
		bit_counter <= 1000; //365 minimum
		end
		else begin
			bit_counter <= bit_counter - 1; 
		end
	end
 end
 
 always @ ( * ) begin
	 Controller[6:5] = {2{Rumble}};
end
endmodule