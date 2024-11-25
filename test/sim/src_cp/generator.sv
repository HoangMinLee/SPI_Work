`include "/home/DN02/SPI/test/sim/src_cp/transaction.sv"
class generator;
  rand transaction trans, tr;
  int repeat_count;
  mailbox gen2driv;
  mailbox gen2score;
  event ended;
  function new(mailbox gen2driv, event ended);
    this.gen2driv = gen2driv;
    //this.gen2score = gen2score;
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
      //gen2score.put(tr);

    end
    ->ended;  //done create generator
  endtask

endclass
