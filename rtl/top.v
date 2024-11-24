module top_spi (
    input wire clk,
    input wire rst,
    input wire [7:0] i_data_m,
    input wire [7:0] i_data_s,
    input wire [31:0] data_config_master,
    input wire [31:0] data_config_slave,
    input wire trans_en,
    output interupt_request,
    output [7:0] o_data_m,
    output [7:0] o_data_s
);
  wire trans_sl;
  wire MOSI, MISO, SCK, SS, interupt_m, interupt_s;
  spi_module master (
      clk,
      rst,
      data_config_master,
      i_data_m,
      trans_en,
      o_data_m,
      interupt_m,
      SCK,
      MOSI,
      MISO,
      SS
  );
  spi_module slave (
      clk,
      rst,
      data_config_slave,
      i_data_s,
      trans_sl,
      o_data_s,
      interupt_s,
      SCK,
      MOSI,
      MISO,
      SS
  );
  assign interupt_request = interupt_m | interupt_s;

endmodule
