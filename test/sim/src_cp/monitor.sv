`include "/home/DN02/SPI_Work/SPI/test/sim/src_cp/transaction.sv"
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
      @(posedge i_spi.clk);
      wait (!i_spi.SS);
      trans.i_data_p = i_spi.i_data_p;
      //trans.i_data_s = i_spi.i_data_s;
      for (int i = 0; i < 8; i++) begin
        @(posedge i_spi.SCK) trans.o_data_s[i] = i_spi.o_data_s;
        @(negedge i_spi.SCK) trans.i_data_s[i] = i_spi.i_data_s;
      end
      wait (i_spi.SS);
      @(posedge i_spi.clk);
      trans.o_data_p = i_spi.o_data_p;
      //trans.o_data_s = i_spi.o_data_s;
      @(posedge i_spi.clk);
      mon2scb.put(trans);

    end


  endtask


endclass
