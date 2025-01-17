interface itf_spi_env (
    input logic clk,
    rst
);
  logic [31:0] data_config;
  logic trans_en;
  logic [7:0] i_data_p;
  logic [7:0] o_data_p;
  logic interupt_request;
  wire SCK;
  wire i_data_s;
  wire o_data_s;
  wire SS;

  clocking driver_cb @(posedge clk);
    default input #1 output #1;
    input o_data_p;
    input interupt_request;
    output i_data_p;
    output data_config;
    output trans_en;
    inout SCK;
    inout i_data_s;
    inout o_data_s;
    inout SS;
  endclocking
  modport DRIVER(clocking driver_cb, input clk, rst);


endinterface
