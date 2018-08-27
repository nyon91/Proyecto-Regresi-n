//-------------------------------------------------------------------------
//				www.verificationguide.com   testbench.sv
//-------------------------------------------------------------------------
//---------------------------------------------------------------
//including interfcae and testcase files
`include "mem_interface.sv"
`include "mem_base_test.sv"
`include "mem_wr_rd_test.sv"
//---------------------------------------------------------------



module tbench_top;

  //---------------------------------------
  //clock and reset signal declaration
  //---------------------------------------
  
  bit txclk;
  bit reset;
  
  //---------------------------------------
  //clock generation
  //---------------------------------------
  always #5 txclk = ~txclk;
  
  //---------------------------------------
  //reset Generation
  //---------------------------------------
  initial begin
    reset = 0;
    #5 reset =1;
    #5 reset =0;
    #5 reset =1;
    #5 reset =0;
  end
  
  //---------------------------------------
  //interface instance
  //---------------------------------------
  mem_if intf(txclk,reset);
  
  //---------------------------------------
  //DUT instance
  //---------------------------------------
  uart DUT (
    .sys_clk(intf.txclk),
    .sys_rst_l(intf.reset),
    //TX
    .push_T(intf.ld_tx_data),
    .Din(intf.tx_data),
    .uart_XMIT_dataH(intf.tx_out),
    .tx_full(intf.tx_empty),
    //RX
    .pop_R(intf.rd_uart_R),
    .uart_REC_dataH(intf.uart_REC_dataH),
    .rx_full(intf.rx_empty),
    .pndng_R(intf.pndng_R),
    .Dout(intf.rx_out)
   );
  
  //---------------------------------------
  //passing the interface handle to lower heirarchy using set method 
  //and enabling the wave dump
  //---------------------------------------
  initial begin 
    uvm_config_db#(virtual mem_if)::set(uvm_root::get(),"*","vif",intf);
    //enable wave dump
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
  
  //---------------------------------------
  //calling test
  //---------------------------------------
  initial begin 
    run_test();
  end
  
endmodule