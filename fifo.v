`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC-DCIlab
// Engineer: Dayahana Sanchez Jimenez
// 
// Create Date: 04/12/2018 08:50:43 AM
// Design Name: UART
// Module Name: fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Fifo module used to transmit data from uart to data bus and vice versa. This module is instantiated in uart.v 
// module. This code is based in the code proposed by professor Ronny.

// Descripcion: Modulo fifo utilizado para transmitir los datos provenientes del uart al bus, y viceversa. instanciado en
// el modulo uart.v. Basado en el codigo propuesto por el profesor Ronny.
// 
// Dependencies: modulo prll_d_reg 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
// 29 abril 18 Actualizacion de fifo incorporacion de sys_clk
//////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////
// Definition of the FIFO 
///////////////////////////////////////////////////////////////////////
module fifo #(parameter depth = 16, parameter bits = 64)( //8 bytes
  input [bits-1:0] Din,
  output reg [bits-1:0] Dout,
  input push,
  input pop,
  input clk,
  output reg full,
  output reg pndng,
  input rst
);
    
  wire [bits-1:0] q [depth-1:0];
  reg [$clog2(depth):0] count;
  reg [bits-1:0] aux_mux [depth-1:0];
  reg [bits-1:0] aux_mux_or [depth-2:0];
  
  genvar i;
  generate
    for(i=0;i<depth;i=i+1)begin:_dp_
       if(i==0)begin: _dp2_
         prll_d_reg #(bits) D_reg(.clk(push),.reset(rst),.D_in(Din),.D_out(q[i]));
         always@(*)begin
           aux_mux[i]=(count==i+1)?q[i]:{bits{1'b0}};
         end    
       end else begin: _dp3_
         prll_d_reg #(bits) D_reg(.clk(push),.reset(rst),.D_in(q[i-1]),.D_out(q[i]));
         always@(*)begin
           aux_mux[i]=(count==i+1)?q[i]:{bits{1'b0}};
         end    
       end
    end
  endgenerate

  generate
  for(i=0;i<depth-2;i=i+1)begin:_nu_
    always@(*)begin
      aux_mux_or[i]=aux_mux[i] | aux_mux_or[i+1];
    end
  end
  endgenerate

  always @(*)begin
    aux_mux_or[depth-2] = aux_mux [depth-1]|aux_mux[depth-2];
    Dout=aux_mux_or[0];  
  end

  always @ (posedge clk) begin
      if(rst) begin
        count <= 0;
      end 
      else begin
        case({push,pop})
          2'b00: count <= count;
          2'b01: begin
            if(count == 0) begin
              count <= 0;
            end else begin
              count <=count - 1;
            end
          end
          2'b10:begin
             if(count == depth)begin
               count <= count;
             end else begin
               count <= count+1;
            end
          end
          2'b11: count <= count;
        endcase
      end
    pndng <= (count==0)?{1'b0}:{1'b1};
    full <=(count == depth)?{1'b1}:{1'b0};
  end
endmodule
