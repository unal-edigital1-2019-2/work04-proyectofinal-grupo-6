# GRUPO DE TRABAJO 06
## INTEGRANTES DEL GRUPO
#### Juan Pablo Fiagá Rodríguez   1002461990
#### Iván leonardo Tamayo Pérez   1052394290
#### Juan Alonso Rubiano Portela    80759456

## Objetivos
* Comprobar el funcionamiento del bloque de captura de pixeles realizado en el paquete de trabajo wp02.
* Crear a partir del diagrama funcional, el esquema  de la máquina de estados y su posterior diseño en verylog.
* Encontrar las fallas en el módulo creado y explicar  el por qué sucedían.

## Metodología

Una vez que se ha tenido diseñado el diagrama estructural del programa, se procedió a crear los módulos de tal forma que internamente quedaran de acuerdo al diseño propuesto, es decir, que al momento de realizar el código en el módulo de cam_read_, su pudiera diferenciar que parte pertenecia a la memoria y que parte pertenecía a la lógica combinacional. A continuación, en la siguiente figura se puede observar  el esquema generado en HDL.

![calculos](https://github.com/unal-edigital1-2019-2/work03-smulacion-ov7670-grupo-06/blob/master/docs/figs/esquema%20cam_read_interno.png)


Se pensó en el diseño de 2 flip-flops, uno con flanco de subida y otro con flanco de bajada los cuales detectaban la señal de vsync. Al momento de tomar una foto, estos flip-flops  bloquean  la captura de datos hasta que el usuario pulse un boton (denominado new_photo) y así se realice una nueva captura. Se puede apreciar también el módulo "contador" el cual va realizando la cuenta del número de pixeles capturados y grabados en la RAM. Una vez que se ha tomado la captura completa de la  imagen, este contador bloquea los demás módulos, entre ellos los flip-flops hasta que el usuario decida tomar una nueva foto.

El módulo "conversor" es el encargado de realizar la lógica secuencial encargada de realizar la conversion del formato rgb565 a RGB332, y de pedirle al contador que aumente la cuenta en 1 hasta realizar la captura completa de la imagen. Finalmente, el módulo "cnt_ln_px" es el encargado de realizar el conteo de pixeles en cada linea horizontal de la imagen.

Luego de realizar el módulo de captura de datos (wp02), la metodología para corregir y rediseñar fue crear en primer lugar el diagrama funcional. Este diagrama se puede apreciar en la figura siguiente

![calculos](https://github.com/unal-edigital1-2019-2/work03-smulacion-ov7670-grupo-06/blob/master/docs/figs/diagrama_de_flujo.jpg)

A partir de este diagrama de flujo, se empezó a diseñar la máquina de estados algorítmicos, donde se identificaron 8 estados posibles para el funcionamiento de la captura de datos a partir de las señales de vsync, href, pclk, rst y new_photo. El diagrama de la máquina de estados se presenta a continuacion. 

![calculos](https://github.com/unal-edigital1-2019-2/work03-smulacion-ov7670-grupo-06/blob/master/docs/figs/maquina-de-estados.jpg)

### código:

### código:

#### flip-flops de flanco de subida y bajada conectados en serie para detectar vsync

Estos flip-flops detectan cuando vsync ha realizado un flanco de subida y de bajada para generar la señal "ver" que llega al módulo del conversor. El siguiente es el código del flip-flop de flanco de subida el cual está conectado directamente en su entrada a la señal vsync de la cámara.
```verilog
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
```
Una vez grabada la señal de subida de vsync, la salida de este flip-flop se conecta a la entrada del flip-flop con flanco de bajada para detectar cuando vsync llega a cero y de esta manera dar comienzo a la captura de imagen.
```verilog
module flip_flopD_bajada(D,vsync,in_reset,Q);
input D; // Data input 
input vsync; // clock input 
input in_reset; // asynchronous reset high level 
output reg Q=0; // output Q 
always @(negedge vsync or posedge in_reset) 
begin
 if(in_reset==1)
  //Q <= 1'b0;
Q <= 0;  
 else 
  Q <= D; 
end 
endmodule
```
#### Módulo conversor RGB565 a RGB332

En seguida de esta señal, tenemos el modulo encargado de realizar la conversión de pixeles al formato RGB332, donde se espera que la señal de vsync esté en 1 junto con href e in_reset sea igual a cero. Una vez dadas estas condiciones, en cada pclk igual a 1 se aumenta el contador de flancos cont_flanco. Si el contador lleva la cuenta de un flanco de subida, entonces se carga el primer byte del pixel, y se realiza la primera conversión. luego vuelve y aumenta el contador cont_flanco y en este caso cuando lleva la cuenta de 2 flancos de subida del pclk, entonces carga el segundo byte del pixel y termina de realizar la conversión, es aquí en este punto que se resetea el contador de flancos para predisponerlo para la siguiente conversión. Dentro de este módulo se tiene en cuenta  cuando pclk es igual a cero y el contador de flancos (cont_flanco) es igual a cero, para cargar el byte que tiene el pixel en el formato RGB332 y a su vez se activa la salida write = 1 para grabar este dato en la RAM de la cámara. El siguiente es el código del módulo  conversor1:
```verilog
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
```
 






