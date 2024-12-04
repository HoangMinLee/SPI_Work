`include "/home/DN01/SPI_Work/SPI/test/sim/src_cp/transaction.sv"
class generator;
  rand transaction trans, tr;
  int repeat_count;
  mailbox gen2driv;
 // mailbox gen2mon; //dev
  event ended;
  function new(mailbox gen2driv, event ended);
    this.gen2driv = gen2driv;
  //  this.gen2mon = gen2mon; //dev
    this.ended = ended;
    trans = new();
  endfunction

  task main();
    repeat (repeat_count) begin
      if (!trans.randomize()) begin
        $fatal("trans randomize is failed");
      end
      tr = trans.copy_data();
      gen2driv.put(tr);
   //   gen2mon.put(tr); //dev

    end
    ->ended;  //done create generator
  endtask

endclass
