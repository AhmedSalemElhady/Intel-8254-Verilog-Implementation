module Dflipflop(
	input clk,
	input rst,
	input enable,
	input input_value,
	output output_value);


localparam[15:0] BASE_RESET = 16'b0000_0000;
reg output_value_output;
always @(posedge clk, rst) begin

	if(rst) output_value_output <= BASE_RESET;
	else output_value_output <= (enable)? input_value: output_value_output;
end

assign output_value = output_value_output;

endmodule;	