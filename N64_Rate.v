module N64_Rate (
    input clk , clk12 , 
    input [4:0] Response , 
    output N64clk , enable , t , output [7:0] GCdiv
);

reg N64clk = 0;  
reg [7:0] GCdiv = 8'b0; 
reg [10:0] GCcount = 11'd1; 
reg enable = 0; 
reg [4:0] GCreset = 0;
reg [10:0] GCstop = 11'd234; 
reg t = 0;

always @ ( posedge clk ) begin
	if ( clk12 ) begin
		if ( Response[4] == 1 ) begin
			GCreset <= 0;

			if ( GCcount < 200 ) begin
				t <= ~t;
				if ( GCdiv > 40 && GCdiv < 57 ) begin
					enable <= 1;
				end
				else if ( GCdiv > 56 ) begin
					GCdiv <= 52;
					N64clk <= ~N64clk;
					GCcount <= GCcount + 1;
				end
				else begin
					GCdiv <= GCdiv + 1;
				end
			end
			else begin
				enable <= 0;
			end
		end
    
		if ( Response[4] == 0 ) begin
			GCcount <= 0;
			GCdiv <= 0;
			if ( GCreset < 7 ) begin
				GCreset <= GCreset + 1;
				N64clk <= 0;
			end
			else if ( GCreset > 6 && GCreset < 21 ) begin
				GCreset <= GCreset + 1;
				N64clk <= 1;
			end
			else begin
				N64clk <= 0;
			end
		end
	end
end

always @ ( posedge enable ) begin
    if ( Response[4:0] == 5'b00001) begin
        GCstop <= 264; 
    end
    else if ( Response[4:0] == 5'b00010 ) begin
        GCstop <= 200;
    end
    else if ( Response[4:0] == 5'b00011 ) begin
        GCstop <= 515;
    end
    else begin
        GCstop <= 300;
    end
end


endmodule