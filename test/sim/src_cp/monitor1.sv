`include "/home/DN01/SPI_Work/SPI/test/sim/src_cp/transaction.sv"
class monitor;
  virtual itf_spi_env i_spi;

  mailbox mon2scb;
  function new(virtual itf_spi_env i_spi, mailbox mon2scb);
    this.i_spi   = i_spi;
    this.mon2scb = mon2scb;
  endfunction

  task main;
    forever begin
      transaction trans;
      trans = new();
      if (trans.data_config[28] == 1) begin
        @(posedge i_spi.clk);
        wait (!i_spi.SS);
        trans.i_data_p = i_spi.i_data_p;

        for (int i = 0; i < 8; i++) begin
          @(posedge i_spi.SCK) trans.io_mosi_s[i] = i_spi.io_mosi_s;
          @(negedge i_spi.SCK) trans.io_miso_s[i] = i_spi.io_miso_s;
        end
        wait (i_spi.SS);
        @(posedge i_spi.clk);
        trans.o_data_p = i_spi.o_data_p;
        //trans.io_mosi_s = i_spi.io_mosi_s;
        @(posedge i_spi.clk);
        mon2scb.put(trans);
      end else begin
        @(posedge i_spi.clk);
        wait (!i_spi.SS);
        trans.i_data_p = i_spi.i_data_p;
        for (int i = 0; i < 8; i++) begin
          @(posedge i_spi.SCK) trans.io_miso_s[i] = i_spi.io_miso_s;
          @(negedge i_spi.SCK) trans.io_mosi_s[i] = i_spi.io_mosi_s;
        end
        wait (i_spi.SS);
        @(posedge i_spi.clk);
        trans.o_data_p = i_spi.o_data_p;
        //trans.io_mosi_s = i_spi.io_mosi_s;
        @(posedge i_spi.clk);
        mon2scb.put(trans);
      end

    end


  endtask

endclass

