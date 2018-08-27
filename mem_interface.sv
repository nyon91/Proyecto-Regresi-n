//-------------------------------------------------------------------------
//						mem_interface - www.verificationguide.com
//-------------------------------------------------------------------------

interface mem_if(input logic txclk,reset);
  
  //---------------------------------------
  //declaring the signals
  //---------------------------------------
 
  logic enable_RX;
  logic enable_TX;
  
  //TX
  logic ld_tx_data;
  logic [7:0] tx_data;
  logic tx_out;
  logic tx_empty;
  
  //RX

  logic rd_uart_R;
  logic uart_REC_dataH;
  logic pndng_R;
  logic [7:0] rx_out;
  logic rx_empty;
    
  
  //---------------------------------------
  //driver clocking block
  //---------------------------------------
  clocking driver_cb @(posedge txclk);
    default input #1 output #1;
    //TX
    output ld_tx_data;
    output tx_data;
    input tx_empty;
    input tx_out;
    //RX
    output rd_uart_R;
    output uart_REC_dataH;
    input rx_out;
    input rx_empty;
    input pndng_R;
  endclocking
  
  //---------------------------------------
  //monitor clocking block
  //---------------------------------------
  clocking monitor_cb @(posedge txclk);
    default input #1 output #1;
    
    input enable_RX;
    input enable_TX;
    //TX
	input ld_tx_data;
    input tx_data;
    input tx_empty;
    input tx_out; 
    //RX
    input rd_uart_R;
    input uart_REC_dataH;
    input rx_empty;
    input rx_out;
    input pndng_R;
  endclocking
  
  //---------------------------------------
  //driver modport
  //---------------------------------------
  modport DRIVER  (clocking driver_cb,input txclk,reset);
  
  //---------------------------------------
  //monitor modport  
  //---------------------------------------
  modport MONITOR (clocking monitor_cb,input txclk,reset);
  
    covergroup UART @ (negedge txclk);
      
      Dato_1: coverpoint tx_data
      {
        bins DATA[256] = {[8'h00:8'hff]};
      }
    
      Carga : coverpoint ld_tx_data
      {
        bins load_TX[2] = {0,1}; 
      }
      
      Resultado :  cross Dato_1,Carga;
      
      Carga_RX : coverpoint rd_uart_R
      {
        bins load_RX[2] = {0,1}; 
      }
      
      Resultado_RX :  cross Dato_1,Carga_RX;
      
     endgroup
    
    UART uart=new(); 
      
endinterface