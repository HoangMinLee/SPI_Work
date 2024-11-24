`ifndef my_transaction
`define my_transaction
class transaction;
    randc   bit [7:0]i_data_m;
    randc   bit [7:0]i_data_s;
            bit [31:0]data_config_master;
            bit [31:0]data_config_slave;
            bit trans_en;
            bit interupt_request;
            bit [7:0]o_data_m;
            bit [7:0]o_data_s;

            function void display(string tag="");
                $display("time: %0t [%s] i_data_m: %h, i_data_s: %h, o_data_m: %h, o_data_s: %h",$time, tag, i_data_m, i_data_s, o_data_m, o_data_s);
            
            endfunction
	function transaction copy_data();
		transaction trans;
		trans  = new();
		trans.i_data_m = this.i_data_m;
		trans.i_data_s = this.i_data_s;
		trans.data_config_master = this.data_config_master;
		trans.data_config_slave = this.data_config_slave;
		return trans;



	endfunction		



endclass
`endif
