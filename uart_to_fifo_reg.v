`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC-DCIlab
// Engineer: Dayahana Sanchez Jimenez
// 
// Create Date: 04/12/2018 06:13:23 PM
// Design Name: UART
// Module Name: uart_to_fifo_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 

// Descripcion: Registro para pasar datos del uart a la fifo. Se realiza de forma independiente
// para posteriormente evaluar si se cambia por una ram.
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_to_fifo_reg #(parameter pos_array = 8,// 10 bytes de la fifo solo interesan 8 los otros 2 se descartan
                                    data_fifo  =64,   // 8  bytes 8*8
                                    byte_out = 8)( // 1 byte
    input [pos_array-1:0]clk, // señal para cargar los registros
    input sys_rst_l,
    input wire [byte_out-1:0] Din, // dato de entrada viene de la fifo
    output wire [data_fifo-1:0] Dout //Dout dato de salida de cada registro
);
   
 wire [byte_out-1:0] array [pos_array-1:0];
   
 //Logica para distribuir el dato de la fifo en registros de 8 bits 
 // En este caso tienen entrada de clk y salida D_out ndependiente
 // y Din y reset comun para todos los registros        
  genvar i;
 generate
    for (i =0; i < pos_array; i=i+1) begin: utf_reg
       prll_d_reg#(8) prll_d_reg(.D_in(Din), .clk(clk[i]), .reset(sys_rst_l), .D_out(array[i]));
       assign Dout [(7+i*8):(8*i)] = array[i];
    end
 endgenerate
 
endmodule
