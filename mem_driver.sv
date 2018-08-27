//-------------------------------------------------------------------------
//						mem_driver - www.verificationguide.com
//-------------------------------------------------------------------------

`define DRIV_IF vif.DRIVER.driver_cb

class mem_driver extends uvm_driver #(mem_seq_item);

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual mem_if vif;
  `uvm_component_utils(mem_driver)
    
  //--------------------------------------- 
  // Constructor
  //--------------------------------------- 
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //--------------------------------------- 
  // build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     if(!uvm_config_db#(virtual mem_if)::get(this, "", "vif", vif))
       `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  //---------------------------------------  
  // run phase
  //---------------------------------------  
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      seq_item_port.item_done();
    end
  endtask : run_phase
  
  //---------------------------------------
  // drive - transaction level to signal level
  // drives the value's from seq_item to interface signals
  //---------------------------------------
  virtual task drive();
    
    
    //TX
    `DRIV_IF.tx_data <= req.tx_data;
    `DRIV_IF.ld_tx_data <= req.ld_tx_data;
    
    //RX
    `DRIV_IF.rd_uart_R <= req.rd_uart_R;
    `DRIV_IF.uart_REC_dataH <= req.uart_REC_dataH;
    
    @(posedge vif.DRIVER.txclk);
    
    //TX
    
    req.tx_empty = `DRIV_IF.tx_empty;
  	req.tx_out = `DRIV_IF.tx_out;
    
    //RX
    req.rx_empty = `DRIV_IF.rx_empty;
  	req.rx_out = `DRIV_IF.rx_out;
    req.pndng_R = `DRIV_IF.pndng_R;
    
    
  endtask : drive
endclass : mem_driver