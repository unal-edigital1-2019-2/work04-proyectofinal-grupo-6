`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:22:05 02/10/2020 
// Design Name: 
// Module Name:    contador 
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
module contador(input in_reset,input inicio,input vsync,input add_cnt,input href, input pclk,output reg [15:0] counter=1, output reg out_reset=0);
  
  
 always @(posedge pclk) begin

if(href==1)
begin //1
if(add_cnt==0 & counter<19200) //19201 add_cnt ES LA SEÑAL add_cnt del conversor QUE PIDE AUMENTAR CONTADOR
begin//2
counter=counter+1;
end//2
end//1

if((counter==19200 & href==0)/*||(in_reset==1)*/) //P
begin//3
out_reset=1;
counter=1;
end//3 
/*
if(inicio==1)
begin //4
out_reset=0;
end//4
*/

end

endmodule 
