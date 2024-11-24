`include "/home/minhuyenhwe/spi_protocol/test/sim/src/transaction.sv"
class monitor;
    virtual itf_spi_env i_spi;

    mailbox mon2scb;
    function new( virtual itf_spi_env i_spi, mailbox mon2scb );
        this.i_spi = i_spi;
        this.mon2scb = mon2scb;


    endfunction
task main;
    forever begin
        transaction trans;
        trans = new();
        @(posedge i_spi.clk);
        wait(i_spi.trans_en);
        trans.i_data_m = i_spi.i_data_m;
        trans.i_data_s = i_spi.i_data_s;
        wait(!i_spi.trans_en);
        @(posedge i_spi.clk);
        trans.o_data_m = i_spi.o_data_m;
        trans.o_data_s = i_spi.o_data_s;
        @(posedge i_spi.clk);
        mon2scb.put(trans);

    end


endtask


endclass
