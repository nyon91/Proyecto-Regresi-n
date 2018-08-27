//-------------------------------------------------------------------------
//						mem_scoreboard - www.verificationguide.com 
//-------------------------------------------------------------------------

class mem_scoreboard extends uvm_scoreboard;
  
  //---------------------------------------
  // declaring pkt_qu to store the pkt's recived from monitor
  //---------------------------------------
  mem_seq_item pkt_qu[$];
  
  int XTAL_CLK = 25175000; //reloj
  //int BAUD = 2400;
  int BAUD = 20000;//valor a cambiar a UART...
  int CLK_DIV = XTAL_CLK / (BAUD * 16 * 2);
  int CW   = 9;
  int clk_div = 0;
  int baud_clk = 0; //reloj
  
  bit [7:0] Rx_Data_Out; //dato Rx out
  bit [7:0] Rx_Dato_scor_Actual;
  bit bit_RX_paridad;
  int Rx_count_scor =1;
  int Rx_enable_scor=1;
  int Rx_count_dato_Env=0;
  bit [7:0] Rx_Dato_scor_0; //datos RX
  bit [7:0] Rx_Dato_scor_1; //datos RX
  bit [7:0] Rx_Dato_scor_2; //datos RX
  bit [7:0] Rx_Dato_scor_3; //datos RX
  bit [7:0] Rx_Dato_scor_4; //datos RX
  bit [7:0] Rx_Dato_scor_5; //datos RX
  bit [7:0] Rx_Dato_scor_6; //datos RX
  bit [7:0] Rx_Dato_scor_7; //datos RX
  
  int Rx_flag_scor_0; //datos RX
  int Rx_flag_scor_1; //datos RX
  int Rx_flag_scor_2; //datos RX
  int Rx_flag_scor_3; //datos RX
  int Rx_flag_scor_4; //datos RX
  int Rx_flag_scor_5; //datos RX
  int Rx_flag_scor_6; //datos RX
  int Rx_flag_scor_7; //datos RX
  int Rx_count_FIFO = 0;
  int rx_new_data = 0;
  int RX_DATA_ON = 0;
  int RX_FULL = 0;
  
  
  
  bit [7:0] Tx_Dato_scor_0; //datos TX
  bit [7:0] Tx_Dato_scor_1; //datos TX
  bit [7:0] Tx_Dato_scor_2; //datos TX
  bit [7:0] Tx_Dato_scor_3; //datos TX
  bit [7:0] Tx_Dato_scor_4; //datos TX
  bit [7:0] Tx_Dato_scor_5; //datos TX
  bit [7:0] Tx_Dato_scor_6; //datos TX
  bit [7:0] Tx_Dato_scor_7; //datos TX
  bit [7:0] Tx_Dato_scor_Actual; //datos TX
  
  bit reset_scor; //reset
  bit ld_tx_scor; //indica que cargue dato a la FIFO
  
  int tx_new_data = 1; //indica nuevo dato a la FIFO   
  int tx_empty_scor = 1; //indica que no tengo dato en FIFO
  int tx_enable_scor = 1; //habilita TX
  int tx_contador = 1; // cuenta los ciclos de reloj para TX
  int tx_count_FIFO = 0; //cuenta para llebar la FIFO
  int tx_count_dato_Actual = 0; //cuenta porque volor de la FIFO va
  int FIFO_FT = 1; //llena la FIFO al inicializarse sistema
  int FIFO_DATA = 0; //la FIFO contiene DATO
  
  int tx_out_scor = 1; // salida TX
  bit bit_paridad; // indica cual es el bit de paridad
  int tx_full = 0; // indica que el dato fue enviado 

  //---------------------------------------
  //port to recive packets from monitor
  //---------------------------------------
  uvm_analysis_imp#(mem_seq_item, mem_scoreboard) item_collected_export;
  `uvm_component_utils(mem_scoreboard)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  //---------------------------------------
  // build_phase - create port and initialize local memory
  //---------------------------------------
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      item_collected_export = new("item_collected_export", this);
    //foreach(Dato[i]) Dato[i] = 1'hFF;
  endfunction: build_phase
  
  //---------------------------------------
  // write task - recives the pkt from monitor and pushes into queue
  //---------------------------------------
  virtual function void write(mem_seq_item pkt);
    //pkt.print();
    pkt_qu.push_back(pkt);
  endfunction : write

  //---------------------------------------
  // run_phase - compare's the read data with the expected data(stored in local memory)
  // local memory will be updated on the write operation.
  //---------------------------------------
  
  virtual task run_phase(uvm_phase phase);
    
    mem_seq_item mem_pkt;
    
    forever begin
      
      wait(pkt_qu.size() > 0);
           
      mem_pkt = pkt_qu.pop_front();
      
      
      if (clk_div == CLK_DIV) begin
      	
        clk_div  = 0;    
    	baud_clk = !baud_clk;
      
        
      	
      if (baud_clk == 1 ) begin //condición de reloj
          
          
      ld_tx_scor = mem_pkt.ld_tx_data; //Ld tx del secuenciador pasa al modelo de referencia
     
      //Parte RX
      
        if (rx_new_data == 1 && RX_FULL == 0) begin //cargo dato cuando Tx data es uno
        
      //Llenamos la FIFO RX
        
        if (Rx_count_FIFO == 8) begin
              Rx_count_FIFO =0;
        end
        
        
        if (Rx_count_FIFO == 0) begin
          	  Rx_Dato_scor_0 = Rx_Dato_scor_Actual;
          	  Rx_flag_scor_0 = 1;
          //`uvm_info(get_type_name(),$sformatf("Dato FIFO 0: %0h",Rx_Dato_scor_0 ),UVM_LOW)
       	end
        
        else if (Rx_count_FIFO == 1) begin
          	  Rx_Dato_scor_1 = Rx_Dato_scor_Actual;
          	  Rx_flag_scor_1 = 1;
          //`uvm_info(get_type_name(),$sformatf("Dato FIFO 1: %0h",Rx_Dato_scor_1 ),UVM_LOW)
       	end
        
        else if (Rx_count_FIFO == 2) begin
          	  Rx_Dato_scor_2 = Rx_Dato_scor_Actual;
              Rx_flag_scor_2 = 1;
          //`uvm_info(get_type_name(),$sformatf("Dato FIFO 2: %0h",Rx_Dato_scor_2 ),UVM_LOW)
       	end
        
        else if (Rx_count_FIFO == 3) begin
          	  Rx_Dato_scor_3 = Rx_Dato_scor_Actual;
              Rx_flag_scor_3 = 1;
          //`uvm_info(get_type_name(),$sformatf("Dato FIFO 3: %0h",Rx_Dato_scor_3 ),UVM_LOW)
       	end
        
        else if (Rx_count_FIFO == 4) begin
          	  Rx_Dato_scor_4 = Rx_Dato_scor_Actual;
              Rx_flag_scor_4 = 1;
          //`uvm_info(get_type_name(),$sformatf("Dato FIFO 4: %0h",Rx_Dato_scor_4 ),UVM_LOW)
       	end
        
        else if (Rx_count_FIFO == 5) begin
          	  Rx_Dato_scor_5 = Rx_Dato_scor_Actual;
              Rx_flag_scor_5 = 1;
          //`uvm_info(get_type_name(),$sformatf("Dato FIFO 5: %0h",Rx_Dato_scor_5 ),UVM_LOW)
       	end
        
        else if (Rx_count_FIFO == 6) begin
          	  Rx_Dato_scor_6 = Rx_Dato_scor_Actual;
              Rx_flag_scor_6 = 1;
          //`uvm_info(get_type_name(),$sformatf("Dato FIFO 6: %0h",Rx_Dato_scor_6 ),UVM_LOW)
       	end
        
        else if (Rx_count_FIFO == 7) begin
          	  Rx_Dato_scor_7 = Rx_Dato_scor_Actual;
              Rx_flag_scor_7 = 1;
          //`uvm_info(get_type_name(),$sformatf("Dato FIFO 7: %0h",Rx_Dato_scor_7 ),UVM_LOW)
       	end
        
        if (Rx_flag_scor_0 == 1 && Rx_flag_scor_1 == 1 && Rx_flag_scor_2 == 1 && Rx_flag_scor_3 == 1 && Rx_flag_scor_4 == 1 && Rx_flag_scor_5 == 1 && Rx_flag_scor_6 == 1 && Rx_flag_scor_7 == 1) begin
    	RX_FULL = 1;
       	end  
          
       	Rx_count_FIFO = Rx_count_FIFO + 1;
        
      end  //finaliza la FIFO
      
      //Leo dato FIFO RX
      
      if (mem_pkt.rd_uart_R == 1) begin
        
        RX_FULL = 0;
        
        if (Rx_count_dato_Env == 8) begin  
          	Rx_count_dato_Env = 0; //coloco dato
        end
        
        if (Rx_count_dato_Env == 0 && Rx_flag_scor_0 == 1) begin  
          	Rx_Data_Out = Tx_Dato_scor_0; //coloco dato
          	Rx_flag_scor_0 = 0;
          Rx_count_dato_Env = Rx_count_dato_Env + 1;
        end
         	
        else if (Rx_count_dato_Env == 1 && Rx_flag_scor_1 == 1) begin  
            Rx_Data_Out = Tx_Dato_scor_1; //coloco dato	
            Rx_flag_scor_1 = 0;
          Rx_count_dato_Env = Rx_count_dato_Env + 1;
        end
         
        else if (Rx_count_dato_Env == 2 && Rx_flag_scor_2 == 1) begin  
          	Rx_Data_Out = Tx_Dato_scor_2; //coloco dato
            Rx_flag_scor_2 = 0;
          Rx_count_dato_Env = Rx_count_dato_Env + 1;
        end
         
        else if (Rx_count_dato_Env == 3 && Rx_flag_scor_3 == 1) begin    
          	Rx_Data_Out = Tx_Dato_scor_3; //coloco dato
			Rx_flag_scor_3 = 0;
          Rx_count_dato_Env = Rx_count_dato_Env + 1;
        end
        
        else if (Rx_count_dato_Env == 4 && Rx_flag_scor_4 == 1) begin    
          	Rx_Data_Out = Tx_Dato_scor_4; //coloco dato
			Rx_flag_scor_4 = 0;
          Rx_count_dato_Env = Rx_count_dato_Env + 1;
        end
        
        else if (Rx_count_dato_Env == 5 && Rx_flag_scor_5 == 1) begin    
          	Rx_Data_Out = Tx_Dato_scor_5; //coloco dato
			Rx_flag_scor_5 = 0;
          Rx_count_dato_Env = Rx_count_dato_Env + 1;
        end
        
        else if (Rx_count_dato_Env == 6 && Rx_flag_scor_6 == 1) begin    
          	Rx_Data_Out = Tx_Dato_scor_6; //coloco dato
			Rx_flag_scor_6 = 0;
          Rx_count_dato_Env = Rx_count_dato_Env + 1;
        end
        
        else if (Rx_count_dato_Env == 7 && Rx_flag_scor_7 == 1) begin    
          	Rx_Data_Out = Tx_Dato_scor_7; //coloco dato
			Rx_flag_scor_7 = 0;
          Rx_count_dato_Env = Rx_count_dato_Env + 1;
        end
         
      end //finaliza envio datos RX
      
      
      
      //Iniciamos la FIFO
      
      if (ld_tx_scor) begin //cargo dato cuando Tx data es uno
       //`uvm_info(get_type_name(),$sformatf("Dato FIFO: %0h",mem_pkt.ld_tx_data),UVM_LOW)
       //Llenamos la FIFO
        
        	if (FIFO_FT == 0 && tx_new_data ==1) begin //recargo la FIFO
      
              	if (tx_count_FIFO == 8) begin
            		tx_count_FIFO = 0;         			
          		end
              
              	if (tx_count_FIFO == 0) begin
            		//`uvm_info(get_type_name(),$sformatf("Dato FIFO: %0h",mem_pkt.tx_data),UVM_LOW)
          			Tx_Dato_scor_0 = mem_pkt.tx_data;
                  //`uvm_error(get_type_name(),"Memoria 0")
          		end
          
              	else if (tx_count_FIFO == 1) begin
            		//`uvm_info(get_type_name(),$sformatf("Dato FIFO: %0h",mem_pkt.tx_data),UVM_LOW)
          			Tx_Dato_scor_1 = mem_pkt.tx_data;
                  //`uvm_error(get_type_name(),"Memoria 1")
          		end
          
              	else if (tx_count_FIFO == 2) begin
            		//`uvm_info(get_type_name(),$sformatf("Dato FIFO: %0h",mem_pkt.tx_data),UVM_LOW)
          			Tx_Dato_scor_2 = mem_pkt.tx_data;
                  //`uvm_error(get_type_name(),"Memoria 2")
          		end
              
              	else if (tx_count_FIFO == 3) begin
            		//`uvm_info(get_type_name(),$sformatf("Dato FIFO: %0h",mem_pkt.tx_data),UVM_LOW)
          			Tx_Dato_scor_3 = mem_pkt.tx_data;
                  //`uvm_error(get_type_name(),"Memoria 3")
          		end
              
              
              	else if (tx_count_FIFO == 4) begin
            		//`uvm_info(get_type_name(),$sformatf("Dato FIFO: %0h",mem_pkt.tx_data),UVM_LOW)
          			Tx_Dato_scor_4 = mem_pkt.tx_data;
                  //`uvm_error(get_type_name(),"Memoria 3")
          		end
              
              	else if (tx_count_FIFO == 5) begin
            		//`uvm_info(get_type_name(),$sformatf("Dato FIFO: %0h",mem_pkt.tx_data),UVM_LOW)
          			Tx_Dato_scor_5 = mem_pkt.tx_data;
                  //`uvm_error(get_type_name(),"Memoria 3")
          		end
              
              	else if (tx_count_FIFO == 6) begin
            		//`uvm_info(get_type_name(),$sformatf("Dato FIFO: %0h",mem_pkt.tx_data),UVM_LOW)
          			Tx_Dato_scor_6 = mem_pkt.tx_data;
                  //`uvm_error(get_type_name(),"Memoria 3")
          		end
              
              	else if (tx_count_FIFO == 7) begin
            		//`uvm_info(get_type_name(),$sformatf("Dato FIFO: %0h",mem_pkt.tx_data),UVM_LOW)
          			Tx_Dato_scor_7 = mem_pkt.tx_data;
                  //`uvm_error(get_type_name(),"Memoria 3")
          		end
              
              	tx_count_FIFO = tx_count_FIFO + 1;
              
        	end
        
        	else if (tx_count_FIFO == 0 && FIFO_FT == 1) begin
            	//`uvm_info(get_type_name(),$sformatf("Dato FIFO: %0h",mem_pkt.tx_data),UVM_LOW)
          		Tx_Dato_scor_0 = mem_pkt.tx_data;
        	end
        
        	else if (tx_count_FIFO == 1 && FIFO_FT == 1) begin
                //`uvm_info(get_type_name(),$sformatf("Dato FIFO: %0h",mem_pkt.tx_data),UVM_LOW)
          		Tx_Dato_scor_1 = mem_pkt.tx_data;
        	end
        
        	else if (tx_count_FIFO == 2 && FIFO_FT == 1) begin
            	//`uvm_info(get_type_name(),$sformatf("Dato FIFO: %0h",mem_pkt.tx_data),UVM_LOW)
          		Tx_Dato_scor_2 = mem_pkt.tx_data;              	
        	end
        
        	else if (tx_count_FIFO == 3 && FIFO_FT == 1) begin
            	//`uvm_info(get_type_name(),$sformatf("Dato FIFO: %0h",mem_pkt.tx_data),UVM_LOW)
          		Tx_Dato_scor_3 = mem_pkt.tx_data;
        	end
        
        	else if (tx_count_FIFO == 4 && FIFO_FT == 1) begin
            	//`uvm_info(get_type_name(),$sformatf("Dato FIFO: %0h",mem_pkt.tx_data),UVM_LOW)
          		Tx_Dato_scor_4 = mem_pkt.tx_data;
        	end
        
        	else if (tx_count_FIFO == 5 && FIFO_FT == 1) begin
            	//`uvm_info(get_type_name(),$sformatf("Dato FIFO: %0h",mem_pkt.tx_data),UVM_LOW)
          		Tx_Dato_scor_5 = mem_pkt.tx_data;
        	end
        
        	else if (tx_count_FIFO == 6 && FIFO_FT == 1) begin
            	//`uvm_info(get_type_name(),$sformatf("Dato FIFO: %0h",mem_pkt.tx_data),UVM_LOW)
          		Tx_Dato_scor_6 = mem_pkt.tx_data;
        	end
        
        	else if (tx_count_FIFO == 7 && FIFO_FT == 1) begin
            	//`uvm_info(get_type_name(),$sformatf("Dato FIFO: %0h",mem_pkt.tx_data),UVM_LOW)
          		Tx_Dato_scor_7 = mem_pkt.tx_data;
        	end
        
        	if (FIFO_FT == 1) begin
        	  	tx_count_FIFO = tx_count_FIFO + 1;
              if (tx_count_FIFO == 8) begin
                FIFO_FT = 0;
                tx_count_FIFO =0;
              end  
          	end
        
       	end  //finaliza la FIFO
      
      
      if (tx_new_data ==1) begin
        	tx_empty_scor = 0;
        	
        	if (tx_count_dato_Actual == 0 && ((tx_count_FIFO > 0 && FIFO_FT == 1) || (tx_count_FIFO > 0 && FIFO_FT == 0))) begin  
          		Tx_Dato_scor_Actual = Tx_Dato_scor_0; //coloco dato
          		bit_paridad = ^Tx_Dato_scor_0; //calculo bit de paridad
            	tx_new_data = 0;
            	tx_count_dato_Actual = 1;
              	FIFO_DATA =0;
                //`uvm_error(get_type_name(),"Dato 0")
         	end
         	
        	else if (tx_count_dato_Actual == 1 && ((tx_count_FIFO > 1 && FIFO_FT == 1) || (tx_count_FIFO <= 1 && FIFO_FT == 0))) begin  
              
          		Tx_Dato_scor_Actual = Tx_Dato_scor_1; //coloco dato
          		bit_paridad = ^Tx_Dato_scor_1; //calculo bit de paridad
            	tx_new_data = 0;
            	tx_count_dato_Actual = 2;
              	FIFO_DATA =0;
                //`uvm_error(get_type_name(),"Dato 1")
              
         	end
         
        	else if (tx_count_dato_Actual == 2 && ((tx_count_FIFO > 2 && FIFO_FT == 1) || (tx_count_FIFO <= 2 && FIFO_FT == 0))) begin  
          		Tx_Dato_scor_Actual = Tx_Dato_scor_2; //coloco dato
          		bit_paridad = ^Tx_Dato_scor_2; //calculo bit de paridad
            	tx_new_data = 0;
            	tx_count_dato_Actual = 3;
              	FIFO_DATA =0;
                //`uvm_error(get_type_name(),"Dato 2")
         	end
        
        	
        	else if (tx_count_dato_Actual == 3 && ((tx_count_FIFO > 3 && FIFO_FT == 1) || (tx_count_FIFO <= 3 && FIFO_FT == 0))) begin  
          		Tx_Dato_scor_Actual = Tx_Dato_scor_3; //coloco dato
          		bit_paridad = ^Tx_Dato_scor_3; //calculo bit de paridad
            	tx_new_data = 0;
            	tx_count_dato_Actual = 4;
              	FIFO_DATA =0;
                //`uvm_error(get_type_name(),"Dato 3")
         	end
        
        	else if (tx_count_dato_Actual == 4 && ((tx_count_FIFO > 4 && FIFO_FT == 1) || (tx_count_FIFO <= 4 && FIFO_FT == 0))) begin  
          		Tx_Dato_scor_Actual = Tx_Dato_scor_4; //coloco dato
          		bit_paridad = ^Tx_Dato_scor_4; //calculo bit de paridad
            	tx_new_data = 0;
            	tx_count_dato_Actual = 5;
              	FIFO_DATA =0;
                //`uvm_error(get_type_name(),"Dato 4")
         	end
         
        	
        	else if (tx_count_dato_Actual == 5 && ((tx_count_FIFO > 5 && FIFO_FT == 1) || (tx_count_FIFO <= 5 && FIFO_FT == 0))) begin  
          		Tx_Dato_scor_Actual = Tx_Dato_scor_5; //coloco dato
          		bit_paridad = ^Tx_Dato_scor_5; //calculo bit de paridad
            	tx_new_data = 0;
            	tx_count_dato_Actual = 6;
              	FIFO_DATA =0;
                //`uvm_error(get_type_name(),"Dato 5")
         	end
        
        	
        	else if (tx_count_dato_Actual == 6 && ((tx_count_FIFO > 6 && FIFO_FT == 1) || (tx_count_FIFO <= 6 && FIFO_FT == 0))) begin  
          		Tx_Dato_scor_Actual = Tx_Dato_scor_6; //coloco dato
          		bit_paridad = ^Tx_Dato_scor_6; //calculo bit de paridad
            	tx_new_data = 0;
            	tx_count_dato_Actual = 7;
              	FIFO_DATA =0;
                //`uvm_error(get_type_name(),"Dato 6")
         	end
        
        	else if (tx_count_dato_Actual == 7 && tx_count_FIFO <= 7 && FIFO_FT == 0) begin    
          		Tx_Dato_scor_Actual = Tx_Dato_scor_7; //coloco dato
          		bit_paridad = ^Tx_Dato_scor_7; //calculo bit de paridad
            	tx_new_data = 0;
            	tx_count_dato_Actual = 0;
              	FIFO_DATA =0;
                //`uvm_error(get_type_name(),"Dato 7")
         	end
         
      end //finaliza envio datos TX
      
      //Reloj principal UART
                 
      //reloj anterior
       	
      	//inicio transmision del dato
      
        if (tx_enable_scor == 1 && tx_new_data == 0) begin // habilitar salida para transmitir
       
          	if(tx_contador == 1) begin
          		tx_out_scor = 1; // bit de sincronización del reloj
        	end
        
          	if(tx_contador == 2) begin
          		tx_out_scor = 0; //bit de inicio 
        	end
        
          	if(tx_contador > 2 && tx_contador < 11) begin
          		tx_out_scor = Tx_Dato_scor_Actual[tx_contador -2];
        	end
        
          	if(tx_contador == 11) begin
          		tx_out_scor = bit_paridad;
        	end
        
          	if(tx_contador == 12) begin
          		tx_out_scor = 1; // bit de parada
          		tx_empty_scor = 1; //dato vacío
              	tx_contador = 0; //variable a cambiar
              	tx_new_data = 1; //pide nuevo dato a la FIFO
            end
        	
      		//`uvm_info(get_type_name(),$sformatf("Dato Salida: %0b",tx_out_scor),UVM_LOW)
            //`uvm_info(get_type_name(),$sformatf("Contador: %0d",tx_contador),UVM_LOW)
        	       	
			tx_contador = tx_contador + 1; 
         
        end  
     
        //Inicia RX
          
          if (Rx_enable_scor == 1) begin // habilitar salida para transmitir
            
            rx_new_data = 0;
       
            if(RX_DATA_ON == 0) begin //si dato entreda es o y contador es 11
          	   Rx_count_scor = 1; // inicializo contador Rx en 0              
        	end
            
            if(mem_pkt.uart_REC_dataH == 0 && Rx_count_scor == 1) begin //si dato entreda es o y contador es 11
          	   Rx_count_scor = 1; // inicializo contador Rx en 0
               RX_DATA_ON = 1;
              //`uvm_info(get_type_name(),$sformatf("Bit Inicio: %0h",mem_pkt.uart_REC_dataH),UVM_LOW)
        	end
        
            else if(Rx_count_scor > 1 && Rx_count_scor < 10) begin
               Rx_Dato_scor_Actual[Rx_count_scor -2] = mem_pkt.uart_REC_dataH;
              //`uvm_info(get_type_name(),$sformatf("BIT: %0h",mem_pkt.uart_REC_dataH),UVM_LOW)
        	end
        
            else if(Rx_count_scor == 10) begin //bit de paridad
          		bit_RX_paridad = mem_pkt.uart_REC_dataH;
              //`uvm_info(get_type_name(),$sformatf("Bit Paridad: %0h",mem_pkt.uart_REC_dataH),UVM_LOW)
        	end
            
            else if(Rx_count_scor == 11) begin
          		Rx_count_scor = 0;
                RX_DATA_ON = 0;
                rx_new_data = 1;
              //`uvm_info(get_type_name(),$sformatf("Bit Parada: %0h",mem_pkt.uart_REC_dataH),UVM_LOW)
              //`uvm_info(get_type_name(),$sformatf("Dato: %0h",Rx_Dato_scor_Actual),UVM_LOW)
        	end 
            
            Rx_count_scor = Rx_count_scor + 1;
            
        end
          
        //Finaliza RX  
          
      	else begin        
        	tx_out_scor = 1;
        	//`uvm_info(get_type_name(),$sformatf("------ :: Salida Vacía :: ------"),UVM_LOW)
        	tx_contador = 0;
        	tx_empty_scor = 1;
      	end
        
        end //finaliza condición de reloj baud==1
      
      end
      
      else begin
    	clk_div  = clk_div + 1;
    	baud_clk = baud_clk;
  	  end
      
      // Validación de datos
        
      //if(mem_pkt.tx_out != tx_out_scor) begin
        
        //if(tx_contador == 2) begin
          //`uvm_error(get_type_name(),"Error  Bit de Inicio")
        //end
     	
        //if(tx_contador > 2 && tx_contador < 11) begin
          //`uvm_error(get_type_name(),"Error e trama de bits")
        //end
        
        //if(tx_contador == 11) begin
          //`uvm_error(get_type_name(),"Error bit Paridad")
        //end
        
        //if(tx_contador == 12) begin
          //`uvm_error(get_type_name(),"Error bit de Parada")
        //end  
      
      //end	
      
      //if(mem_pkt.tx_empty != tx_empty_scor) begin
        //`uvm_error(get_type_name(),"Error Tx Empty")
      //end
      
    end
  endtask : run_phase
endclass : mem_scoreboard