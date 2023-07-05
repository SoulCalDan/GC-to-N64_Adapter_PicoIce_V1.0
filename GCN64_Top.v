module GCN64_Top ( 
    input clk , 
	//output GC_poll , output r0 , output r1 , output r2 , output r3 ,
    inout tri line_N64_1 , 	inout tri line_N64_2 ,	inout tri line_N64_3 , inout tri line_N64_4 ,
    inout tri line_GC_1 , inout tri line_GC_2 ,	inout tri line_GC_3 , inout tri line_GC_4
    );
pullup (line_GC_1); pullup (line_GC_2); pullup (line_GC_3); pullup (line_GC_4);

//assign r0 = enable64; //assign r2 = bits2[0]; //assign r1 = Response[4]; //assign r3 = Response[2];

wire data_N64_1;		wire data_N64_2;		wire data_N64_3;		wire data_N64_4;
wire [4:0] Response_1;	wire [4:0] Response_2;	wire [4:0] Response_3;	wire [4:0] Response_4;
wire [19:0] A_1;		wire [19:0] A_2;		wire [19:0] A_3;		wire [19:0] A_4;
wire [80:0] data_1;		wire [80:0] data_2;		wire [80:0] data_3;		wire [80:0] data_4;
wire enable64_1;		wire enable64_2;		wire enable64_3;		wire enable64_4;
wire analog_check_1;	wire analog_check_2;	wire analog_check_3;	wire analog_check_4;
wire N64_Controller_1; 	wire N64_Controller_2;	wire N64_Controller_3;	wire N64_Controller_4;
wire Rumble_1;			wire Rumble_2;			wire Rumble_3;			wire Rumble_4;
 
//MODULE LIST _1
bounce      bounce_N64_1      (.clk(clk),.enable(enable64_1),.line(line_N64_1),.debounced(data_N64_1));
bounce      bounce_GCC_1      (.clk(clk),.enable(GC_enable_1),.line(line_GC_1),.debounced(data_GCC_1));
GC_PollGen  GC_PollGen_1      (.clk(clk),.GC_poll(GC_poll_1),.GC_enable(GC_enable_1),.Rumble(Rumble_1));
GCC_Data    GCC_Data_1        (.clk(clk),.poll(data_GCC_1),.data(data_1),.enable(GC_enable_1)); 
N64_ID      N64_ID_1          (.clk(clk),.data(data_N64_1),.Response(Response_1),.Rumble(Rumble_1));
Analog1     Analog_1         (.data(data_1),.A1(A_1),.analog_check(analog_check_1),.clk(clk));
Control     Control_1         (.clk(clk),.data(data_1),.Response(Response_1),.A1(A_1),.N64_Controller(N64_Controller_1),.enable(enable64_1),.analog_check(analog_check_1));

assign line_GC_1 = GC_enable_1 ? GC_poll_1 : 1'bz;
assign line_N64_1 = ( enable64_1 && ~N64_Controller_1 ) ? 1'b0 : 1'bz;


//MODULE LIST _2
bounce bounce_N64_2 (.clk(clk),.enable(enable64_2),.line(line_N64_2),.debounced(data_N64_2));
bounce bounce_GCC_2 (.clk(clk),.enable(GC_enable_2),.line(line_GC_2),.debounced(data_GCC_2));
GC_PollGen GC_PollGen_2 (.clk(clk),.GC_poll(GC_poll_2),.GC_enable(GC_enable_2),.Rumble(Rumble_2));
GCC_Data GCC_Data_2 (.clk(clk),.poll(data_GCC_2),.data(data_2),.enable(GC_enable_2));
N64_ID N64_ID_2 (.clk(clk),.data(data_N64_2),.Response(Response_2),.Rumble(Rumble_2));
Analog1 Analog_2 (.data(data_2),.A1(A_2),.analog_check(analog_check_2),.clk(clk));
Control Control_2 (.clk(clk),.data(data_2),.Response(Response_2),.A1(A_2),.N64_Controller(N64_Controller_2),.enable(enable64_2),.analog_check(analog_check_2));

assign line_GC_2 = GC_enable_2 ? GC_poll_2 : 1'bz;
assign line_N64_2 = ( enable64_2 && ~N64_Controller_2 ) ? 1'b0 : 1'bz;


//MODULE LIST _3
bounce bounce_N64_3 (.clk(clk),.enable(enable64_3),.line(line_N64_3),.debounced(data_N64_3));
bounce bounce_GCC_3 (.clk(clk),.enable(GC_enable_3),.line(line_GC_3),.debounced(data_GCC_3));
GC_PollGen GC_PollGen_3 (.clk(clk),.GC_poll(GC_poll_3),.GC_enable(GC_enable_3),.Rumble(Rumble_3));
GCC_Data GCC_Data_3 (.clk(clk),.poll(data_GCC_3),.data(data_3),.enable(GC_enable_3));
N64_ID N64_ID_3 (.clk(clk),.data(data_N64_3),.Response(Response_3),.Rumble(Rumble_3));
Analog1 Analog_3 (.data(data_3),.A1(A_3),.analog_check(analog_check_3),.clk(clk));
Control Control_3 (.clk(clk),.data(data_3),.Response(Response_3),.A1(A_3),.N64_Controller(N64_Controller_3),.enable(enable64_3),.analog_check(analog_check_3));

assign line_GC_3 = GC_enable_3 ? GC_poll_3 : 1'bz;
assign line_N64_3 = ( enable64_3 && ~N64_Controller_3 ) ? 1'b0 : 1'bz;


//MODULE LIST _4
bounce bounce_N64_4 (.clk(clk),.enable(enable64_4),.line(line_N64_4),.debounced(data_N64_4));
bounce bounce_GCC_4 (.clk(clk),.enable(GC_enable_4),.line(line_GC_4),.debounced(data_GCC_4));
GC_PollGen GC_PollGen_4 (.clk(clk),.GC_poll(GC_poll_4),.GC_enable(GC_enable_4),.Rumble(Rumble_4));
GCC_Data GCC_Data_4 (.clk(clk),.poll(data_GCC_4),.data(data_4),.enable(GC_enable_4));
N64_ID N64_ID_4 (.clk(clk),.data(data_N64_4),.Response(Response_4),.Rumble(Rumble_4));
Analog1 Analog_4 (.data(data_4),.A1(A_4),.analog_check(analog_check_4),.clk(clk));
Control Control_4 (.clk(clk),.data(data_4),.Response(Response_4),.A1(A_4),.N64_Controller(N64_Controller_4),.enable(enable64_4),.analog_check(analog_check_4));

assign line_GC_4 = GC_enable_4 ? GC_poll_4 : 1'bz;
assign line_N64_4 = ( enable64_4 && ~N64_Controller_4 ) ? 1'b0 : 1'bz;

endmodule    