interface itf_spi_env( input logic clk, rst);
    logic [7:0]i_data_m;
    logic [7:0]i_data_s;
    logic [31:0]data_config_master;
    logic [31:0]data_config_slave;
    logic trans_en;
    logic interupt_request;
    logic [7:0]o_data_m;
    logic [7:0]o_data_s;

	clocking driver_cb @(posedge clk); 
		default input #1 output #1;
		input o_data_m;
		input o_data_s;
		input interupt_request;
		output i_data_m;
		output i_data_s;
		output data_config_master;
		output data_config_slave;
		output trans_en;
	endclocking 
	modport DRIVER (clocking driver_cb, input clk, rst);


endinterface
