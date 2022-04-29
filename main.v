`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:37:13 03/26/2022 
// Design Name: 
// Module Name:    main 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module time_alarm(Out, clk_1s, clk_5ms, up, down, clk, control, rst, s_alarm, buzzer);

input  clk;
input up, down, s_alarm, rst;
output reg [5:0]control;
output reg[6:0]Out;
output reg buzzer;

output reg clk_1s;
output reg clk_5ms;

reg [27:0] counter;
reg [6:0] counter1;

reg [7:0]sec; // gio phut giay
reg [7:0]min;
reg [7:0]hour;


reg [3:0]c_sec; // dv, c
reg [3:0]dv_sec;

reg [3:0]c_min;
reg [3:0]dv_min;

reg [3:0]c_hour;
reg [3:0]dv_hour;
////////////////////////// alarm bit
reg [7:0]min_alarm;
reg [7:0]hour_alarm;

reg [3:0]c_hour_alarm;
reg [3:0]dv_hour_alarm;

reg [3:0]c_min_alarm;
reg [3:0]dv_min_alarm;


reg [2:0]count;  // bien dem quet led
initial begin
	counter = 28'b0;// counter 1s
	clk_1s = 1'b0;
	sec = 8'd0;
	counter1 = 28'b0; // counter
	clk_5ms = 1'b0;
	
	count = 3'b000;
	sec = 8'd0;
	min = 8'd50;
	hour = 8'd7;
	
	min_alarm = 8'd0;  // set alarm
	hour_alarm = 8'd0;

	buzzer = 1'b0;

end

always @(posedge clk) // chia xung 1hz
begin
	counter <= counter + 1;
	if (counter == 28'd50_000) // tao xung 1Hz
		begin
			counter <= 28'b0;
			clk_1s <= ~clk_1s;
			/// d?o tr?ng thái còi kêu
			if ({min, hour}=={min_alarm, hour_alarm} ) // check alarm
			begin
					buzzer = ~buzzer;	
			end
			else if ({min, hour}!={min_alarm, hour_alarm}) // check alarm
			begin
				buzzer = 1'b0;	
			end
		end
end


always @(posedge clk) // chia xung hz
begin
	counter1 <= counter1 + 1;
	if (counter1 == 7'd100) // tao xung 
		begin
			counter1 <= 28'b0;
			clk_5ms <= ~clk_5ms;
		end
end

function [3:0]mod_10; // chia 10
	input [5:0]number;
	begin
		mod_10 = (number >= 50) ? 5:((number>=40)?4:((number>=30)?3:((number>=20)?2:((number>=10)?1:0))));
	end
endfunction

function [6:0]number_led7seg; //lay so led 7 doan
	input [3:0]num;
	begin
		number_led7seg = (num == 4'd0) ? 7'b1000000:((num == 4'd1)?7'b1111001:((num == 4'd2)?7'b0100100:((num==4'd3)?7'b0110000:((num==4'd4)?7'b0011001:((num == 4'd5)?7'b0010010:((num == 4'd6)?7'b0000010:((num == 4'd7)?7'b1111000:((num == 4'd8)?7'b0000000:7'b0010000))))))));
	end
endfunction


always @(posedge clk_1s)
begin
	sec = sec + 1; 
	if (down && !s_alarm) //up hour
		begin
			hour = hour + 1;
			if(hour == 24)
				hour = 0;	
		end
	if (up && !s_alarm) // up min
		begin
			min = min +1;
			if(min == 60)
				min = 0;	
		end
	
	///////////////////////////////// set alarm	
	if (down && s_alarm) //up hour alarm
		begin
			hour_alarm = hour_alarm + 1;
			if(hour_alarm == 24)
				hour_alarm = 0;	
		end
	if (up && s_alarm) // up min alarm
		begin
			min_alarm = min_alarm +1;
			if(min_alarm == 60)
				min_alarm = 0;	
		end	
	if(rst)begin
		sec = 8'd0;
		min = 8'd0;
		hour = 8'd0;
		
		min_alarm = 8'd0;  // set alarm
		hour_alarm = 8'd0;
	end	
	/////////////////////////////////// time up
	if(sec == 60)
		begin
			 sec = 0;  //reset seconds
			 min = min + 1;
			 if(min == 60)
				begin
					 min = 0;  //reset seconds
					 hour = hour + 1;
				end
				if(hour == 24)
				begin
					hour = 0;
				end	
		end	
	
	c_sec = mod_10(sec); 
	dv_sec = sec - c_sec*10;	
	
	c_min = mod_10(min); 
	dv_min = min - c_min*10;
	
	c_hour = mod_10(hour); 
	dv_hour = hour - c_hour*10;

	////////////////////////////////////// alarm
	c_hour_alarm = mod_10(hour_alarm); 
	dv_hour_alarm = hour_alarm - c_hour_alarm*10;
	c_min_alarm = mod_10(min_alarm); 
	dv_min_alarm = min_alarm - c_min_alarm*10;
	
	
end



always @ (posedge clk_5ms)
begin
	if (!s_alarm)begin   // if change
		if(count == 3'b101)
			begin
				case (c_hour)
					4'd0: Out = 7'b1000000;
					4'd1: Out = 7'b1111001;
					4'd2: Out = 7'b0100100;
				endcase
				control = 6'b000001;
			end
		else if (count == 3'b100)
			begin
				Out = number_led7seg(dv_hour);	
				control = 6'b000010;
			end
		else if (count == 3'b011)
			begin
				Out = number_led7seg(c_min);	
				control = 6'b000100;
			end
		else if (count == 3'b010)
			begin
				Out = number_led7seg(dv_min);		
				control = 6'b001000;
			end
		else if (count == 3'b001)
			begin
				Out = number_led7seg(c_sec);	
				control = 6'b010000;
			end
		else if (count == 3'b000)
			begin
				Out = number_led7seg(dv_sec);	
				control = 6'b100000;
			end
	end 
	else if (s_alarm)begin   // if change
		if(count == 3'b101)
			begin
				case (c_hour_alarm)
					4'd0: Out = 7'b1000000;
					4'd1: Out = 7'b1111001;
					4'd2: Out = 7'b0100100;
				endcase
				control = 6'b000001;
			end
		else if (count == 3'b100)
			begin
				Out = number_led7seg(dv_hour_alarm);	
				control = 6'b000010;
			end
		else if (count == 3'b011)
			begin
				Out = number_led7seg(c_min_alarm);	
				control = 6'b000100;
			end
		else if (count == 3'b010)
			begin
				Out = number_led7seg(dv_min_alarm);		
				control = 6'b001000;
			end
		else if (count == 3'b001)
			begin
				Out = number_led7seg(c_sec);	
				control = 6'b010000;
			end
		else if (count == 3'b000)
			begin
				Out = number_led7seg(dv_sec);	
				control = 6'b100000;
			end
	end 
		
	
	
	count = count + 3'b001;
	if(count == 3'b110)
	begin
		count = 3'b000;
	end		
end

endmodule
