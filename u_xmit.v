`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC-DCIlab
// Engineer: Dayhana Sánchez Jiménez
// 
// Create Date: 02/15/2018 10:49:03 AM
// Design Name: UART
// Module Name: u_xmit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Descripción: Módulo u_xmit, contiene la máquina de estados del transmisor.
// 
// Dependencies: baud.v log_ftu
// 
// Description: u_xmit module, contains the FSM of transmitter.
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module u_xmit #(parameter WORD_LEN = 8)(
    input uart_clk,
    input sys_rst_l,
    // in
    input xmitH,// active high, Xmit command -> Indica que hay un nuevo dato para transmitir
    input [7:0] xmit_dataH,	// data to be xmitted	
    // out
    output reg uart_xmitH,
    output reg xmit_doneH // status
);


// Symbolic State Declaration 
//*********************************************

localparam	[2:0]
        	x_IDLE		= 3'b000,
			x_START		= 3'b001,
			x_WAIT		= 3'b010,
			x_SHIFT		= 3'b011,
			x_PARITY    = 3'b100,
			x_STOP		= 3'b101;

// Definition of bits in the trasnmition
localparam  x_STARTbit  = 2'b00,
			x_STOPbit   = 2'b01,
			x_ShiftReg  = 2'b10,
			x_PAR       = 2'b11;

// Common parameter Definition
localparam	LO 		= 1'b0,
          	HI		= 1'b1,		
 		  	X		= 1'bx;			
// ******************************************
//
// MEMORY ELEMENT DEFINITIONS
//
// ******************************************
reg		[2:0]	next_state, state;
reg				load_shiftRegH;
reg				shiftEnaH;       // from state machine to serializer
reg		[4:0]	bitCell_cntrH;   // bit cell counter to state machine
reg				countEnaH;       // form state machine to bit cell counter
reg		[7:0]	xmit_ShiftRegH;
reg		[3:0]	bitCountH;       // xmitted bit counter to state machine
reg				rst_bitCountH;   // from state machine to xmitted bit counter
reg				ena_bitCountH;   // from state machine to xmitted bit counter
reg		[1:0]	xmitDataSelH;
reg				xmit_doneInH;
reg             BP;


// MUX -----------------------------------------------------------------------------
always @(xmit_ShiftRegH or xmitDataSelH or BP)
  case (xmitDataSelH)
	x_STARTbit: uart_xmitH = LO; // Data output
	x_STOPbit:  uart_xmitH = HI;
	x_ShiftReg: uart_xmitH = xmit_ShiftRegH[0];
	x_PAR:      uart_xmitH = BP; // Se envia el bit de paridad
	//default:    uart_xmitH = HI;	
  endcase


//
// Bit Cell time Counter----------------------------------------------------------
//
  always @(posedge uart_clk or posedge sys_rst_l)
  if (sys_rst_l) 
    bitCell_cntrH <= 0;
  else if (countEnaH) 
    bitCell_cntrH <= bitCell_cntrH + 1;
  else 
    bitCell_cntrH <= 0;


//
// Shift Register------------------------------------------------------------------
//
// The LSB must be shifted out first
//
always @(posedge uart_clk or posedge sys_rst_l)
  if (sys_rst_l) 
    xmit_ShiftRegH <= 0;
  else 
	if (load_shiftRegH) 
	   xmit_ShiftRegH <= xmit_dataH;
	else if (shiftEnaH) begin
		xmit_ShiftRegH[6:0] <= xmit_ShiftRegH[7:1];
		xmit_ShiftRegH[7]   <= HI;
	end 
	else 
	   xmit_ShiftRegH <= xmit_ShiftRegH;

//
// Transmitted bit counter---------------------------------------------------------
//
// bitCount es el encargado de contar la cantidad de datos recibida, definida por WORD_LEN
//
always @(posedge uart_clk or posedge sys_rst_l)
  if (sys_rst_l) 
    bitCountH <= 0;
  else if (rst_bitCountH) 
    bitCountH <= 0;
  else if (ena_bitCountH) 
    bitCountH <= bitCountH + 1;


// Detect parity bit -----------------------------------------------

always @(posedge uart_clk or posedge sys_rst_l)
  if (sys_rst_l) 
    BP <= 1'b0;
  else if (xmitH) // Si hay un dato nuevo
        if(^xmit_dataH[7:0]==1'b0)
        	BP<= 1'b0;
        else 
        	BP<= 1'b1;

//
// STATE MACHINE--------------------------------------------------------------------
//

// State Variable
always @(posedge uart_clk or posedge sys_rst_l)
  if (sys_rst_l) 
    state <= x_IDLE;
  else 
    state <= next_state;


// Next State, Output Decode
always @(state or xmitH or bitCell_cntrH or bitCountH or BP)
begin
   
	// Defaults
	next_state 		= state;
	load_shiftRegH	= LO;
	countEnaH       = LO;
	shiftEnaH       = LO;
	rst_bitCountH   = LO;
	ena_bitCountH   = LO;
    xmitDataSelH    = x_STOPbit;
	xmit_doneInH	= LO;
	

	case (state)
    	
		//
		// x_IDLE 000
		// wait for the start command
		//
		x_IDLE: begin
			if (xmitH) 
			begin 
                next_state = x_START;
				load_shiftRegH = HI;
				rst_bitCountH = HI;  ///Para resetear word_len
                //xmit_doneInH  = HI; 
			end 
			else begin
				next_state    = x_IDLE;
				rst_bitCountH = HI; 
                xmit_doneInH  = HI;     
        end
		end
 
		//
		// x_START  001
		// send start bit 
		//
		x_START: begin 
            xmitDataSelH    = x_STARTbit;  //xmitH=LO
			if (bitCell_cntrH == 4'hF) begin
				next_state = x_WAIT;
				ena_bitCountH = HI; //1more bit sent
		    end
			else begin 
				next_state = x_START;
				countEnaH  = HI; // allow to count up
			end				
		end


		//
		// x_WAIT  010
		// wait 1 bit-cell time before sending
		// data on the xmit pin
		//
		x_WAIT: begin 
            xmitDataSelH    = x_ShiftReg;  
			// 1 bit-cell time wait completed
			if (bitCell_cntrH == 4'hE) begin
				if (bitCountH == WORD_LEN) // si el # de bits muestreado es igual a WORD_LEN
					next_state = x_PARITY;
				else begin
					next_state = x_SHIFT;
					ena_bitCountH = HI; //1more bit sent
				end
			// bit-cell wait not complete
			end 
			else begin
				next_state = x_WAIT;
				countEnaH  = HI;
			end		
		end



		//
		// x_SHIFT   011
		// shift out the next bit
		//
		x_SHIFT: begin 
            xmitDataSelH    = x_ShiftReg;
			next_state = x_WAIT;
			shiftEnaH  = HI; // shift out next bit
		end


        //
        //x_PARITY   100
        //Error detection
        //
        x_PARITY: begin
            xmitDataSelH    = BP; //uart_xmitH=HI
            if (bitCell_cntrH == 4'hF) begin
                next_state   = x_STOP;
            end else begin
                next_state = x_PARITY;
                countEnaH = HI; //allow bit cell cntr
            end 
        end
              
        
		//
		// x_STOP
		// send stop bit
		//
		x_STOP: begin //101
            xmitDataSelH    = x_STOPbit; //uart_xmitH=HI
			if (bitCell_cntrH == 4'hF) begin
				next_state   = x_IDLE;
                rst_bitCountH  = HI;    ///Para resetear el contador de WordLen
                xmit_doneInH  = HI; 
			end else begin
				next_state = x_STOP;
				countEnaH = HI; //allow bit cell cntr
			end
		end



		default: begin
			next_state     = 3'bxxx;
			load_shiftRegH = X;
			countEnaH      = X;
            shiftEnaH      = X;
            rst_bitCountH  = X;
            ena_bitCountH  = X;
            xmitDataSelH   = 2'bxx;
            xmit_doneInH   = X;
		end

    endcase

end


// register the state machine outputs
// to eliminate ciritical-path/glithces
always @(posedge uart_clk or posedge sys_rst_l)
  if (sys_rst_l) 
    xmit_doneH <= 0;
  else begin // Atraso de una señal de reloj
    xmit_doneH<= xmit_doneInH;
   
  end
endmodule
