`timescale 1ns / 10ps

`include "baud.v"
`include "fifo.v"
`include "fifo_to_uart_reg.v"
`include "log_ftu.v"
`include "log_utf.v"
`include "prll_d_reg.v"
`include "u_rec.v"
`include "u_xmit.v"
`include "uart_to_fifo_reg.v"

//////////////////////////////////////////////////////////////////////////////////
// Company:  ITCR
// Engineer: Dayhana Sánchez Jiménez
// 
// Create Date: 02/15/2018 10:49:03 AM
// Design Name: UART
// Module Name: Transmitter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Descripción: Este módulo top contiene los módulos principales del UART, 
// los cuales son el baud generator, el Transmitter y el Receiver

// Description: This module contains the principals modules of UART, which are
// baud generator, Transmitter and Receiver
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//=========================UART======================================================================================

module uart        #(parameter WORD_LEN = 8, // Tamaño de la palabra a transmitir
                        byte_datos = 8, 
                        data_fifo = 8, //\ parametros utilizados en la fifo 10 bytes
                        depth = 16,///
                        XTAL_CLK = 25175000, 
                        BAUD = 20000,
                        CLK_DIV = XTAL_CLK / (BAUD * 16 * 2),
                        CW   = 9,
                        pos_array=8)
            (                  // System
                                sys_clk,
                                sys_rst_l,

                                // Transmitter Signals
                                uart_XMIT_dataH, //Salida del bloque
                                tx_full,         // Status FIFO_T
                                push_T, // from bus
                                Din, 
                                
                                // Receiver Signals
                                uart_REC_dataH, // Entrada al rx
                                rx_full,
                                pop_R,
                                Dout,
                                pndng_R,
                                
 //---------------Señales internas para visualizacion en testbench (No son puertos del UART) ---------------------
                         uart_clk,
                        
                        // Transmitter
                         pndng_T, pop_T, xmit_doneH, xmit,    
                         D_pop_fT,
                         xmit_dataH,
                        
                        //Receiver
                         parity_error,    // Bandera que indica error de paridad  
                         rec_readyH,
                         rec_dataH,
                         push_fR, // Se;al para escribir dato en la fifo
                         D_push_fR
                        );

//====================================================================================================================                                

input                        sys_clk;
input                        sys_rst_l;

// Trasmitter
output          uart_XMIT_dataH; // Salida de dato serie 
output          tx_full; 
input           push_T;
input [data_fifo-1:0] Din;

// Receiver
input           uart_REC_dataH; 
output          rx_full;
input           pop_R;
output          pndng_R;
output [data_fifo-1:0] Dout;

//====================================================================================================================                                
//    Señales internas para visualizacion en testbench (No son puertos del UART)

//Baud generator 
output uart_clk;

// Transmitter
output pndng_T, pop_T, xmit_doneH, xmit;     
output [data_fifo-1:0] D_pop_fT;
output [byte_datos-1:0] xmit_dataH;

//Receiver
output rec_readyH;
output [byte_datos-1:0] rec_dataH;
output push_fR; // Se;al para escribir dato en la fifo
output [data_fifo-1:0] D_push_fR; 
output parity_error;

//====================================================================================================================
// *****Interconexión de señales*****

//Baud generator
wire uart_clk;

// Transmitter
wire pndng_T, pop_T, xmit_doneH, xmit;     
wire [data_fifo-1:0] D_pop_fT;
wire [byte_datos-1:0] xmit_dataH;
wire [data_fifo-1:0] Dout_ftu;

//Receiver
wire rec_readyH;
wire [byte_datos-1:0] rec_dataH;
wire push_fR, rst; // Se;al para escribir dato en la fifo
wire [data_fifo-1:0] Din_utf;
wire [data_fifo-1:0] D_push_fR; 
wire [pos_array-1:0] enable_reg;



//======================================================================================================
// Instantiate the Baud Rate Generator
///////////////////////////////////////////////////////////////////////////
//                              baud                                     //
///////////////////////////////////////////////////////////////////////////
baud #(.XTAL_CLK(XTAL_CLK), .BAUD(BAUD), .CLK_DIV(CLK_DIV), .CW(CW)) baud (.sys_clk(sys_clk),
                        .sys_rst_l(sys_rst_l),                
                        .uart_clk(uart_clk)
                );
                
