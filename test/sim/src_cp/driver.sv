

`include "/home/DN02/SPI_Work/SPI/test/sim/src_cp/transaction.sv"
`define DRIV_ITF i_spi.DRIVER.driver_cb
class driver;
  int no_transaction;
  virtual itf_spi_env i_spi;
  mailbox gen2driv;
  reg [11:0] R_counter_div;
  reg [11:0] cal;
  function new(virtual itf_spi_env i_spi, mailbox gen2driv);
    this.i_spi = i_spi;
    this.gen2driv = gen2driv;
    R_counter_div = 12'b0;
    cal = 12'b0;
  endfunction
  // reset
  task reset;
    wait (i_spi.rst);
    `DRIV_ITF.i_data_p  <= 8'b0;
    `DRIV_ITF.io_miso_s <= 8'b0;
    `DRIV_ITF.trans_en  <= 1'b0;

    //case master   
    `DRIV_ITF.io_miso_s <= 1'b0;

  endtask

  task driver;

    transaction trans;
    gen2driv.get(trans);
    //output
    @(posedge i_spi.DRIVER.clk);
    `DRIV_ITF.data_config <= trans.data_config;
    if (trans.data_config[28] == 0) begin
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
      @(posedge i_spi.DRIVER.clk) begin
        if (i_spi.rst) begin
          R_counter_div <= 12'b0;  // Reset counter when system reset
          cal           <= 12'b0;
          `DRIV_ITF.SCK <= trans.data_config[27];
        end else if (trans.data_config[28] && trans.data_config[30] == 1 && trans.data_config[25] == 0) begin
          if (!`MDRIV_ITF.SCK) begin
            if (R_counter_div < cal) begin
              R_counter_div <= R_counter_div + 1'b1;
            end else begin
              R_counter_div  <= 12'b0;
              `MDRIV_ITF.SCK <= ~`MDRIV_ITF.SCK;
            end
          end else begin
            `MDRIV_ITF.SCK <= trans.data_config[27];
          end
        end
      end

      for (int i = 0; i < 8; i++) begin
        //  @(posedge i_spi.SCK)
        //	  trans.o_data_s[7-i] = `DRIV_ITF.o_data_s;
        @(negedge `MDRIV_ITF.SCK) `DRIV_ITF.io_mosi_s <= trans.io_mosi_s[7-i];
      end

    end


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
