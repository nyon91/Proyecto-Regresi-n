`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITCR
// Engineer: Dayhana Sanchez Jimenez
// 
// Create Date: 04/16/2018 05:41:06 PM
// Design Name: UART
// Module Name: prll_d_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Descripcion: Registro paralelo parametrizado
// 
// Dependencies: 
// Dependencias: Depende de un registro sencillo tipo d de 1 bit
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////
// Definition of the prll D register 
///////////////////////////////////////////////////////////////////////

module prll_d_reg #(parameter bits = 32)(
  input clk,
  input reset,
  input [bits-1:0] D_in,
  output [bits-1:0] D_out
);
  genvar i;
  generate
    for(i = 0; i < bits; i=i+1) begin:bit_
      dff_async_rst prll_regstr_(.data(D_in[i]),.clk(clk),.reset(reset),.q(D_out[i]));
    end
  endgenerate
endmodule

////////////////////////////////////////////////////////////////////////
// Definicion de Flip Flop D asincrono
////////////////////////////////////////////////////////////////////////
  
module dff_async_rst (
    input data,
    input clk,
    input reset,
    output reg q
);

always @ ( posedge clk or posedge reset)
  if (reset) begin
    q <= 1'b0;
  end  else begin
    q <= data;
  end

endmodule
