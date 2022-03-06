//Fields required to generate the stimulus are declared in the transaction class

class transaction;

  //declare transaction items
  typedef enum bit [1:0] {IDLE,BUSY,NONSEQ,SEQ} e_HTRANS;
  typedef enum bit [2:0] {BYTE,HALF_WORD,WORD,BITS_64,BITS_128,BITS_256,BITS_512,BITS_1024} e_HSIZE;
  typedef enum bit [2:0] {SINGLE,INCR,WRAP4,INCR4,WRAP8,INCR8,WRAP16,INCR16} e_HBURST;
  typedef enum bit       {READ,WRITE} e_HWRITE;
  
  rand     e_HTRANS  htrans;
  rand     e_HSIZE   hsize;
  rand     e_HBURST  hburst;
  rand bit hsel;     // Slave select
  rand bit [`DW-1:0] haddr;
  rand bit [`DW-1:0] hwdata;
  rand bit [3:0]     hprot;
  rand     e_HWRITE  hwrite;
  logic    [`DW-1:0] hrdata;
  bit      [`RW-1:0] hresp;
  bit                hready;
  bit                error;
  rand byte unsigned len_burst_INCR;
  
  //constraints
  
  // a. No bursts
  constraint c_burst { hburst inside{[0:7]};}

  //c. Address aligned w.r.t. Size
  /*
  size	 	|addr div by | bin addr ends in
  --------------------------------------------
  byte		|		1	 |  anything		
  halfword	|       2    |      0
  word		|		4	 |     00
  doubleword|       8    |    000
  */
  constraint c_addr { 
      hsize == `H_SIZE_16 -> haddr[0] == '0;
      hsize == `H_SIZE_32 -> haddr[1:0] == '0;
    haddr inside{[0:1023]};
      solve hsize before haddr;
    }
  
  constraint c_hwdata { 
    hwdata inside{[0:256]};
    }
  
  //d. Protection control for Data Access only
  constraint data_prot_c { hprot == 1;}
  
  // e. Transfer sizes of BYTE,HALF_WORD,WORD only
  constraint c_hsize { hsize inside {`H_SIZE_8,`H_SIZE_16,`H_SIZE_32};};
  //test
  constraint c_sel { hsel == 1;}
  //bursts
  constraint c_addr_data_q {
      if(hburst==INCR) { len_burst_INCR==1;}
        if(hburst==INCR4 || hburst==WRAP4) { len_burst_INCR==4;}
          if(hburst==INCR8 || hburst==WRAP8) { len_burst_INCR==8;} 
            if(hburst==INCR16 || hburst==WRAP16) { len_burst_INCR==16;}
        }
  //print_trans method to print the transaction item values
  function void print_trans();
    $display("hsel=%0x, haddr=%0x, htrans=%0x, hwrite=%0x, hsize=%0x, hburst=%0x, hprot=%0b, hwdata=%8x, hrdata=%8x, hready=%0x, hresp=%0x, error=%0x\n", hsel, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, hrdata, hready, hresp, error);
  endfunction
    
   
endclass