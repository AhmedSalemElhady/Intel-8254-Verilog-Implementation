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
//reg EnableCountingtemp;
reg [15:0]Counter;
reg [15:0]Countertemp;
localparam state0=3'b000;
localparam state1=3'b001;
localparam state2=3'b010;
//localparam state3=3'b011;
//localparam state4=3'b100;
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
		Countertemp={msb,lsb};//to renew the countertemp w a3mlo be zero awl mabd2 counting
		//ta8t fl main lazm el tempcount fl if mayb2ash be zero 3ashan kda 3amltlo assign bardw
		Counter={msb,lsb};//renew also the counter
	end
end

always @(msb,lsb)
begin
	Countertemp={msb,lsb};
end

always @(negedge clk)
begin	
	case(state_reg)
	state0://idle state no counting as no gate enabled
	begin
		out=1;
		if ( Countertemp!=0 && EnableCounting==1'b1)//if conditions to begin the counting are satisfied then enter
		begin
			Counter=Countertemp;//3ashan law el countertemp initially be number 
			EnableCounting=1'b0;//reset the STARTING enable counting
			//if (Counter==Countertemp)
			//begin
			Countertemp=0;
			//end
			state_reg=state2;//go to state2 to begin counting
			out=0;//and make the output LOW
			//Counter={msb,lsb};//+16'b0000_0000_0000_0001;	
		end
	end
	state1://3ashan law gali trigger f nos mana ba3ed
	begin
		state_reg=state2;
		Counter=Counter-1;
		if (Counter==0)//incase new initial count equals 1 fa a3edaha hena warg3 lel idle 3la tool
		begin
			state_reg=state0;
			out=1;
		end
		Countertemp=0;
	end
	state2:
	begin
		if (gate==1'b1)//if trigerred during counting
		begin
			state_reg=state1;
		end
		else
		begin
			Counter=Counter-1;
			Countertemp=0;
			if (Counter>0)
			begin
				out=0;
				state_reg=state2;//remain in the same state
			end
			else if (Counter==0 || Counter<0 )//3ashan law kan 1 cycle bs w trigerred during counting
			begin
				//Counter=Countertemp;
				//if (Counter==Countertemp)
				//	Countertemp=0;
				//if (Counter!=0 && EnableCounting==1'b1) //w kan geh enable add it
				//begin
					//EnableCounting=1'b0;
						//out=0;
					//state_reg=state2;
				//end
				//else if (Counter==0)
				//begin
				state_reg=state0;
				out=1;
				//end
			end
		end	
	end
	default: state_reg=state0;
	endcase
end

endmodule
