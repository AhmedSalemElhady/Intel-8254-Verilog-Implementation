module Mode1(clk,gate,msb,lsb,out);
input clk;
input [7:0]msb;
input [7:0]lsb;
input gate;
output out;
//output finished;
//reg finished;
reg out;
reg EnableCounting;
reg EnableCountingtemp;
reg [15:0]Counter;
reg [15:0]Countertemp;
localparam state0=3'b000;
localparam state1=3'b001;
localparam state2=3'b010;
localparam state3=3'b011;
localparam state4=3'b100;
reg[2:0] state_reg;

initial
begin
	out=1;
	Counter=0;
	Countertemp=0;
end

always @(gate)
begin
	if (gate==1'b1)
	begin
		EnableCounting=1'b1;
	end
end

always @(msb,lsb)
begin
	Countertemp={msb,lsb};
end

always @(negedge clk)
begin	
	//if (Counter!=0)
	//begin
		case(state_reg)
		state0:
		begin
			out=1;
			if ( Countertemp!=0 && EnableCounting==1'b1)
			begin
				Counter=Countertemp;
				EnableCounting=1'b0;
				if (Counter==Countertemp)
				begin
					Countertemp=0;
				end
				state_reg=state2;
				out=0;
				//Counter={msb,lsb};//+16'b0000_0000_0000_0001;	
			end
		end
		state2:
		begin
			Counter=Counter-1;
			//out=0;
			if (Counter>0)
			begin
				out=0;
				state_reg=state2;
			end
			else if (Counter==0)
			begin
				Counter=Countertemp;
				if (Counter==Countertemp)
					Countertemp=0;
				if (Counter!=0 && EnableCounting==1'b1) //w kan geh enable add it
				begin
					EnableCounting=1'b0;
					out=0;
					state_reg=state2;
				end
				else if (Counter==0)
				begin
					state_reg=state0;
					out=1;
				end
			end
		end
		default: state_reg=state0;
		endcase
	//end

end

endmodule
