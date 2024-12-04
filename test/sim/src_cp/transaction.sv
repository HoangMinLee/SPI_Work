`ifndef my_transaction
`define my_transaction
class transaction;
  randc bit [7:0] i_data_p;
  randc bit [7:0] io_miso_s;
  bit [31:0] data_config;
  bit trans_en;
  bit interupt_request;
  bit [7:0] o_data_p;
  randc bit [7:0] io_mosi_s;
  bit SCK;
  bit SS;

  function void display(string tag = "");
    $display("time: %0t [%s] i_data_m: %h, io_miso_s: %h, o_data_m: %h, io_mosi_s: %h", $time, tag,
             i_data_p, io_miso_s, o_data_p, io_mosi_s);

  endfunction
  function transaction copy_data();
    transaction trans;
    trans = new();
    trans.i_data_p = this.i_data_p;
    trans.io_miso_s = this.io_miso_s;
    trans.data_config = this.data_config;
    trans.o_data_p = this.o_data_p;
    trans.io_mosi_s = this.io_mosi_s;
    return trans;
  endfunction



endclass
`endif
