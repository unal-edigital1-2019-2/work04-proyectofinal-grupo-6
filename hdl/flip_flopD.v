`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:19:46 02/10/2020 
// Design Name: 
// Module Name:    flip_flopD 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module flip_flopD (D,vsync,in_reset,Q);
input D; // Data input 
input vsync; // clock input 
input in_reset; // asynchronous reset high level
output reg Q=0; // output Q 
always @(posedge vsync or posedge in_reset) 
begin
if(in_reset==1)
  Q <= 0; 
 else 
  Q <= D; 
end 
endmodule
