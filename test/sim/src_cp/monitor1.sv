`include "/home/DN01/SPI_Work/SPI/test/sim/src_cp/transaction.sv"
class monitor;
  virtual itf_spi_env i_spi;

  mailbox mon2scb;
 // mailbox gen2driv;
  //mailbox gen2mon;

  function new(virtual itf_spi_env i_spi, mailbox mon2scb);
    this.i_spi   = i_spi;
    this.mon2scb = mon2scb;
    //this.gen2mon = gen2mon;
  endfunction

  task main;
    forever begin
      transaction trans;
      trans = new();
      trans.data_config = i_spi.data_config;
      //gen2mon.get(trans);
      if (trans.data_config[28] == 1) begin
        wait (!i_spi.SS);
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
	trans.data_config = i_spi.data_config;
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
	trans.data_config = i_spi.data_config;
      end
       
      @(posedge i_spi.clk);
      mon2scb.put(trans);
      

    end


  endtask

endclass

