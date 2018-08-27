`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITCR
// Engineer: Dayhana Sanchez Jimenez
// 
// Create Date: 02/12/2018 09:23:21 AM
// Design Name: UART
// Module Name: baud
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//
// BAUD.v//------------------------------------------------------------
//
// www.cmosexod.com
// 4/13/2001 (c) 2001
// Jeung Joon Lee
//
// This is the "baud-rate-genrator"
// The "uart_clk" is the output clock feeding the
// receiver and transmitter modules of the UART.
//
// By design, the purpose of the "uart_clk" is to 
// take in the "sys_clk" and generate a clock 
// which is 16 x BaudRate, where BaudRate is the
// desired UART baud rate.  
//
// Refer to "inc.h" for the setting of system clock
// and the desired baud rate. -------------------------------------------
// Descripcion: Modulo divisor de la se;al de re;oj
// 
// Dependencias: 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------



module baud #(parameter XTAL_CLK = 20000000, //20MHz es la frec max del micro
                        BAUD = 2400,
                        CLK_DIV = XTAL_CLK / (BAUD * 16 * 2),
                        CW   = 9)(
     input   sys_clk,
     input   sys_rst_l,
     output reg  uart_clk                                
);

reg [CW-1:0] clk_div;

//        CLK_DIV 328

always @(posedge sys_clk or posedge sys_rst_l)
  if (sys_rst_l) begin
    clk_div  <= 0;
    uart_clk <= 0; 
  end 
  else if (clk_div == CLK_DIV) begin
    clk_div  <= 0;
    uart_clk <= ~uart_clk;
  end 
  else begin
    clk_div  <= clk_div + 1;
    uart_clk <= uart_clk;
  end

endmodule
