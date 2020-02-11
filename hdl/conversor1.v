`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:21:23 02/10/2020 
// Design Name: 
// Module Name:    conversor1 
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
module conversor1(input href, input [7:0] in_dt,output reg [7:0] out_dt, input pclk,
input ver,input in_reset,output reg add_cnt=1,output reg write=0 /*input rst*/);
reg [7:0] PX_byte; 
reg [3:0] cont_flanco=0;



always @(*) //en todo flanco de subida del pclk:
begin//a

if(in_reset==1)
begin
cont_flanco=0;
add_cnt=1;
end

if(href==0)//para cargar el dato cuando href sea cero
begin
out_dt<=PX_byte; //cargar dato
write=1;
end

if(ver==1 & href==1 & in_reset==0)//si verificacion de vsync=1 y href=1 
begin//b

if(pclk==1)
begin//0

cont_flanco=cont_flanco+1;
case (cont_flanco)
1:begin //1
add_cnt=1;
write=0;
PX_byte [7:5]<=in_dt [7:5];//se hace la
PX_byte [4:2]<=in_dt [2:0];//primera conversion

end//1

2:begin//2
add_cnt=0;
cont_flanco=0;
write=0;
PX_byte[1:0]<=in_dt[4:3];//cargue el segundo byte

end//2
endcase
end//0

if(pclk==0 & cont_flanco==0)
begin//3
out_dt<=PX_byte; //cargar dato
write=1;
end//3

end//b

end
endmodule
