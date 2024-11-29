`include "/home/DN02/SPI_Work/SPI/test/sim/src_cp/transaction.sv"
`define DRIV_ITF i_spi.DRIVER.driver_cb
class driver;
  int no_transaction;
  virtual itf_spi_env i_spi;
  mailbox gen2driv;
  function new(virtual itf_spi_env i_spi, mailbox gen2driv);
    this.i_spi = i_spi;
    this.gen2driv = gen2driv;
    reg [11:0] R_counter_div;
    reg [11:0] cal;
    reg SCK_reg;

  endfunction
  // reset
  task reset;
    wait (i_spi.rst);
    `DRIV_ITF.i_data_p <= 8'b0;
    `DRIV_ITF.io_miso_s <= 8'b0;
    `DRIV_ITF.SS <= 1'b0;
    R_counter_div = 0;
    cal = 12'b1;
    SCK_reg = 0;

    //case master
    `DRIV_ITF.io_mosi_s <= 1'b0;

    wait (!i_spi.rst);

  endtask

  task driver;

    transaction trans;
    gen2driv.get(trans);
    //output
    @(posedge i_spi.DRIVER.clk);
    `DRIV_ITF.data_config <= trans.data_config;
    if (trans.data_config[28] == 1) begin
      repeat (10) @(i_spi.DRIVER.clk);
      `DRIV_ITF.i_data_p <= trans.i_data_p;
      `DRIV_ITF.trans_en <= 1'b1;
      //@(negedge i_spi.SS)
      for (int i = 0; i < 8; i++) begin
        //  @(posedge i_spi.SCK)
        //	  trans.o_data_s[7-i] = `DRIV_ITF.o_data_s;
        @(negedge i_spi.SCK) `DRIV_ITF.io_miso_s <= trans.io_miso_s[7-i];
      end
      trans.interupt_request = `DRIV_ITF.interupt_request;
      repeat (10) @(posedge i_spi.DRIVER.clk);
      `DRIV_ITF.trans_en <= 1'b0;
      no_transaction++;
    end else begin
      repeat (10) @(i_spi.DRIVER.clk);
      `DRIV_ITF.i_data_p <= trans.i_data_p;
      `DRIV_ITF.SS <= 1'b0;
      fork
        begin
          forever begin
            @(posedge i_spi.DRIVER.clk);
            if (!`DRIV_ITF.SS) begin
              if (R_counter_div < cal) begin
                counter++;
              end else begin
                counter = 0;
                `DRIV_ITF.SCK <= ~`DRIV_ITF.SCK;
              end
            end
          end
        end
      join_none

      for (int i = 0; i < 8; i++) begin
        @(negedge `DRIV_ITF.SCK) `DRIV_ITF.io_mosi_s <= trans.io_mosi_s[7-i];
      end
    end
    trans.interupt_request = `DRIV_ITF.interupt_request;
    repeat (10) @(posedge i_spi.DRIVER.clk);
    `DRIV_ITF.SS <= 1'b1;
    disable fork;  // Stop clock generation
    no_transaction++;


  endtask
  task main;
    fork
      begin
        wait (i_spi.rst);
      end
      begin
        forever driver();
      end

    join_any
  endtask
endclass
