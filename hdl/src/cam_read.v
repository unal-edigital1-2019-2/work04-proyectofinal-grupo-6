`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:14:22 12/02/2019 
// Design Name: 
// Module Name:    cam_read 
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
module cam_read #(
		parameter AW = 15 // Cantidad de bits  de la direccin 
		)(
		input pclk,
		input rst,
		input vsync,
		input href,
		input [7:0] px_data,
      input inicio,
		
		output [AW-1:0] mem_px_addr,
		output [7:0]  mem_px_data,
		output px_wr
   );
	

/********************************************************************************

Por favor colocar en este archivo el desarrollo realizado por el grupo para la 
captura de datos de la camara 

debe tener en cuenta el nombre de las entradas  y salidad propuestas 

********************************************************************************/

wire w0,w1,w3,w5;
reg f1=1;
flip_flopD m1 (.D(f1), .Q(w0), .vsync(vsync),.in_reset(w5));
flip_flopD_bajada m2 (.D(w0), .Q(w1), .vsync(vsync),.in_reset(w5));
conversor1 m3 (.ver(w1),.href(href),.in_dt(px_data),.pclk(pclk),.add_cnt(w3),.out_dt(mem_px_data),.write(px_wr),.in_reset(w5));
contador m5(.in_reset(rst),.inicio(inicio),.add_cnt(w3), .pclk(pclk),.href(href),.counter(mem_px_addr),.out_reset(w5),.vsync(vsync));
cnt_ln_px m6(.in_reset(w5),.write(px_wr), .cont_href(cont_href));
endmodule
