`define CMD_TX_FIR_I_SETUP 0
`define CMD_TX_FIR_Q_SETUP 1
`define CMD_RX_FIR_I_SETUP 2
`define CMD_RX_FIR_Q_SETUP 3
`define CMD_RX_GAIN_SET 4
`define CMD_RESET 5
`define CMD_SET_FREQUENCY 6


`define STATE_WAIT_CMD 0
`define STATE_FIR_CTRL_WAIT_ADDRESS 1
`define STATE_FIR_CTRL_WAIT_DATAL 2
`define STATE_FIR_CTRL_WAIT_DATAH 3
`define STATE_FIR_WRITE_DATA 4
`define STATE_WAIT_RX_GAINL 5
`define STATE_WAIT_RX_GAINH 6
`define STATE_WAIT_RESET_OPCODE 7
`define STATE_DO_RESET 8
`define STATE_FREQUENCY_CTRL_WAIT_DATA_BIT_7_0 9
`define STATE_FREQUENCY_CTRL_WAIT_DATA_BIT_15_8 10
`define STATE_FREQUENCY_CTRL_WAIT_DATA_BIT_23_16 11
`define STATE_FREQUENCY_CTRL_WAIT_DATA_BIT_26_24 12

module control_registers(
	clock, 
	reset_n, 
	cs_n,
	spi_data_in, 
	spi_data_en,
	fir_data_out,
	fir_address_out,
	tx_fir_i_data_we,
	tx_fir_q_data_we,
	rx_fir_i_data_we,
	rx_fir_q_data_we,
	rx_gain_out,
	rx_reset_n,
	tx_reset_n,
	frequency_data_out);
	
	input clock, reset_n,spi_data_en, cs_n;
	input [7:0] spi_data_in;
	output signed [15:0] fir_data_out;
	output [7:0] fir_address_out;
	output [15:0] rx_gain_out;
	output rx_reset_n,tx_reset_n;
	output tx_fir_i_data_we, tx_fir_q_data_we, rx_fir_i_data_we, rx_fir_q_data_we;
	output reg[26:0] frequency_data_out;
	
	reg [3:0]state;
	reg[2:0]command;
	reg[7:0]fir_address;
	reg [7:0]fir_data_l;
	reg [7:0]fir_data_h;
	reg [15:0]rx_gain;
	reg [1:0]reset_opcode;
	
	assign fir_data_out = {fir_data_h, fir_data_l};
	assign fir_address_out = fir_address;
	assign tx_fir_i_data_we = (state == `STATE_FIR_WRITE_DATA) && (command == `CMD_TX_FIR_I_SETUP);
	assign tx_fir_q_data_we = (state == `STATE_FIR_WRITE_DATA) && (command == `CMD_TX_FIR_Q_SETUP);
	assign rx_fir_i_data_we = (state == `STATE_FIR_WRITE_DATA) && (command == `CMD_RX_FIR_I_SETUP);
	assign rx_fir_q_data_we = (state == `STATE_FIR_WRITE_DATA) && (command == `CMD_RX_FIR_Q_SETUP);
	assign rx_gain_out = rx_gain;
	assign rx_reset_n = ((state == `STATE_DO_RESET) && (reset_opcode[0] == 1'b1) ? 1'b0 : 1'b1)&&reset_n; // Active low reset for RX
	assign tx_reset_n = ((state == `STATE_DO_RESET) && (reset_opcode[1] == 1'b1) ? 1'b0 : 1'b1)&&reset_n; // Active low reset for TX
	
	always @(posedge clock) begin
		if(!reset_n) begin
			state <= `STATE_WAIT_CMD;
			command <= 0;
			fir_address <= 0;
			fir_data_l <= 0;
			fir_data_h <= 0;
			rx_gain <= 0;
			reset_opcode <= 0;
			frequency_data_out <= 0;
		end else begin
			case (state)
				`STATE_WAIT_CMD: begin
					if(!cs_n && spi_data_en) begin
						command <= spi_data_in[2:0];
						case (spi_data_in[2:0])
							`CMD_TX_FIR_I_SETUP, `CMD_TX_FIR_Q_SETUP, `CMD_RX_FIR_I_SETUP, `CMD_RX_FIR_Q_SETUP: state <= `STATE_FIR_CTRL_WAIT_ADDRESS;
							`CMD_RX_GAIN_SET: state <= `STATE_WAIT_RX_GAINL;
							`CMD_RESET: state <= `STATE_WAIT_RESET_OPCODE;
							`CMD_SET_FREQUENCY: state <= `STATE_FREQUENCY_CTRL_WAIT_DATA_BIT_7_0;
						endcase
					end	else if (cs_n) begin
						state <= `STATE_WAIT_CMD;
					end
				end
				`STATE_FIR_CTRL_WAIT_ADDRESS: begin
					if(!cs_n && spi_data_en) begin
						fir_address <= spi_data_in;
						state <= `STATE_FIR_CTRL_WAIT_DATAL;
					end else if (cs_n) begin
						state <= `STATE_WAIT_CMD;
					end
				end
				`STATE_FIR_CTRL_WAIT_DATAL: begin
					if(!cs_n && spi_data_en) begin
						fir_data_l <= spi_data_in;
						state <= `STATE_FIR_CTRL_WAIT_DATAH;
					end else if (cs_n) begin
						state <= `STATE_WAIT_CMD;
					end
				end
				`STATE_FIR_CTRL_WAIT_DATAH: begin
					if(!cs_n && spi_data_en) begin
						fir_data_h <= spi_data_in;
						state <= `STATE_FIR_WRITE_DATA;
					end 
				end
				`STATE_FIR_WRITE_DATA: begin
					fir_address<=fir_address+1;
					if(!cs_n) begin
						state <= `STATE_FIR_CTRL_WAIT_DATAL;
					end else begin
						state <= `STATE_WAIT_CMD;
					end
				end
				`STATE_WAIT_RX_GAINL: begin
					if(!cs_n && spi_data_en) begin
						rx_gain[7:0] <= spi_data_in;
						state <= `STATE_WAIT_RX_GAINH;
					end else if (cs_n) begin
						state <= `STATE_WAIT_CMD;
					end
				end
				`STATE_WAIT_RX_GAINH: begin
					if(!cs_n && spi_data_en) begin
						rx_gain[15:8] <= spi_data_in;
						state <= `STATE_WAIT_CMD;
					end
				end
				`STATE_WAIT_RESET_OPCODE: begin
					if(!cs_n && spi_data_en) begin
						reset_opcode<=spi_data_in[1:0];
						state <= `STATE_DO_RESET;
					end 
				end
				`STATE_DO_RESET: begin
					// Implement reset logic based on reset_op_code
					// For example, if reset_op_code == 2'b01, reset RX; if reset_op_code == 2'b10, reset TX; if reset_op_code == 2'b11, reset both
					state <= `STATE_WAIT_CMD;
				end
				`STATE_FREQUENCY_CTRL_WAIT_DATA_BIT_7_0: begin
					if(!cs_n && spi_data_en) begin
						frequency_data_out[7:0] <= spi_data_in;
						state <= `STATE_FREQUENCY_CTRL_WAIT_DATA_BIT_15_8;
					end else if (cs_n) begin
						state <= `STATE_WAIT_CMD;
					end
				end
				`STATE_FREQUENCY_CTRL_WAIT_DATA_BIT_15_8: begin
					if(!cs_n && spi_data_en) begin
						frequency_data_out[15:8] <= spi_data_in;
						state <= `STATE_FREQUENCY_CTRL_WAIT_DATA_BIT_23_16;
					end else if (cs_n) begin
						state <= `STATE_WAIT_CMD;
					end
				end
				`STATE_FREQUENCY_CTRL_WAIT_DATA_BIT_23_16: begin
					if(!cs_n && spi_data_en) begin
						frequency_data_out[23:16] <= spi_data_in;
						state <= `STATE_FREQUENCY_CTRL_WAIT_DATA_BIT_26_24;
					end else if (cs_n) begin
						state <= `STATE_WAIT_CMD;
					end
				end
				`STATE_FREQUENCY_CTRL_WAIT_DATA_BIT_26_24: begin
					if(!cs_n && spi_data_en) begin
						frequency_data_out[26:24] <= spi_data_in;
						state <= `STATE_WAIT_CMD;
					end else if (cs_n) begin
						state <= `STATE_WAIT_CMD;
					end
				end

			endcase
		end
	end
	
	
	
endmodule
	