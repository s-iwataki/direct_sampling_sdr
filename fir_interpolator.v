/*fir interpolator*/

module fir_interpolator(clock,reset_n,signal_in,signal_out,fir_update_clk,input_en,coeff_we,coeff_in,coeff_w_addr);
	parameter SIGNAL_BITWIDTH = 16, NMAX_TAPS =256;
	input clock,reset_n,fir_update_clk,input_en,coeff_we;
	input signed [SIGNAL_BITWIDTH-1:0] signal_in,coeff_in;
	input [7:0]coeff_w_addr;
	output reg signed [SIGNAL_BITWIDTH-1:0] signal_out;
	reg signed [SIGNAL_BITWIDTH-1:0] signal_mem [0:NMAX_TAPS-1];
	reg signed [SIGNAL_BITWIDTH-1:0] tap_coeffs [0:NMAX_TAPS-1];
	reg signed [SIGNAL_BITWIDTH-1:0] signal_mem_out;
	reg signed [SIGNAL_BITWIDTH-1:0] tap_coeffs_out;
	reg [7:0] tap_address_counter;
	reg [7:0] sigmem_addr_counter;
	reg [7:0] sigmem_read_addr;
	reg [7:0] coeff_read_addr;
	reg fir_update_en_adress_stg,fir_update_en_memout_stg,fir_update_en_mult_stg;
	reg signed [2*SIGNAL_BITWIDTH-1:0] fir_accumlator;
	reg signed [2*SIGNAL_BITWIDTH-1:0] mult_result;
	reg signed [SIGNAL_BITWIDTH-1:0] output_sampler;
	reg signed [SIGNAL_BITWIDTH-1:0] fir_output;
	wire[7:0] signal_mem_read_addr;
    wire signed [SIGNAL_BITWIDTH-1:0]fir_in ;
	assign signal_mem_read_addr=sigmem_addr_counter-tap_address_counter;
    assign fir_in=input_en? signal_in: 0;//If input_en is low, feed 0 to FIR filter to output interpolated values without new input samples.
	
	always @(posedge clock) begin
		if(!reset_n) begin
			tap_address_counter<=0;
			sigmem_addr_counter<=0;
			fir_accumlator<=0;
			output_sampler<=0;
			fir_update_en_adress_stg<=0;
			fir_update_en_memout_stg<=0;
			fir_update_en_mult_stg<=0;
		end else begin
			tap_address_counter<=tap_address_counter+1;
			sigmem_read_addr<=signal_mem_read_addr;
			coeff_read_addr<=tap_address_counter;
			signal_mem_out<=signal_mem[sigmem_read_addr];
			tap_coeffs_out<=tap_coeffs[coeff_read_addr];
			mult_result<=signal_mem_out*tap_coeffs_out;
			fir_update_en_adress_stg<=fir_update_clk;
			fir_update_en_memout_stg<=fir_update_en_adress_stg;
			fir_update_en_mult_stg<=fir_update_en_memout_stg;
			if(fir_update_clk) begin
				sigmem_addr_counter<=sigmem_addr_counter+1;
				signal_mem[sigmem_addr_counter]<=fir_in;
				
			end
			if(fir_update_en_mult_stg) begin
				fir_accumlator<= mult_result;
				signal_out<=fir_accumlator[2*SIGNAL_BITWIDTH-1:SIGNAL_BITWIDTH];
			end else begin
				fir_accumlator<= mult_result+fir_accumlator;
			end
			
			if(coeff_we)begin
				tap_coeffs[coeff_w_addr]<=coeff_in;
			end
			
		end
	end

endmodule