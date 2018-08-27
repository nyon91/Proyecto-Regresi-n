//-------------------------------------------------------------------------
//						mem_monitor - www.verificationguide.com 
//-------------------------------------------------------------------------

class mem_monitor extends uvm_monitor;

  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual mem_if vif;
  realtime cov1, cov2, cov3;

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(mem_seq_item) item_collected_port;
  
  //---------------------------------------
  // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods).
  //---------------------------------------
  mem_seq_item trans_collected;

  `uvm_component_utils(mem_monitor)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    item_collected_port = new("item_collected_port", this);
  endfunction : new

  //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual mem_if)::get(this, "", "vif", vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase
  
  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    int i = 0;
    int o = 0;
    
    forever begin
      
      @(posedge vif.MONITOR.txclk);
      
      trans_collected.enable_RX = vif.monitor_cb.enable_RX;
      trans_collected.enable_TX = vif.monitor_cb.enable_TX;
      
      //TX IN
      trans_collected.tx_data = vif.monitor_cb.tx_data;
      trans_collected.ld_tx_data = vif.monitor_cb.ld_tx_data;
      
      //RX IN
      trans_collected.rd_uart_R = vif.monitor_cb.rd_uart_R;
      trans_collected.uart_REC_dataH = vif.monitor_cb.uart_REC_dataH;
      
      @(negedge vif.MONITOR.txclk);
      
      //TX OUT
      
      trans_collected.tx_out = vif.monitor_cb.tx_out;
      trans_collected.tx_empty = vif.monitor_cb.tx_empty;
      
      //RX OUT
      
      trans_collected.rx_out = vif.monitor_cb.rx_out;
      trans_collected.rx_empty = vif.monitor_cb.rx_empty;
      trans_collected.pndng_R = vif.monitor_cb.pndng_R;
      
      
      item_collected_port.write(trans_collected);
      
      i++;
      
      if(i>500) begin
      	o++;
      $display("Intento :  %0d",o);
        cov1=vif.uart.Dato_1.get_coverage();
        
      $display("Coverage TX_DATA :  %0f",cov1);
        cov2=vif.uart.Resultado.get_coverage();
        
      $display("Coverage Cruzado TX:  %0f",cov2);
        cov3=vif.uart.Resultado_RX.get_coverage();
        
      $display("Coverage RX :  %0f",cov3);
        
        i = 0;
        
      end 
      
      end 
  endtask : run_phase

endclass : mem_monitor
