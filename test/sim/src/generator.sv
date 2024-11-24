`include "/home/minhuyenhwe/spi_protocol/test/sim/src/transaction.sv"
class generator;
    rand transaction trans, tr;
    int repeat_count;
    mailbox gen2driv;
    event ended;
    function  new(mailbox gen2driv, event ended);
        this.gen2driv = gen2driv;
        this.ended = ended;
            trans = new(); 
    endfunction

    task main();
        repeat(repeat_count) begin
            if( !trans.randomize()) $fatal("trans randomize is failed");
            tr = trans.copy_data();
	    gen2driv.put(tr);
    		
        end
        -> ended; //done create generator

        
    endtask

endclass
