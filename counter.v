module Counter(
	input clk,
	input rst,
	input load,
	input enable,
	input[15:0] new_count,
	output counting_complete);
// the module is for interruptable counter

// definition of some constants to be used:
localparam[15:0] COUNTER_BASE = 16'b0000_0000; 	    // the base for any count_down counter unless interrupted
localparam[15:0] COUNTER_DECREMENT = 16'b0000_0001; // the decrementer of the counter: state decreases by 1 each clock pulse
localparam VOLTAGE_HIGH = 1'b1;

reg[15:0] counter_current_state;

always @(posedge clk,rst) begin

	if(rst == 1'b0) begin
		counter_current_state <= 16'b0; // the reset is negatove valued
	end
	else begin
	     	if(enable) begin// inverted value:
			counter_current_state <= counter_current_state;
		end
		else begin
			if(load) begin
				
				counter_current_state <= new_count;
			end
			else begin
				counter_current_state <= (counter_current_state == COUNTER_BASE)? COUNTER_BASE : counter_current_state-COUNTER_DECREMENT;
			end
		end
	end 
end

assign counting_complete = (rst==1'b0)? 1'b0 :
			   (enable)? counting_complete :
			   (load)? 1'b0:// counting_complete_output;
			   (counter_current_state == COUNTER_BASE)? 1'b1: 1'b0;
endmodule;