`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC-DCIlab
// Engineer: Dayhana Sanchez Jimenez
// 
// Create Date: 04/12/2018 09:23:21 AM
// Design Name: UART
// Module Name: uart_to_fifo_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 

// Descripcion: Modulo de control entre el registro utf y el urec y la fifo
// 
// Dependencias: modulos u_rec.v fifo.v baud.v
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
// Actualizado 30 de abril. Cambios la señal push hacia la fifo debe durar solo un ciclo de reloj del sistema
//////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------

module log_utf #(parameter pos_array =8, 
                            data_fifo  =64, // 8 bytes -> 64 bits
                            data  =8
                        )( 
    input uart_clk,
    input sys_clk,
    input rec_ready, //indica que hay un byte completo listo "rec_ready"
    input sys_rst_l,
    output reg push, // indica que ya se completaron los bytes  
    output reg rst,
    output reg [pos_array-1:0] enable_reg // se;al que habilita los registros de utf_reg
    );
        
    reg rst_cont_byte, ena_cont_byte;
    reg [1:0] state, next_state;
    reg [$clog2(pos_array)-1:0] cont_byte;
    wire [data-1:0] array [data-1:0];
    reg [1:0] p_state, p_next_state;
    reg push_en, set_push, rst_push, reset_push; //Señales para push de fifo
    
   // Definicion de parameteros 
    localparam [1:0]
        IDLE  = 2'b00,
        CARGA = 2'b01,
        ENVIO = 2'B10,
        STOP  = 2'B11;
    
    localparam HI = 1'b1,
               LO = 1'b0,
               X  = 1'bx,
               Z  = 1'bz;

    // maquina push
    localparam [1:0]
    	      idle= 2'b00,
    	      desact_push = 2'b01,
              desact_rst_push = 2'b10;
              
 // Registro pop--------------------------------------------------------
 always @ (posedge sys_clk) begin
    if (rst_push)
        push_en = LO;
    else if (set_push)
        push_en = HI;
 end   
  //---------------------------------------------------------------------
  
    // FSM para señal push
    always @ (posedge sys_clk or posedge sys_rst_l) begin
    	if (sys_rst_l) begin
    	    p_state <= idle;
    	end
    	else 
    	    p_state <= p_next_state;
    end
     always @(p_state or push_en or reset_push) begin
 	push = LO;
 	p_next_state = p_state;
 	case (p_state)
 	    idle: begin
 	    	if (push_en) begin
 	    	    push = HI;
 	    	    p_next_state= desact_push;
 	        end
 	        else
 	            p_next_state = idle;
 	    end
 	    desact_push: begin
 	    	push = LO;
 	    	p_next_state = desact_rst_push;
 	    	rst_push = HI;
 	    end
 	    desact_rst_push: begin
 	    	if (reset_push) begin
 	    	    rst_push = LO;
 	    	    p_next_state = idle;
 	    	end
 	    	else
 	    	    p_next_state = desact_rst_push;
 	    end
 	endcase
     end
    	      
  // Deco de activacion de los registros del uft reg
  always @ (posedge uart_clk) begin
    if (rec_ready)
        enable_reg[cont_byte] = 1'b1;
    else enable_reg = {pos_array{1'b0}};
  end
  //--------------------------------------------------------- 
    
    //Contador de bytes ---------------------------------------
    always @ (posedge uart_clk or posedge sys_rst_l) begin
        if (sys_rst_l)
            cont_byte <=0;
        else if (rst_cont_byte)
            cont_byte <=0;
        else if (ena_cont_byte)
            cont_byte <= cont_byte+1;
        else cont_byte <= cont_byte;
    end
    //--------------------------------------------------------- 
    
    // State Variable
    always @ (posedge uart_clk or posedge sys_rst_l) begin
        if (sys_rst_l)
            state <= IDLE;
        else 
            state <= next_state;
    end 
    
    // FSM
    always @ (state or cont_byte or rec_ready) begin
        // Defaults
        next_state    = state;
        ena_cont_byte = LO;
        rst_cont_byte = LO;
        rst           = LO;
        set_push      = LO;
        reset_push    = LO;
        
        case (state)
            IDLE: begin
                if (rec_ready) begin// si hay un dato pendiente y termino de enviar el primer paquete
                    next_state = CARGA;
                    ena_cont_byte = HI;
                end
                else begin
                    next_state = IDLE;
                    rst = HI; // reinicia los registros del array
                end                    
            end
            
            CARGA: begin
                if (rec_ready) begin  
                    if (cont_byte == (pos_array-1)) begin
                        next_state= ENVIO;
                    end
                    else 
                        ena_cont_byte = HI;
                end
                else 
                    next_state = CARGA;                
            end
            
            ENVIO: begin
                set_push = HI;
                rst_cont_byte = HI;
                next_state = STOP;
            end
            
            STOP: begin
                reset_push=HI;
                next_state = IDLE;
            end
        endcase
    end
    
endmodule
