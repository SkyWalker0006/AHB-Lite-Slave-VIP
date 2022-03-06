//Gets the packet from generator and drive the transaction packet items into interface (interface is connected to DUT, so the items driven into interface signal will get driven in to DUT) 
`define MASTER_cb vif.master.cb_master
class driver;
    //used to count t,ihe number of transactions
  int no_transactions;
  int no_wr,idle_busy;
  transaction trans;
  //creating virtual interface handle
  virtual dut_if vif;
  
  //creating mailbox handle
  mailbox gen2driv;
  
  //constructor
  function new(virtual dut_if vif,mailbox gen2driv);
    //getting the interface
    this.vif = vif;
    //getting the mailbox handles from  environment 
    this.gen2driv = gen2driv;
  endfunction
  
  //Reset task, Reset the Interface signals to default/initial values
  task reset;
    wait(!vif.hresetn);
    $display("--------- [DRIVER] Reset Started ---------");
        `MASTER_cb.haddr       <= 0;
        `MASTER_cb.hburst      <= 0;
        `MASTER_cb.hmastlock   <= 0;
        `MASTER_cb.hprot       <= 4'b0001;
        `MASTER_cb.hsize       <= 3'b010;
        `MASTER_cb.htrans      <= 2'b00;
        `MASTER_cb.hwdata      <= 0;
        `MASTER_cb.hwrite      <= 0;
        `MASTER_cb.hsel        <= 1'b1; 
    wait(vif.hresetn);
    $display("--------- [DRIVER] Reset Ended ---------");
  endtask
  
  //drive packets
  task drive();
    transaction trans;
    gen2driv.get(trans);
//     trans.hwrite=~trans.hwrite;
      `MASTER_cb.hsel  <= trans.hsel;
      `MASTER_cb.haddr <= trans.haddr;
      `MASTER_cb.htrans<= trans.htrans;
      `MASTER_cb.hwrite<= trans.hwrite;
      `MASTER_cb.hsize <= trans.hsize;
      `MASTER_cb.hburst<= trans.hburst;
      `MASTER_cb.hprot <= trans.hprot;
      `MASTER_cb.error <= trans.error;
      `MASTER_cb.htrans<= trans.htrans;
      `MASTER_cb.haddr <= trans.haddr;
    @(`MASTER_cb);
      `MASTER_cb.hwdata<= trans.hwdata;
     
//     $display("%d:\t-----------------------------------------",no_transactions);
//     $display($time," DRV:: Transaction : %p",trans);
    no_transactions++;
    if(trans.htrans=='b0 || trans.htrans=='b1)
      begin
        idle_busy++;
      end
    if(trans.hwrite=='b1 && (trans.htrans=='b010 || trans.htrans=='b011))
      begin
        no_wr++;
      end
  endtask 
  
   //main methods
  task main;
      fork
        //Waiting for reset
        begin
          wait(!vif.hresetn);
        end
        //Calling drive task
        begin
          forever
            drive();
        end
      join_any
      disable fork;
  endtask
        
endclass
