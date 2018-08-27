//-------------------------------------------------------------------------
//						mem_sequence's - www.verificationguide.com
//-------------------------------------------------------------------------

//=========================================================================
// mem_sequence - random stimulus 
//=========================================================================
class mem_sequence extends uvm_sequence#(mem_seq_item);
  
  `uvm_object_utils(mem_sequence)
  
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "mem_sequence");
    super.new(name);
  endfunction
  
  `uvm_declare_p_sequencer(mem_sequencer)
  
  //---------------------------------------
  // create, randomize and send the item to driver
  //---------------------------------------
  virtual task body();
    repeat(2000) begin
    req = mem_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    send_request(req);
    wait_for_item_done();
   end 
  endtask
endclass
//=========================================================================

//=========================================================================
// tx_sequence - "tx" type
//=========================================================================
class tx_sequence extends uvm_sequence#(mem_seq_item);
  
  `uvm_object_utils(tx_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "tx_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(req,{req.enable_RX==1;})
  endtask
endclass
//=========================================================================

//=========================================================================
// rx_sequence - "rx" type
//=========================================================================
class rx_sequence extends uvm_sequence#(mem_seq_item);
  
  `uvm_object_utils(rx_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "rx_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(req,{req.enable_RX==1;})
  endtask
endclass
//=========================================================================

//=========================================================================
// tx_rx_sequence - "tx" followed by "rx" 
//=========================================================================
//class tx_rx_sequence extends uvm_sequence#(mem_seq_item);
  
//  `uvm_object_utils(tx_rx_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
//  function new(string name = "tx_rx_sequence");
//    super.new(name);
//  endfunction
  
//  virtual task body();
//    `uvm_do_with(req,{req.tx_enable==1;})
//    `uvm_do_with(req,{req.rx_enable==1;})
//  endtask
//endclass
//=========================================================================


//=========================================================================
// wr_rd_sequence - "write" followed by "read" (sequence's inside sequences)
//=========================================================================
//class tx_rx_sequence extends uvm_sequence#(mem_seq_item);
  
  //--------------------------------------- 
  //Declaring sequences
  //---------------------------------------
//  tx_sequence tx_seq;
//  rx_sequence  rx_seq;
  
//  `uvm_object_utils(tx_rx_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
//  function new(string name = "tx_rx_sequence");
//    super.new(name);
//  endfunction
  
//  virtual task body();
//    `uvm_do(tx_seq)
//    `uvm_do(rx_seq)
//  endtask
//endclass
//===================================================================//======