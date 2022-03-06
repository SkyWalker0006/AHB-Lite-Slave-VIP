//Random test
`include "environment.sv"
program test(dut_if ahb_if);
  
  environment env;
  transaction my_tr;
  
  initial begin
    //creating instances
    env = new(ahb_if);
    
    my_tr = new();
    
    //to generate N no of transactions
    env.gen.repeat_count = 1500;
    env.gen.trans = my_tr;
    
    //calling run of env, it interns calls generator and driver main tasks.
    env.run();
  end

endprogram
