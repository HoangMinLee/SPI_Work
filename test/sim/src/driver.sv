`include "/home/minhuyenhwe/spi_protocol/test/sim/src/transaction.sv"
`define DRIV_ITF i_spi.DRIVER.driver_cb
class driver;
    int no_transaction;
    virtual itf_spi_env i_spi;
    mailbox gen2driv;
    function new(virtual itf_spi_env i_spi, mailbox gen2driv);
        this.i_spi = i_spi;
        this.gen2driv = gen2driv;

    endfunction
    // reset
    task reset;
        wait(i_spi.rst);
        `DRIV_ITF.i_data_m <= 8'b0;
        `DRIV_ITF.i_data_s <= 8'b0;
        `DRIV_ITF.trans_en <= 1'b0;
        wait(!i_spi.rst);

    endtask

    task driver;
        
            transaction trans;
            gen2driv.get(trans);
	        //output
            @(posedge i_spi.DRIVER.clk);
		    `DRIV_ITF.data_config_master <= trans.data_config_master;
		    `DRIV_ITF.data_config_slave <= trans.data_config_slave;
		    repeat(10) @(i_spi.DRIVER.clk);
            `DRIV_ITF.i_data_m <= trans.i_data_m;
            `DRIV_ITF.i_data_s <= trans.i_data_s;
            `DRIV_ITF.trans_en <= 1'b1;
            //input
	        repeat(100) @(posedge i_spi.DRIVER.clk);
            trans.o_data_m = `DRIV_ITF.o_data_m;
            trans.o_data_s = `DRIV_ITF.o_data_s;
            trans.interupt_request = `DRIV_ITF.interupt_request;
            repeat(10) @(posedge i_spi.DRIVER.clk);
            `DRIV_ITF.trans_en <= 1'b0;
            no_transaction++;

    endtask
    task main;
	fork
		begin
			wait(i_spi.rst);
		end
		begin
			forever	driver();
		end

	join_any
    endtask
endclass
