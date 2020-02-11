`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:22:37 02/10/2020 
// Design Name: 
// Module Name:    cnt_ln_px 
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
module cnt_ln_px(input write,input in_reset,output reg [7:0] cont_href=0
    );
always @(*) 
begin	 
if(write==1 & cont_href<123) //PL ES LA SEÑAL Z QUE PIDE AUMENTAR CONTADOR
begin//1
cont_href=cont_href+1;
end//1
if(cont_href==123 || in_reset==1) 
begin//2
cont_href=0;
end//2

end
endmodule