//====================================================================================================================
// Instancia fifo-fito_to_uart_reg-xmit (Lado transmisor)
///////////////////////////////////////////////////////////////////////////                       
//                             fifo                                      //
///////////////////////////////////////////////////////////////////////////
            
// Instantiate the FIFO_T
   fifo #(.bits(data_fifo), .depth(depth)) fifo_T( 
                  .rst(sys_rst_l),
                  .pop(pop_T),           
                  .push(push_T),
                  .clk(sys_clk),
                  .Din(Din), // 10 bytes de datos de entrada             
                  .pndng(pndng_T),       
                  .full(tx_full),                       
                  .Dout(D_pop_fT) 
               );
///////////////////////////////////////////////////////////////////////////                       
//                             fifo_to_uart_reg                          //
///////////////////////////////////////////////////////////////////////////


  fifo_to_uart_reg #(.pos_array(pos_array), .data_fifo(data_fifo), .byte_out(byte_datos)) ftu_reg (
                .clk(pop_T),
                .sys_rst_l(sys_rst_l),
                .Din(D_pop_fT),
                .Dout(Dout_ftu)
              );
 
///////////////////////////////////////////////////////////////////////////                       
//                             log_ftu                                   //
///////////////////////////////////////////////////////////////////////////

log_ftu #(.pos_array(pos_array), .data_fifo(data_fifo), .byte_out(byte_datos)) log_ftu (
                .uart_clk(uart_clk),
                .sys_clk(sys_clk),
                .xmit_done(xmit_doneH),
                .pndng(pndng_T),
                .sys_rst_l(sys_rst_l),
                .D_reg(Dout_ftu),
                .Dout(xmit_dataH),
                .xmit(xmit),
                .pop(pop_T)
              );

///////////////////////////////////////////////////////////////////////////
//                              xmit                                     //
///////////////////////////////////////////////////////////////////////////
u_xmit #(.WORD_LEN(WORD_LEN)) u_xmit (        
                    // in
                    .uart_clk(uart_clk),
                    .sys_rst_l(sys_rst_l), 
                    .xmitH(xmit),
                    .xmit_dataH(xmit_dataH),
                    // out
                    .uart_xmitH(uart_XMIT_dataH), 
                    .xmit_doneH(xmit_doneH)
                );

//======================================================================================================             
// Instancia urec-uart_to_fifo_reg-fifo_R (lado del receptor)
///////////////////////////////////////////////////////////////////////////
//                              u_rec                                    //
///////////////////////////////////////////////////////////////////////////

u_rec #(.WORD_LEN_PLUS1(WORD_LEN+1)) u_rec (
                    .sys_rst_l(sys_rst_l),
                    .uart_clk(uart_clk),
                    .uart_dataH(uart_REC_dataH),
                    .rec_dataH(rec_dataH),
                    .rec_readyH(rec_readyH),
                    .parity_error()
                    //.parity_error(parity_error)
                    );
                    
///////////////////////////////////////////////////////////////////////////
//                              log_utf                                  //
///////////////////////////////////////////////////////////////////////////  

log_utf #(.pos_array(pos_array)) log_utf (
                .uart_clk(uart_clk),
                .sys_clk (sys_clk),
                .rec_ready(rec_readyH),
                .sys_rst_l(sys_rst_l),
                .push(push_fR),
                .rst(rst),
                .enable_reg(enable_reg)
              );
///////////////////////////////////////////////////////////////////////////
//                              uart_to_fifo_reg                         //
///////////////////////////////////////////////////////////////////////////
//
uart_to_fifo_reg #(.pos_array(pos_array), .data_fifo(data_fifo), .byte_out(byte_datos)) utf_reg (
                .clk(enable_reg),
                .sys_rst_l(rst),
                .Din(rec_dataH),
                .Dout(D_push_fR)
              );
///////////////////////////////////////////////////////////////////////////                       
//                                   fifo                                //
///////////////////////////////////////////////////////////////////////////
          
// Instantiate the FIFO_R
  fifo #(.bits(data_fifo), .depth(depth)) fifo_R( 
                 .rst(sys_rst_l),
                 .pop(pop_R),           // ***desde el bus al uart
                 .push(push_fR),
                 .clk(sys_clk),
                 .Din(D_push_fR), // 10 bytes de datos de entrada             
                 .pndng(pndng_R),       // ***desde el uart hacia el bus 
                 .full(rx_full),                       
                 .Dout(Dout)   // ***desde el uart hacia el bus 10 bytes
              );

endmodule