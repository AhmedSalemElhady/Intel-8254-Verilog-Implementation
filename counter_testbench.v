module tb_counter;

reg clk,rst,load,enable;
reg[15:0] new_count;
wire[15:0] counter_current_state;
wire counting_complete;

Counter counter_unit(clk,rst,load,enable,new_count,counting_complete);

initial begin
	$monitor("Time=%0d rst=%b, load=%b, enable=%b, new_count=%b,counting_complete=%b",$time,rst,load,enable,new_count,counting_complete);
	// force clock:
	clk = 1'b1;
	enable=1'b1;
	load=1'b1;
	rst=1'b0; #10
	rst=1'b1; // release asynchronous part
	enable=1'b0;
	load=1'b1;
	new_count = 16'b0000_0011;#10
	load=1'b0; #60
	// interrupt the counting, restart from 4
	load=1'b1;
	new_count = 16'b0000_0100;#10
	load=1'b0; #300
	$finish;	
end

always begin 
	#5 clk=~clk;
end


endmodule;
