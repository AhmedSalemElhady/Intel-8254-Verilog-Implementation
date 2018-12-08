module Mode0(
	input COUNTER_SELECTOR,
	input[7:0] INITIAL_COUNT,
	input TWO_BYTE_COUNTER,
	input GATE, // 00 ->counter 1, 01->counter2, 10->counter3, 11-> forbidden state
	input CLK,
	output OUT);
// we have 3 independent couters, each of which has a mode of operation:
// choosing one of them to work is dependednt on the conrol word:
// then selecting the mode to work on is also up to the control word
// assuming that this mode module is called only when the chosen mode is 0

localparam[7:0] COUNTER_EXTEND = 8'b0000_0000;
localparam VOLTAGE_HIGH = 1'b1;
localparam VOLTAGE_LOW = 1'b0;

// some required wirings:
reg[15:0] initial_buffer_count;
reg[1:0] first_byte_loaded;
reg counter_enable;


always @(posedge CLK) begin

	if(COUNTER_SELECTOR) begin
		if(TWO_BYTE_COUNTER) begin
			if(first_byte_loaded == 2'b0) initial_buffer_count <= {COUNTER_EXTEND,INITIAL_COUNT};
			else if(first_byte_loaded == 2'b01) begin
				initial_buffer_count <= {INITIAL_COUNT,initial_buffer_count[7:0]};
				first_byte_loaded <= 2'b01;
			end
			else begin// now pass the initial count to the value, set counter enable to GATE
				first_byte_loaded <= 2'b10;
				counter_enable <= GATE;
			end
		end
		else begin
			if(first_byte_loaded == 2'b0) initial_buffer_count <= {COUNTER_EXTEND,INITIAL_COUNT};
			else begin
				first_byte_loaded <= 2'b10;
				counter_enable <= GATE;
			end
		end
	end
	else begin
		initial_buffer_count <= 16'b0;
		first_byte_loaded <= 2'b0;
		counter_enable <= VOLTAGE_LOW;
	end
end




endmodule;