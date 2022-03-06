//Top most file which connets DUT, interface and the test

`include "interface.sv"

//-------------------------[NOTE]---------------------------------
//Particular testcase can be run by uncommenting, and commenting the rest
`include "random_test.sv"
// `include "default_rd_test.sv"
// `include "wr_rd_test.sv"
//----------------------------------------------------------------

module testbench_top;
    timeunit 1ns;
	timeprecision 1ns;
  //declare clock and reset signal
  logic clk;
  logic reset;
  //clock generation
  always #10 clk=~clk;
  //reset generation
  initial begin
    clk <= 0;
    reset <= 0;
    #30 reset <=1;
  end
  //interface instance, inorder to connect DUT and testcase
  dut_if intf(clk,reset);
  //testcase instance, interface handle is passed to test as an argument
  test t1 (intf);
  //DUT instance, interface signals are connected to the DUT ports
  amba_ahb_slave DUT (
    
    // AMBA AHB system signals
    .hclk(intf.hclk),
    .hresetn(intf.hresetn),
    
    // AMBA AHB decoder signal
    .hsel(intf.hsel),
    
    // AMBA AHB master signals
    .haddr(intf.haddr),
    .htrans(intf.htrans),
    .hwrite(intf.hwrite),
    .hsize(intf.hsize),
    .hburst(intf.hburst),
    .hprot(intf.hprot),
    .hwdata(intf.hwdata),
    
    // AMBA AHB slave signals
    .hrdata(intf.hrdata),
    .hready(intf.hready),
    .hresp(intf.hresp),
    
    // slave control signal
    .error ('0)
  );
  
  //enabling the wave dump
  initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
  end


  
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////				We are calculating coverage for HBURST				   	          	/////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  
  covergroup cover_burst @(posedge clk);
    option.per_instance = 1;

    coverpoint intf.hburst {
      bins SINGLE   = {0};
      bins INCR     = {1};
      bins WRAP4    = {2};
      bins INCR4    = {3};
      bins WRAP8    = {4};
      bins INCR8    = {5};
      bins WRAP16   = {6};
      bins INCR16   = {7};
    }
  endgroup
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////				We are calculating coverage for HSIZE				   	          	/////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  
  covergroup cover_size @(posedge clk);
    coverpoint intf.hsize {
      bins Byte              = {0};
      bins Halfword          = {1};
      bins Word              = {2};
    }
  endgroup

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////				We are calculating coverage for HTRANS				   	          	/////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  
  covergroup cover_trans @(posedge clk);
    option.per_instance = 1;

    coverpoint intf.htrans {
      bins trans_idle_idle   = (0 => 0);
      bins trans_idle_busy   = (0 => 1);
      bins trans_busy_nonseq = (1 => 2);
      bins trans_nonseq_seq  = (2 => 3);
      bins trans_nonseq_busy = (2 => 1);
      bins trans_nonseq_idle = (2 => 0);
      bins trans_nonseq_nonseq  = (2 => 2);
    }
  endgroup

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////				We are calculating coverage for HWDATA				   	          	/////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  
  covergroup cover_write_data @(posedge clk);
    option.per_instance = 1;
    coverpoint intf.hwdata {
      bins lowest = {[0:8]};
      bins lower[4] = {[8:16]};
      bins mid[4] = {[16:64]};
      bins high[4] = {[64:256]};
      bins misc = default;
    }
  endgroup

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////				We are calculating coverage for HADDR				   	          	/////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  
  covergroup cover_address @(posedge clk);
    option.per_instance = 1;
    coverpoint intf.haddr {
      bins zero = {[0:80]};
      bins low[4] = {[80:160]};
      bins med[4] = {[160:640]};
      bins high[4] = {[640:1023]};
      bins misc = default;
    }
  endgroup

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////				Calculating cross coverage between HADDR and HBURST			          	/////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  
  covergroup cross_cover_HBURST_HSIZE @(posedge clk);
    option.per_instance = 1;
    coverpoint intf.hburst {
      bins SINGLE   = {0};
      bins INCR     = {1};
      bins WRAP4    = {2};
      bins INCR4    = {3};
      bins WRAP8    = {4};
      bins INCR8    = {5};
      bins WRAP16   = {6};
      bins INCR16   = {7};
    }
    coverpoint intf.hsize {
      bins Byte              = {0};
      bins Halfword          = {1};
      bins Word              = {2};
    }
    cross intf.hburst, intf.hsize;
  endgroup
  cover_burst cg1;
    cover_size cg2;
    cover_trans cg3;
    cover_write_data cg4;
    cover_size cg5;
    cover_address cg6;
  cross_cover_HBURST_HSIZE cg7;
  
  initial
    begin
    cg1 =new();
    cg2 = new();
    cg3 = new();
    cg4 = new();
    cg5 = new();
    cg6 = new();
    cg7 = new();
    end
 

  
endmodule
