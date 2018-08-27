`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC-DCIlab
// Engineer: Dayahana Sanchez Jimenez
// 
// Create Date: 04/12/2018 06:13:23 PM
// Design Name: UART
// Module Name: fifo_to_uart_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 

// Descripcion: Modulo de control entre el registro ftu y el xmit y la fifo
// Dependencias: baud.v, fifo_T.v, xmit.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//Actualizado 30 abril. Cambios: La señal pop hacia la fifo dura un solo un ciclo de reloj del sistema
//////////////////////////////////////////////////////////////////////////////////


module log_ftu #(parameter pos_array = 8,
                           data_fifo  =64,   // 8 bytes 8 *8
                           byte_out = 8)( // 1 byte
    input uart_clk,
    input sys_clk,
    input xmit_done, // proveniente de la señal xmit_doneH listo byte transmitido
    input pndng, // señal pndng indica que hay un dato en la fifo esperando ser transmitido
    input sys_rst_l,
    input wire [data_fifo-1:0] D_reg, // dato de entrada viene del registro ftu
    output wire [byte_out-1:0] Dout, // dato hacia el xmit para transmitir bit a bit
    output reg xmit, // habilita el transmisor
    output reg pop // indica que ya se completaron los 8 o 4 bytes por lo que solicita otro 
   
);

reg [$clog2(pos_array)-1:0] cont_byte;
wire [byte_out-1:0] array [pos_array-1:0];
reg rst, rst_cont_byte, ena_cont_byte, four_eight; // rst para resetear el arreglo
reg [2:0] state, next_state;
reg [1:0] p_state, p_next_state; // estados FSM para la señal pop
reg pop_en, set_pop, rst_pop, reset_pop; // señales para pop de fifo

genvar i;
generate 
    for (i =0; i < pos_array; i=i+1) begin :l_ftu
        assign array[i] = D_reg[(7+i*8):(8*i)];
    end
 endgenerate
 
assign Dout [byte_out-1:0] = array[cont_byte];

//--------------------------------------------------------- 

 // Definicion de parametros
 localparam HI = 1'b1,
            LO = 1'b0,
            Z  = 1'bz;
 
 localparam [2:0]
    IDLE     = 3'b000,
    POP_data = 3'b001,
    QTY_BYTE = 3'b010,
    START    = 3'b011,
    WAIT     = 3'b100,
    SEND     = 3'b101,
    STOP     = 3'b110;
 
 // maquina pop
 localparam [1:0]
     idle = 2'b00,
     desact_pop = 2'b01,
     desact_rst_pop = 2'b10;
    
 //Contador de bytes transmitidos---------------------------------------
 always @ (posedge uart_clk or posedge sys_rst_l) begin
     if (sys_rst_l)
         cont_byte <=0;
     else if (rst_cont_byte)
         cont_byte <=0;
     else if (ena_cont_byte)
         cont_byte <= cont_byte+1;
     else cont_byte <= cont_byte;
 end
 //---------------------------------------------------------------------
 
 // Registro pop--------------------------------------------------------
 always @ (posedge sys_clk) begin
    if (rst_pop)
        pop_en = LO;
    else if (set_pop)
        pop_en = HI;
 end   
  //---------------------------------------------------------------------

 // FSM para señal pop--------------------------------------------------- 
 always @ (posedge sys_clk or posedge sys_rst_l) begin
         if (sys_rst_l) begin
             p_state <= idle;
         end
         else 
            p_state <= p_next_state;
     end     
             
 always @(p_state or pop_en or reset_pop) begin
     pop = LO;
     p_next_state = p_state;
     case (p_state)
         idle: begin
             if (pop_en) begin
                 pop = HI;
                 p_next_state= desact_pop;
             end
             else
                 p_next_state = idle;
         end
         desact_pop: begin
             pop = LO;
             p_next_state = desact_rst_pop;
             rst_pop=HI;
         end
         desact_rst_pop:  begin
             if (reset_pop) begin
                 rst_pop=LO;
                 p_next_state = idle;
             end
             else 
             	 p_next_state = desact_rst_pop;
         end
     endcase
 end
 //---------------------------------------------------------------------
 
 // State Variable
 always @ (posedge uart_clk or posedge sys_rst_l) begin
         if (sys_rst_l) begin
             state <= IDLE;
             rst=HI;
         end
         else 
             state <= next_state;
     end
  //--------------------------------------------------------- 
 
 // FSM    
 always @ (state or cont_byte or pndng or xmit_done) begin
     // Defaults
     next_state    = state;
     ena_cont_byte = LO;
     rst_cont_byte = LO;
     rst           = LO;
     set_pop       = LO;
     xmit          = LO;
     reset_pop     = LO;
          
     case (state)
         IDLE: begin //0
            if (pndng) begin
                next_state = POP_data;
            end
            else begin
                next_state = IDLE;
                rst = HI; // reinicia los registros del array
                rst_cont_byte = HI;
            end    
         end
         
         POP_data: begin //1
             set_pop = HI;  // carga dato en los registros
             next_state = QTY_BYTE;
         end
         
         QTY_BYTE: begin // 2   32 - 55
            reset_pop = HI;
            if (|D_reg[55:32] == 0)
                four_eight = LO; // envia solo los 4 bytes de datos
            else 
                four_eight = HI; // envia 8 bytes de datos
            next_state = START;
         end
         
         START: begin //3
            xmit = HI;
            next_state = WAIT;
         end
         
         WAIT: begin //4
            if (four_eight==1'b0) begin
                if (xmit_done) begin
                    if (cont_byte == pos_array-5) begin
                        next_state = STOP; 
                   end
                    else begin
                        next_state = SEND;
                        ena_cont_byte = HI;
                    end
                end
                else begin
                    next_state = WAIT;
                end
            end
            else begin
                if (xmit_done) begin
                    if (cont_byte == pos_array-1) begin
                        next_state = STOP; 
                   end
                    else begin
                        next_state = SEND;
                        ena_cont_byte = HI;
                    end
                end
                else begin
                    next_state = WAIT;
                end
            end
         end
         
         SEND: begin //5
            xmit=HI;
            next_state = WAIT;
         end
         
         STOP: begin //6
            
            rst_cont_byte = HI;
            next_state = IDLE;
            four_eight = LO;
         end
     endcase
  end
endmodule


