module clock12MHz ( 
input clk , 
output reg clk12a 
);
reg clk_counter = 0;

always @ ( posedge clk ) begin //divides the 48MHz clk to 12MHz
	clk_counter <= clk_counter + 1;
	clk12a <= 1'b0;
	if ( clk_counter == 3 ) begin 
		clk12a <= 1'b1;
	end
end



endmodule