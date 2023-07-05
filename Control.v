module Control (
	input clk , 
    input [80:0] data,
    input [4:0] Response,
    input [19:0] A1 , 
	output enable , output clk_en , output analog_check , output [10:0] bits2 ,
    output N64_Controller //N64 controller data order is A,B,Z,S,DU,DD,DL,DR,RESET,RESERVED,L,R,CU,CD,CL,CR,JX,JY
);
reg [3:0] L; reg [3:0] H; reg [3:0] M; reg [3:0] F; reg [31:0] B; reg [31:0] P; reg [31:0] C;
reg analog_check = 1; //the purpose of analog check is to stop GCC analog data from updating during a N64 write of analog data
reg [139:0] LetsGetReadyToRumble;
reg [135:0] Controller;
reg [135:0] Status;
reg [135:0] PeriInsert; reg [135:0] PeriInsert2; 
reg [1067:0] PakResponse;
reg B_toggle = 0;
parameter PakSize = 1067;
initial begin
	N64_Controller = 1'bz;
	L = 4'h1; H = 4'h7; M = 4'h3; F = 4'hF; B=32'h11111111; C=32'h71111111; P=32'h11111111;
	Controller = {F,L,L,L,L,L,L,L,L,L,L,L,L,L,L,L,L,H,L,L,L,L,L,L,L,H,L,L,L,L,L,L,L,H}; //4'b1111 + 128 pulses + 4'b0111;
	Status	   = {3'b111,L,L,L,L,L,H,L,H,L,L,L,L,L,L,L,L,L,L,L,L,L,L,L,H,M,F,F,F,F,F,F,F,F,1'b1}; //stops at 25 bits, but padding it out. Only last 4 bits of protocol change based on controller peripheral
	PakResponse = {1,1,F,F,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,P,M};	//
	//PakResponse2= 	{F,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,M};
	PeriInsert = {F,1'b1,H,H,H,L,L,L,L,H,M,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,3'b111}; // xE1 is something inserted , x1E is nothing
	PeriInsert2= {F,1'b1,H,L,H,H,H,L,L,L,M,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,3'b111}; // xB8 for Rumble inserted?
	LetsGetReadyToRumble	   = {F,F,H,L,L,L,L,L,L,L,M,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F}; // Rumble returns x80, apparently, need to verify
end

always @ ( * ) begin
    Controller[130:129] = {2{data[72]}}; // A 
    Controller[126:125] = {2{data[73]}}; // B
    Controller[122:121] = {2{data[70]}}; // Z  should be 68, but swapped with L to be like VC
    Controller[118:117] = {2{data[76]}}; // Start
    Controller[114:113] = {2{data[67]}}; // DU
    Controller[110:109] = {2{data[66]}}; // DD
    Controller[106:105] = {2{data[64]}}; // DL
    Controller[102:101] = {2{data[65]}}; // DR
    Controller[98:97] = 2'b00;// Reset - always 0 except L+R+S
    Controller[94:93] = 2'b00;// Reserved - always 0
    Controller[90:89] = {2{(data[68] && data[64])}}; // L swapped with Z to be like VC
    Controller[86:85] = {2{data[69]}}; // R   
    Controller[82:81] = {2{A1[19]}}; // CU
    Controller[78:77] = {2{(A1[18] || data[68])}}; // CD or Z
    Controller[74:73] = {2{(A1[17] || data[75])}}; // CL or GC_Y
    Controller[70:69] = {2{(A1[16] || data[74])}}; // CR or GC_X
    Controller[66:65] = {2{A1[15]}};	Controller[62:61] = {2{A1[14]}}; // X joystick
    Controller[58:57] = {2{A1[13]}};	Controller[54:53] = {2{A1[12]}};
    Controller[50:49] = {2{A1[11]}};	Controller[46:45] = {2{A1[10]}};
	Controller[42:41] = {2{A1[09]}};	Controller[38:37] = {2{A1[08]}};
    Controller[34:33] = {2{A1[7]}};		Controller[30:29] = {2{A1[6]}};  // Y Joystick
    Controller[26:25] = {2{A1[5]}};		Controller[22:21] = {2{A1[4]}};
    Controller[18:17] = {2{A1[3]}};		Controller[14:13] = {2{A1[2]}};
	Controller[10:09] = {2{A1[1]}};		Controller[06:05] = {2{A1[0]}};	
	if ( B_toggle ) begin
		PakResponse = {1,1,F,F,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,C,H,L,H,H,H,L,L,L,M};
	end
	else begin
		PakResponse = {1,1,F,F,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,P,M};
	end
end

reg [7:0] bits = 8'd135; reg [10:0] bits2 = PakSize;
reg N64_Controller; reg enable;
always @ ( posedge clk ) begin
	if ( clk_en && Response[4:0] == 5'b10001 ) begin
		N64_Controller <= Controller[bits];
		if ( bits > 1 ) begin
			bits <= bits - 1; enable <= 1;
		end
		else begin
			bits <= 1; N64_Controller <= 1'b1;	enable <= 0;
		end
		if ( bits > 1 && bits < 90 ) begin
			analog_check <= 0;
		end
		else begin
			analog_check <= 1;
		end
	end
	if ( clk_en && Response[4:0] == 5'b10010 ) begin
		N64_Controller <= Status[bits];
			if ( bits > 30 ) begin
			bits <= bits - 1; enable <= 1;
		end
		else begin
			bits <= 1; N64_Controller <= 1'b1;	enable <= 0;
		end
	end
	if ( clk_en && Response[4:0] == 5'b10100 ) begin
		N64_Controller <= PeriInsert[bits];
			if ( bits > 95 ) begin
			bits <= bits - 1; enable <= 1;
		end
		else begin
			bits <= 1; N64_Controller <= 1'b1;	enable <= 0;
		end
	end
	if ( clk_en && Response[4:0] == 5'b10101 ) begin
		N64_Controller <= PeriInsert2[bits];
			if ( bits > 95 ) begin
			bits <= bits - 1; enable <= 1;
		end
		else begin
			bits <= 1; N64_Controller <= 1'b1;	enable <= 0;
		end
	end
	if ( clk_en && Response[4:0] == 5'b10110 ) begin
		N64_Controller <= PakResponse[bits2];
		if ( bits2 > 1 ) begin
			bits2 <= bits2 - 1; enable <= 1;
		end
		else begin
			bits2 <= 1; N64_Controller <= 1'b1;	enable <= 0; B_toggle <= ~B_toggle;
		end
	end
	if ( clk_en && Response[4:0] == 5'b10111 ) begin
		N64_Controller <= LetsGetReadyToRumble[bits];
			if ( bits > 91 ) begin
			bits <= bits - 1; enable <= 1;
		end
		else begin
			bits <= 1; N64_Controller <= 1'b1;	enable <= 0;
		end
	end
	else if ( clk_en && Response[4] == 1'b0 ) begin //Response[4] is only 0 when no other poll conditions are not active
		bits <= 135; bits2 <= PakSize;
	end
end

//parameters depending on FPGA dev board
parameter clk_div_value = 45; // for pico-ice
//parameter clk_div_value = 25; // for Tang Nano 9k

reg [5:0] clk_div = 0; reg clk_en = 0;
always @ ( posedge clk ) begin // clk at 1_MHz
	clk_en <= 1'b0;	clk_div <= clk_div + 1;
	if ( clk_div > clk_div_value ) begin
		clk_div <= 0; clk_en <= 1;
	end
end
		

 
endmodule