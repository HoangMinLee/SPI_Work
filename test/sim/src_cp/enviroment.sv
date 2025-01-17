`include "/home/DN02/SPI_Work/SPI/test/sim/src_cp/transaction.sv"
`include "/home/DN02/SPI_Work/SPI/test/sim/src_cp/generator.sv"
`include "/home/DN02/SPI_Work/SPI/test/sim/src_cp/driver.sv"
`include "/home/DN02/SPI_Work/SPI/test/sim/src_cp/scoreboard.sv"
`include "/home/DN02/SPI_Work/SPI/test/sim/src_cp/monitor.sv"

class enviroment;

    generator gen;
    driver driv;
    monitor mon;
    scoreboard scb;

    mailbox gen2driv;
    mailbox mon2scb;
    //mailbox gen2score;

    virtual itf_spi_env i_spi;
    event gen_ended;

    function new(virtual itf_spi_env i_spi);

        this.i_spi = i_spi;
        gen2driv = new();
        mon2scb = new();

        gen = new(gen2driv, gen_ended);
        driv = new(i_spi, gen2driv);
        mon = new(i_spi, mon2scb);
        scb = new(mon2scb);

    endfunction
    task pre_test;
        driv.reset();
    endtask

    task test();
        fork
            gen.main();
            driv.main();
            mon.main();
            scb.main();
        join_any
    endtask

    task post_test;
        wait(gen_ended.triggered);
        wait(gen.repeat_count == driv.no_transaction);
        wait(gen.repeat_count == scb.no_transaction);
    endtask
    
    task run;
        pre_test();
        test();
        post_test();
        $finish;
    endtask


endclass
