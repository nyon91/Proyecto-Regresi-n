//-------------------------------------------------------------------------
//						mem_seq_item - www.verificationguide.com 
//-------------------------------------------------------------------------

class mem_seq_item extends uvm_sequence_item;
  //---------------------------------------
  //data and control fields
  //---------------------------------------
  
    int enable_TX;
  	int enable_RX;
  
  	//TX
	//bit        reset = 1;
  
    rand bit   ld_tx_data; //Se le indica a FIFO TX que recibe dato
    rand bit  [7:0] tx_data; //SE crea dato TX
    bit        tx_out;
    bit        tx_empty;
        
    //Rx
  	
  	rand bit rd_uart_R = 0; //se genera dato RX
  	rand bit uart_REC_dataH = 0;////se solicita dato a FIFO RX
  bit [7:0] rx_out;
    bit rx_empty;
    bit pndng_R;
  
  	constraint c_addr { uart_REC_dataH >= 0; uart_REC_dataH < 2; }
  	
  
  //---------------------------------------
  //Utility and Field macros
  //---------------------------------------
  `uvm_object_utils_begin(mem_seq_item)
  
  `uvm_field_int(enable_RX,UVM_ALL_ON)
  `uvm_field_int(enable_TX,UVM_ALL_ON)

  `uvm_field_int(tx_data,UVM_ALL_ON)
  `uvm_field_int(ld_tx_data,UVM_ALL_ON)
  
  `uvm_field_int(rd_uart_R,UVM_ALL_ON)
  `uvm_field_int(uart_REC_dataH,UVM_ALL_ON)
  
  `uvm_object_utils_end
  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "mem_seq_item");
    super.new(name);
  endfunction
  
  //---------------------------------------
  //constaint, genera si escribo o leo
  //---------------------------------------
  //constraint wr_rd_c { tx_enable != rx_enable; }; 
  
 
endclass