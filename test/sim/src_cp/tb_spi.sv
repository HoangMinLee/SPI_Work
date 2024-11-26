`include "/home/DN02/SPI_Work/SPI/rtl/spi_module.v"
`include "/home/DN02/SPI_Work/SPI/test/sim/src_cp/interface.sv"
`include "/home/DN02/SPI_Work/SPI/test/sim/src_cp/test_trans.sv"



module tb_spi;
  bit clk;
  bit rst;

  initial begin
    clk = 1'b0;
    rst = 1'b1;
    #5 rst = 1'b0;
    #5 rst = 1'b1;  //  C1      //C2      //Status//baud rate
    //  i_spi.data_config_master <= 32'b11010110_00010000_10000000_00010001;
    //  i_spi.data_config_slave <= 32'b01000100_00000000_10000000_00010001;
    //  #4000 i_spi.data_config_master <= 32'b01010110_00010000_10000000_00110001;
  end
  always #5 clk = ~clk;

  itf_spi_env i_spi (
      clk,
      rst
  );
  test test (i_spi);


  spi_module uut (
      .clk(i_spi.clk),
      .rst_n(i_spi.rst),
      .i_data(i_spi.i_data_p),
      .MISO(i_spi.i_data_s),
      .data_config(i_spi.data_config),
      .trans_en(i_spi.trans_en),
      .interupt_request(i_spi.interupt_request),
      .o_data(i_spi.o_data_p),
      .MOSI(i_spi.o_data_s),
      .SCK(i_spi.SCK),
      .SS(i_spi.SS)
  );



endmodule
