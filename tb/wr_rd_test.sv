//test case for alternate read/write transactions using the pre_randomize method
`include "environment.sv"
program test(dut_if ahb_if);
  
  class my_trans extends transaction;
    
    bit [1:0] count;
    
    function void pre_randomize();
      hwrite.rand_mode(0);
      haddr.rand_mode(0);
      htrans.rand_mode(0);
      if(count %2 == 0) begin
         hwrite = 1;
         haddr  = count;      
      end 
      else begin
        hwrite = 0;
        haddr  = count;
        count++;
      end
      count++;
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
    env.gen.repeat_count = 200;
    
    env.gen.trans = my_tr;
    
    //calling run of env
    env.run();
  end
endprogram