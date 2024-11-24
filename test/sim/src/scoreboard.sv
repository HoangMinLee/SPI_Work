`include "/home/minhuyenhwe/spi_protocol/test/sim/src/transaction.sv"
class scoreboard;
    mailbox mon2scb;
    int no_transaction;
function new(mailbox mon2scb);
    this.mon2scb = mon2scb;


endfunction
    task main;
        transaction trans;
        forever begin
            $display("before get from scb");
            mon2scb.get(trans);
            if((trans.i_data_m != trans.o_data_s) || (trans.i_data_s != trans.o_data_m)) begin
                trans.display("FAILED");
            end
            else begin

                trans.display("PASSED");
            end
            no_transaction++;
        end

    endtask


endclass
