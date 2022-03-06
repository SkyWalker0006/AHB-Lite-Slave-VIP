//Samples the interface signals, captures into transaction packet and sends the packet to scoreboard.
`define MONITOR_cb vif.monitor.cb_monitor
class monitor;
  //creating virtual interface handle
  virtual dut_if vif;
  
  //creating mailbox handle
  mailbox mon2scb;
  
  //constructor
  function new(virtual dut_if vif,mailbox mon2scb);
    //getting the interface
    this.vif = vif;
    //getting the mailbox handles from  environment 
    this.mon2scb = mon2scb;
  endfunction
  
  //Samples the interface signal and send the sample packet to scoreboard
  task main;
    @(posedge vif.monitor.hclk);
    forever begin
      transaction trans;
      trans = new();
        trans.hsel  = `MONITOR_cb.hsel;
        trans.haddr = `MONITOR_cb.haddr;
        trans.htrans= `MONITOR_cb.htrans;
        trans.hwrite= `MONITOR_cb.hwrite;
        trans.hsize = `MONITOR_cb.hsize;
        trans.hburst= `MONITOR_cb.hburst;
        trans.hprot = `MONITOR_cb.hprot;
        trans.error = `MONITOR_cb.error;
        trans.hwdata= `MONITOR_cb.hwdata;
      @(`MONITOR_cb);
        trans.hwdata = `MONITOR_cb.hwdata;
	 	trans.hrdata = `MONITOR_cb.hrdata;
      	trans.hready = `MONITOR_cb.hready;
      	trans.hresp  = `MONITOR_cb.hresp; 
        mon2scb.put(trans);
//         $display($time," MON:: Transaction : %p",trans);
    end
  endtask

endclass
