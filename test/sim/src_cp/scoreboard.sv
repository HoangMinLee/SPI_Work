`include "/home/DN02/SPI_Work/SPI/test/sim/src_cp/transaction.sv"
class scoreboard;
  mailbox mon2scb;
  int no_transaction;
  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
    //this.gen2score = gen2score;

  endfunction
  task main;
    transaction trans;
    forever begin
      $display("before get from scb");
      mon2scb.get(trans);
      //gen2score.get(bf_trans);
      if ((trans.i_data_p != trans.o_data_s) || (trans.i_data_s != trans.o_data_p)) begin
        trans.display("FAILED");
      end else begin

        trans.display("PASSED");
      end
      no_transaction++;
    end

  endtask


endclass
