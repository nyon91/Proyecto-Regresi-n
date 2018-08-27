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

// Descripcion: Registro para pasar datos de la fifo al transmisor. Se realiza de forma independiente
// para posteriormente evaluar si se cambia por una ram. En este modulo todos los registros comparten 
// el mismo clk
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo_to_uart_reg #(parameter pos_array = 8,// 
                                    data_fifo  =64,   // 8  bytes 8*8
                                    byte_out = 8)( // 1 byte
    input clk, // señal para cargar los registros
    input sys_rst_l,
    input wire [data_fifo-1:0] Din, // dato de entrada viene de la fifo
    output wire [data_fifo-1:0] Dout //Dout dato de salida de cada registro
);
   
 wire [byte_out-1:0] array [pos_array-1:0];
   
 //conexion de varios registros paralelos, con entrada y salida de datos independiente
 //y con el mismo reset y clk para todos los registros.     
  genvar i;
 generate
    for (i =0; i < pos_array; i=i+1) begin: ftu_reg
       prll_d_reg#(8) prll_d_reg(.D_in(Din[(7+i*8):(8*i)]), .clk(clk), .reset(sys_rst_l), .D_out(array[i]));
       assign Dout [(7+i*8):(8*i)] = array[i];
      end
             
 endgenerate
 
endmodule
