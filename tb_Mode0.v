
module tb_Mode0;

reg CLK,GATE,NEW_COUNT,TWO_BYTE_COUNTER,COUNTER_SELECTOR;
reg[7:0] INITIAL_COUNT;

Mode0 unit_to_test(
	COUNTER_SELECTOR, // This Pin is High when the counter is to be written at
	INITIAL_COUNT, // The Initial Count to Begin Count From
	TWO_BYTE_COUNTER, // High Voltage on This Pin Indicates that the Initial Count is a Two Byte Counter
	NEW_COUNT, // This Pin Goes LOW when a new count is required to be loaded
	GATE, // High Voltage Gate enables Counting on the Counter
	CLK, // System Clock Required For this Exact Counter
	OUT // High Value Indicates Counting Termination without Interruption
);
initial begin
	
	$monitor("Time=%0d COUNTER_SELECTOR=%b, INITIAL_COUNT=%b, TWO_BYTE_COUNTER=%b, NEW_COUNT=%b,GATE=%b, OUT=%b",$time,COUNTER_SELECTOR, INITIAL_COUNT, TWO_BYTE_COUNTER, NEW_COUNT,GATE, OUT);
	
	
	// Force Clock:
	CLK=1'b1;

	// first, select the counter, reset it:
	COUNTER_SELECTOR = 1'b0;
	#10
	COUNTER_SELECTOR = 1'b1;
	GATE=1'b1; // disable counter
	NEW_COUNT = 1'b0; // reset the counter itself
	TWO_BYTE_COUNTER = 1'b0; // first, try one byte count
	GATE=1'b0; //enable the counter
	INITIAL_COUNT = 'b0000_0011; // count from 3
	#20 //NEW_COUNT = 1'b1;  //must be after 4
	NEW_COUNT = 1'b1;
	#10
	#20
	// first, select the counter, reset it:
	COUNTER_SELECTOR = 1'b0;
	#10
	COUNTER_SELECTOR = 1'b1;
	GATE=1'b1; // disable counter
	NEW_COUNT = 1'b0; // reset the counter itself
	TWO_BYTE_COUNTER = 1'b0; // first, try one byte count
	GATE=1'b0; //enable the counter
	INITIAL_COUNT = 'b0000_0011; // count from 3
	#20 //NEW_COUNT = 1'b1;  //must be after 4
	NEW_COUNT = 1'b1;
	#10
	
	
	// load new count, interrupt old one:
	INITIAL_COUNT = 'b0000_1100; // count from 3
	NEW_COUNT = 1'b0;// make it load
	#20 NEW_COUNT = 1'b1;
	#50
	
	// Two Counters:
	TWO_BYTE_COUNTER = 1'b1;
	// load new count, interrupt old one:
	INITIAL_COUNT = 'b0000_0000; // count from 3
	NEW_COUNT = 1'b0;// make it load
	#10 INITIAL_COUNT = 'b0000_0001;
	#20 NEW_COUNT = 1'b1;
	#100
	
	// One Byte Again Counters:
	//TWO_BYTE_COUNTER = 1'b0;
	// load new count, interrupt old one:
	INITIAL_COUNT = 'b0000_0100; // count from 3
	NEW_COUNT = 1'b0;// make it load
	#10 INITIAL_COUNT = 'b0000_0000;
	#20 NEW_COUNT = 1'b1;
	#100
	#3000 $finish;
end

always begin
	#5 CLK = ~CLK;
end


endmodule;