
`include "/home/minhuyenhwe/spi_protocol/test/sim/src/interface.sv"
//`include "/home/minhuyenhwe/spi_protocol/test/sim/TEST_BAUD_RATE/test_baud_rate_no_interupt.sv"
`include "/home/minhuyenhwe/spi_protocol/test/sim/TEST_TRANS_MSB_LSB/test_trans_msb_lsb.sv"
//`include "/home/minhuyenhwe/spi_protocol/test/sim/TEST_CHANGE_CONFIG/test_change_config.sv"
//`include "/home/minhuyenhwe/spi_protocol/test/sim/TEST_TRANSACTION_RANDOM/test_transaction_random.sv"
module tb_spi;
    bit clk;
    bit rst;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        #5 rst = 1'b0;
        #5 rst = 1'b1;              //  C1      //C2      //Status//baud rate
      //  i_spi.data_config_master <= 32'b11010110_00010000_10000000_00010001;
      //  i_spi.data_config_slave <= 32'b01000100_00000000_10000000_00010001;
      //  #4000 i_spi.data_config_master <= 32'b01010110_00010000_10000000_00110001;
    end
    always #5 clk = ~clk;

    itf_spi_env i_spi(clk, rst);
    test test(i_spi);


top_spi uut(
    .clk(i_spi.clk),
    .rst(i_spi.rst),
    .i_data_m(i_spi.i_data_m),
    .i_data_s(i_spi.i_data_s),
    .data_config_master(i_spi.data_config_master),
    .data_config_slave(i_spi.data_config_slave),
    .trans_en(i_spi.trans_en),
    .interupt_request(i_spi.interupt_request),
    .o_data_m(i_spi.o_data_m),
    .o_data_s(i_spi.o_data_s)
);
endmodule

