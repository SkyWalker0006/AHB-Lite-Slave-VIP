//Interface groups the design signals, specifies the direction (Modport) and Synchronize the signals(Clocking Block)

interface dut_if(input logic hclk,hresetn);

    // Add design signals here
    logic           hsel;
    logic           hwrite;
  logic [`AW -1:0] haddr;
  logic [`DW -1:0] hwdata;
  logic [`DW -1:0] hrdata;
    logic [    2:0] hsize;
    logic [    2:0] hburst;
    logic [    3:0] hprot;
    logic [    1:0] htrans;
    logic           hmastlock;
    logic           hready;
  logic [`RW-1: 0] hresp;
  logic error;
    
    //Master Clocking block - used for Drivers
  	clocking cb_master @(posedge hclk);
      output hsel;
      output haddr;
      output hwdata;
      input  hrdata;
      output hwrite;
      output hsize;
      output hburst;
      output error;
      output hprot;
      output htrans;
      output hmastlock;
      input  hready;
      input  hresp;
    endclocking
    
    //Monitor Clocking block - For sampling by monitor components
  	clocking cb_monitor @(posedge hclk);
      input  hsel;
      input  haddr;
      input  hwdata;
      input  hwrite;
      input  hsize;
      input  hburst;
      input  hprot;
      input  htrans;
      input  hmastlock;
      input  hready;
      input  hresp;
      input  hrdata;
      input  hresetn;
      input  error;
    endclocking
  
    //Add modports here
  	modport master (clocking cb_master,input hclk,hresetn);
    modport monitor (clocking cb_monitor,input hclk,hresetn);
      
endinterface
