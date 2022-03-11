//Generates randomized transaction packets and put them in the mailbox to send the packets to driver 

class generator;
  
  //declaring transaction class 
  rand transaction trans,tr;
  
  //repeat count, to specify number of items to generate
  int  repeat_count;
  int no_transactions;
  int temp_array[*];
  
  //
  logic [`AW-1:0] addr;
    logic [2:0] size;
    logic [`AW-1:0] start_addr;
    logic [`AW-1:0] next_addr;
    logic [2:0]  burst;
    bit          wrap=0;
    bit          INCR_WRP;
    byte unsigned burst_len;
 
    int i=1;
    int j=0;
    int k=0;
  
  //mailbox, to generate and send the packet to driver
  mailbox gen2driv;
  
  //event
  event ended;
  
  //constructor
  function new(mailbox gen2driv,event ended);
    //getting the mailbox handle from env, in order to share the transaction packet between the generator and driver, the same mailbox is shared between both.
    this.gen2driv = gen2driv;
    this.ended    = ended;
    
  endfunction
  
  //main task, generates(create and randomizes) the repeat_count number of transaction packets and puts into mailbox
  
  ////////////////////////////////////////////////////////////////////////////////////////
  //                              SINGLE BUIRST                                         //
  ////////////////////////////////////////////////////////////////////////////////////////
  
  task single_burst();
    $display("\t ----------------------------------------------");
    $display("\t|  Tr#   \t|\tTransaction Data            ");
    $display("\t ----------------------------------------------");
    repeat(repeat_count) begin
    trans = new();     
    if( !trans.randomize() ) 
      $fatal("Gen:: trans randomization failed");      
    gen2driv.put(trans);
//       $display("%d GEN:: Transaction : %p",no_transactions, trans);
    no_transactions++;
    end
    -> ended; 
  endtask
  
  ////////////////////////////////////////////////////////////////////////////////////////
  //                         INCR (undefined length)                                    //
  ////////////////////////////////////////////////////////////////////////////////////////
  
  task incr_burst();
    logic [`AW-1:0] addr;
    logic [2:0] size;
    logic [`AW-1:0] start_addr;
    logic [`AW-1:0] next_addr;
    logic [2:0]  burst;
    bit          wrap=0;
    bit          INCR_WRP;
    byte unsigned burst_len;
 
    int i=1;
    int j=0;
    int k=0;
    repeat(repeat_count) begin
      trans = new();     
      if( !trans.randomize() ) 
       $fatal("Gen:: trans randomization failed");
      $cast(trans.hburst,1);
      $cast(trans.htrans,2);
      $cast(trans.hwrite,1); 
      start_addr = trans.haddr;
      temp_array[0] = trans.haddr;
        burst_len  = trans.len_burst_INCR;
        size       =  trans.hsize;
      if(i==1)
        trans.haddr=start_addr;
        else begin
          trans.haddr=next_addr;
          temp_array[0] = next_addr;
        end
       gen2driv.put(trans);
       next_addr = start_addr + i * (2 ** trans.hsize);
       i = i+1;
  
       //read
       repeat(burst_len) begin
         trans = new();     
         if( !trans.randomize() ) 
          $fatal("Gen:: trans randomization failed");
         $cast(trans.hburst,1);
         if(j==0)
           $cast(trans.htrans ,2);
         else
           $cast(trans.htrans ,3);
         $cast(trans.hwrite,0); 
         trans.haddr = temp_array[0]; 
         $cast(trans.hsize , size);
         gen2driv.put(trans);
         j = j+1;
        end
      
    end
    -> ended;
  endtask
  
  ////////////////////////////////////////////////////////////////////////////////////////
  //                       WRAP4,INCR4,WRAP8,INCR8,WRAP16,INCR16                        //
  ////////////////////////////////////////////////////////////////////////////////////////
  
  task INCR_WRAP();
    logic [`AW-1:0] addr;
    logic [2:0] size;
    logic [`AW-1:0] start_addr;
    logic [`AW-1:0] next_addr;
    logic [2:0]  burst;
    bit          wrap=0;
    bit          INCR_WRP;
    byte unsigned burst_len;
 
    int i=1;
    int j=0;
    int k=0;
    repeat(repeat_count) begin
      
      trans = new();     
      if( !trans.randomize() ) 
       $fatal("Gen:: trans randomization failed");
      $cast(trans.htrans ,2);
      $cast(trans.hwrite,1); 
      
      if(i!=1 && !wrap)
        begin
          trans.haddr=next_addr+(2 ** trans.hsize);
        end
      else if(i!=1 && wrap)
        trans.haddr=next_addr;
      temp_array[k] = trans.haddr;
      k = k+1;
      gen2driv.put(trans);
      if(i==1)
      start_addr = trans.haddr;
      burst     = trans.hburst;
      size      = trans.hsize;
      burst_len = trans.len_burst_INCR;
      
      repeat(burst_len -1) begin
        trans = new();     
        if( !trans.randomize() ) 
          $fatal("Gen:: trans randomization failed");
        if (trans.hburst inside {transaction::INCR4, transaction::INCR8, transaction::INCR16}) begin
          if (i >= burst_len)
            next_addr = start_addr + i * (2 ** trans.hsize)+(2 ** trans.hsize);
          else
            next_addr = start_addr + i * (2 ** trans.hsize);
          INCR_WRP=0;
        end
        if(trans.hburst inside {transaction::WRAP4,transaction::WRAP8,transaction::WRAP16}) begin
            byte n_hburst;
            byte wrap_bd;
            INCR_WRP=1;
          case(trans.hburst)
                transaction::WRAP4: n_hburst=4;
                transaction::WRAP8: n_hburst=8;
                transaction::WRAP16: n_hburst=16;
            endcase
            wrap_bd=n_hburst*2**trans.hsize;
            next_addr=start_addr + i * (2 ** trans.hsize);
            if(((next_addr%wrap_bd)==0) &&(next_addr!=start_addr))
              begin
              next_addr=next_addr-wrap_bd; 
                wrap=1;
              end
             else wrap=0;
        end
        temp_array[k] = next_addr;
        $cast( trans.hburst,burst); 
        $cast(trans.htrans ,3);
        $cast(trans.hwrite,1); 
        trans.haddr = next_addr; 
        $cast(trans.hsize , size); 
        gen2driv.put(trans);
         i = i+1;
         k = k+1;
        if(i==burst_len && INCR_WRP)
        i=1;

      end
       //read sequence
       repeat(burst_len) begin
         trans = new();     
         if( !trans.randomize() ) 
          $fatal("Gen:: trans randomization failed");
         $cast(trans.hburst,burst);
         $cast(trans.htrans ,3);
         $cast(trans.hwrite,0); 
         trans.haddr = temp_array[j]; 
         $cast(trans.hsize , size);
         gen2driv.put(trans);
         j = j+1;
        end
    end
    -> ended;
  endtask
  
endclass
