module Mode0(
	input COUNTER_SELECTOR, // This Pin is High when the counter is to be written at
	input[7:0] INITIAL_COUNT, // The Initial Count to Begin Count From
	input TWO_BYTE_COUNTER, // High Voltage on This Pin Indicates that the Initial Count is a Two Byte Counter
	input NEW_COUNT, // This Pin Goes LOW when a new count is required to be loaded
	input GATE, // LOW Voltage Gate enables Counting on the Counter
	input CLK, // System Clock Required For this Exact Counter
	output OUT // High Value Indicates Counting Termination without Interruption
);
// we have 3 independent couters, each of which has a mode of operation:
// choosing one of them to work is dependednt on the conrol word:
// then selecting the mode to work on is also up to the control word
// assuming that this mode module is called only when the chosen mode is 0

localparam[7:0] COUNTER_EXTEND = 8'b0000_0000; // Extend The Two Bytes of Counter if it was a Single Byte Counter Value
localparam VOLTAGE_HIGH = 1'b1; // High Voltage Reference
localparam VOLTAGE_LOW = 1'b0; // Ground Voltage Reference
localparam[1:0] NO_BYTES_LOADED_YET = 2'b00;
localparam[1:0] FIRST_BYTE_IS_LOADED = 2'b01;
localparam[1:0] SECOND_BYTE_IS_LOADED = 2'b10;

// some required wirings:
reg[15:0] initial_buffer_count;
reg[1:0] first_byte_loaded;
reg counter_enable;
reg counter_reset;
reg counter_load_enable;

Counter counter_unit(CLK, counter_reset, counter_load_enable, counter_enable, initial_buffer_count, OUT);

always @(posedge CLK) begin

	if(COUNTER_SELECTOR) begin
		if(NEW_COUNT==VOLTAGE_LOW) begin	// a new count is to be readed
			// first Thing is to reset the counter
			if(TWO_BYTE_COUNTER) begin // if the Initial Count Was To Be an Initial Count, Reset The Value Of Out, Load New Count

				if(first_byte_loaded == NO_BYTES_LOADED_YET) begin
					initial_buffer_count <= {COUNTER_EXTEND,INITIAL_COUNT};
					first_byte_loaded <= FIRST_BYTE_IS_LOADED; 
 					counter_reset <= VOLTAGE_LOW;
				end
				else if(first_byte_loaded == FIRST_BYTE_IS_LOADED) begin
					initial_buffer_count <= {INITIAL_COUNT,initial_buffer_count[7:0]};
					first_byte_loaded <= SECOND_BYTE_IS_LOADED; // when second byte is loaded, load it in the counter itself
					counter_enable <= VOLTAGE_LOW;
					counter_load_enable <= VOLTAGE_HIGH;
					counter_reset <= VOLTAGE_HIGH;
				end

				else begin // now pass the initial count to the value, set counter enable to GATE
					first_byte_loaded <= NO_BYTES_LOADED_YET; // The Value of NEW_COUNT Should Go VOLTAGE_LOW After This
					counter_enable <= GATE;
					counter_load_enable <= VOLTAGE_LOW;
					counter_reset <= VOLTAGE_HIGH;
				end
			end
			else begin
				counter_reset <= VOLTAGE_HIGH;
				if(first_byte_loaded == NO_BYTES_LOADED_YET) begin
					initial_buffer_count <= {COUNTER_EXTEND,INITIAL_COUNT}; // it is loaded
					first_byte_loaded <= FIRST_BYTE_IS_LOADED;
					counter_enable <= VOLTAGE_LOW;		
					counter_load_enable <= VOLTAGE_HIGH;	
				end
				else begin
					first_byte_loaded <= NO_BYTES_LOADED_YET;
					counter_enable <= GATE;
					counter_load_enable <= VOLTAGE_LOW;						
				end
			end
		end
	end 
	else begin // The Counter Is Not Selected: Latch The Same Values!!
		counter_reset <= VOLTAGE_LOW;
		initial_buffer_count <= 'b0;
		first_byte_loaded <= 2'b0; // Must Reset The Bytes Count
		counter_enable <= VOLTAGE_LOW;
		counter_load_enable <= VOLTAGE_LOW;
	end
end

endmodule;