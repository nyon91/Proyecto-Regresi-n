`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC-DCIlab
// Engineer: Dayhana Sánchez Jiménez
// 
// Create Date: 02/15/2018 10:49:03 AM
// Design Name: UART
// Module Name: u_rec
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Descripción: Módulo u_rec, contiene la máquina de estados del Receptor.
// 
// Dependencies: baud.v
// 
// Description: u_rec module, contains the FSM of Receiver.

// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module u_rec #(parameter WORD_LEN_PLUS1 = 9)(	
				input sys_rst_l,
				input uart_clk,

				// uart in
				input uart_dataH, //Dato de entrada que recibe el UART de forma serial

				// out
				output wire [7:0] rec_dataH, // parallel received data
				output reg rec_readyH,
				output reg parity_error

				);


// Symbolic State Declaration 
//*********************************************

localparam	[2:0]
            r_START 	= 3'b000,
          	r_CENTER	= 3'b001,
          	r_WAIT  	= 3'b010,
          	r_SAMPLE	= 3'b011,
          	r_PARITY    = 3'b100,
		    r_STOP  	= 3'b101;
		    
// Common parameter Definition
localparam   LO         = 1'b0,
             HI         = 1'b1,        
             X          = 1'bx;    
                             
// ******************************************
//
// MEMORY ELEMENT DEFINITIONS
//
// ******************************************

reg		[2:0]	next_state, state;
reg				rec_datH, rec_datSyncH; // rec_datH form dualrank synchronizer to de'serializer
reg		[3:0]	bitCell_cntrH; // from bit cell counter to FSM
reg				cntr_resetH;   // from FSM to bit cell counter
reg		[8:0]	par_dataH;
reg				shiftH;        // from FSM to deserializer
reg		[3:0]	recd_bitCntrH; // from received counter to FSM
reg				countH;        // from FSM to received counter
reg				rstCountH;     // from FSM to received counter
reg				rec_readyInH;
reg             bit_paridad;



assign rec_dataH[7:0] = par_dataH[7:0];  // byte de salida

// synchronize the asynchrnous input
// to the system clock domain
// dual-rank
always @(posedge uart_clk or posedge sys_rst_l)
  if (sys_rst_l) 
  begin
     rec_datSyncH <= 1'b1;
     rec_datH     <= 1'b1;
  end 
  else begin
     rec_datSyncH <= uart_dataH;
     rec_datH     <= rec_datSyncH;
  end


// Bit-cell counter
always @(posedge uart_clk or posedge sys_rst_l)
  if (sys_rst_l) 
    bitCell_cntrH <= 0;
  else if (cntr_resetH) 
    bitCell_cntrH <= 0;
  else 
    bitCell_cntrH <= bitCell_cntrH + 1;


// Shifte Register to hold the incoming 
// serial data
// LSB is shifted in first
//
always @(posedge uart_clk or posedge sys_rst_l)
  if (sys_rst_l) 
    par_dataH <= 0;
  else if(shiftH) begin                 //cuando esta activa en alto desplaza el dato una posición
     par_dataH[7:0] <= par_dataH[8:1];
     par_dataH[8]   <= rec_datH; // bit que va entrando al deserializador
  end


// RECEIVED BIT Counter
// This coutner keeps track of the number of
// bits received
always @(posedge uart_clk or posedge sys_rst_l)
  if (sys_rst_l) 
    recd_bitCntrH <= 0;
  else if (countH) 
    recd_bitCntrH <= recd_bitCntrH + 1;
  else if (rstCountH) 
    recd_bitCntrH <= 0;




// State Machine - Next State Assignment
always @(posedge uart_clk or posedge sys_rst_l)
  if (sys_rst_l) 
    state <= r_START;
  else 
    state <= next_state;


// State Machine - Next State and Output Decode
always @(state or rec_datH or bitCell_cntrH or recd_bitCntrH or par_dataH)
begin

  // default
  next_state  = state;
  cntr_resetH = HI;
  shiftH      = LO;
  countH      = LO;
  rstCountH   = LO;
  rec_readyInH= LO;
  //parity_error= LO;
  case (state)
     
    //
    // START
    // Wait for the start bit
    // 
    r_START: begin //001
       if (~rec_datH ) begin
        next_state = r_CENTER; // bit de inicio 0
        parity_error = LO;
       end 
       else begin 
         next_state = r_START;
         rstCountH  = HI; // place the bit counter in rst state
         //rec_readyInH = HI; // by default, we're ready ///######VERIFICAR
       end
    end

    //
	// CENTER
	// Find the center of the bit-cell 
	// A bit cell is composed of 16 system-clock 
	// ticks
	//
    r_CENTER: begin //010
       if (bitCell_cntrH == 4'h4) begin
         // if after having waited 1/2 bit cell,
 		 // it is still 0, then it is a genuine start bit
         if (~rec_datH) begin
            next_state = r_WAIT;
            countH = HI;
         end   
		 // otherwise, could have been a false noise
         else 
            next_state = r_START;
       end 
       else begin
         next_state  = r_CENTER;
		 cntr_resetH = LO;  // allow counter to tick          
       end
    end


    //
	// WAIT
	// Wait a bit-cell time before sampling the
	// state of the data pin
	//
	r_WAIT: begin //011
		if (bitCell_cntrH == 4'hE) begin
           if (recd_bitCntrH == WORD_LEN_PLUS1) begin // + 1 para muestrear el bit de paridad
             next_state = r_PARITY; // we've sampled all 8 bits
             shiftH = HI;
           end
           else begin
             next_state = r_SAMPLE;
           end
        end else begin
             next_state  = r_WAIT;
             cntr_resetH = LO;  // allow counter to tick 
        end
    end

    // 
	// SAMPLE
	// Sample the state of the RECEIVE data pin 
   	//
	r_SAMPLE: begin//100
		shiftH = HI; // shift in the serial data
		countH = HI; // one more bit received
		next_state = r_WAIT;
	end	
    
    //
    //x_PARITY   100
    //Error detection
    //
    r_PARITY: begin
        if (bitCell_cntrH == 4'hE) begin
            //parity_error = par_dataH[8];      // bit de detección de error
            if (^par_dataH[7:0] == par_dataH[8]) //If the Exclusive-OR of data bits equals the expected value, then no error was detected.  Otherwise, an error is detected.
                parity_error = LO; // no se presenta error
            else 
                parity_error = HI; // Si no cumple la condicion de paridad par
            next_state = r_STOP;
        end
        else begin
            next_state = r_PARITY; 
            cntr_resetH = LO;
        end
            
     end
  
    // 
    // STOP
    // make sure that we've seen the stop
    // bit
    //
    r_STOP: begin//101
		next_state = r_START;
		if (parity_error == 1'b1)  // \
		  rec_readyInH = LO;       //  \ logica para descartar escribir un dato en caso de que haya error de paridad
		else                        ///
		  rec_readyInH = HI;       ///
        rstCountH = HI; // linea agregada para reiniciar el contador que muestra hasta WORD_LEN
    end

    default: begin
       next_state  = 3'bxxx;
       cntr_resetH = X;
	   shiftH      = X;
	   countH      = X;
       rstCountH   = X;
       rec_readyInH  = X;
       parity_error = X;

    end

  endcase

end

// register the state machine outputs
// to eliminate ciritical-path/glithces
always @(posedge uart_clk or posedge sys_rst_l)
  if (sys_rst_l) 
    rec_readyH <= 0;
  else 
    rec_readyH <= rec_readyInH;
    
endmodule
