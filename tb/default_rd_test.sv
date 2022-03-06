//test case for all read transactions using pre_randomize method for checking reset state of design memory
`include "environment.sv"
program test(dut_if ahb_if);
  
  class my_trans extends transaction;
    
    bit [1:0] cnt;
    
    function void pre_randomize();
      hwrite.rand_mode(0);
      haddr.rand_mode(0);
      hwrite = 0;
      haddr  = cnt;
      cnt++;
    endfunction
    
  endclass
    
  //declaring instances
  environment env;
  my_trans my_tr;
  
  initial begin
    //creating instances
    env = new(ahb_if);
    
    my_tr = new();
    
    //to generate N no of transactions
    env.gen.repeat_count = 10;
    
    env.gen.trans = my_tr;
    
    //calling run of env
    env.run();
  end
endprogram