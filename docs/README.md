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

El diseño del diagrama estructural de la captura de datos es el que se presenta a continuación.
![calculos](https://github.com/unal-edigital1-2019-2/work04-proyectofinal-grupo-6/blob/master/docs/figs/caja.png)

Una vez que se ha tenido diseñado el diagrama estructural del programa, se procedió a crear los módulos de tal forma que internamente quedaran de acuerdo al diseño propuesto, es decir, que al momento de realizar el código en el módulo de cam_read, se pudiera diferenciar que parte pertenecia a la memoria y que parte pertenecía a la lógica combinacional. A continuación, en la siguiente figura se puede observar  el esquema generado en HDL.

![calculos](https://github.com/unal-edigital1-2019-2/work03-smulacion-ov7670-grupo-06/blob/master/docs/figs/esquema%20cam_read_interno.png)



Se pensó en el diseño de 2 flip-flops, uno con detección de flanco de subida y otro con flanco de bajada los cuales detectaban la señal de vsync. Al momento de tomar una foto, estos flip-flops  bloquean  la captura de datos hasta que el usuario pulse un boton (denominado inicio) y así se realice una nueva captura. Se puede apreciar también el módulo "contador" el cual va realizando la cuenta del número de pixeles capturados y grabados en la RAM. Una vez que se ha tomado la captura completa de la  imagen, este contador bloquea los demás módulos, entre ellos los flip-flops hasta que el usuario decida tomar una nueva foto.

El módulo "conversor" es el encargado de realizar la lógica secuencial encargada de hacer la conversion del formato rgb565 a RGB332, y de pedirle al contador que aumente la cuenta en 1 hasta obtener la captura completa de la imagen. Finalmente, el módulo "cnt_ln_px" es el encargado de realizar el conteo de pixeles en cada linea horizontal de la imagen.

Luego de realizar el módulo de captura de datos (wp02), la metodología para corregir y rediseñar fue crear en primer lugar el diagrama funcional. Este diagrama se puede apreciar en la figura siguiente

![calculos](https://github.com/unal-edigital1-2019-2/work04-proyectofinal-grupo-6/blob/master/docs/figs/Doc2%20(1).jpg)

A partir de este diagrama de flujo, se empezó a diseñar la máquina de estados algorítmicos, donde se identificaron 8 estados posibles para el funcionamiento de la captura de datos a partir de las señales de vsync, href, pclk, rst e inicio. El diagrama de la máquina de estados se presenta a continuacion. 

![calculos](https://github.com/unal-edigital1-2019-2/work04-proyectofinal-grupo-6/blob/master/docs/figs/maquina-de-estados%20(1).jpg)

### Bloque de captura

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

En seguida de esta señal, tenemos el modulo encargado de realizar la conversión de pixeles al formato RGB332, donde se espera que la señal de vsync esté en 1 junto con href=1 e in_reset=0. Una vez dadas estas condiciones, en cada pclk igual a 1 se aumenta el contador de flancos cont_flanco. Si el contador lleva la cuenta de un flanco de subida, entonces se carga el primer byte del pixel, y se realiza la primera conversión. Luego vuelve y aumenta el contador cont_flanco y en este caso cuando lleva la cuenta de 2 flancos de subida del pclk, se carga el segundo byte del pixel y termina de realizar la conversión. Es aquí en este punto que se resetea el contador de flancos y se predispone para la siguiente conversión. Dentro de este módulo se tiene en cuenta  cuando pclk es igual a cero y el contador de flancos (cont_flanco) es igual a cero, para cargar el byte que tiene el pixel en el formato RGB332 y a su vez se activa la salida write = 1 para grabar este dato en la RAM de la cámara. El siguiente es el código del módulo  conversor1:
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

### Módulo contador de pixeles

En este módulo se aumenta el valor del contador a medida que se termina de cargar el byte que contiene el pixel en formato RGB332 en la memoria RAM de la cámara. La señal de salida  add_cnt=0 que proviene del módulo conversor, llega a add_cnt declarado como una entrada en el modulo contador. Si esta entrada es igual a cero, entonces se aumenta en 1 el valor del contador; si es igual a cero, entonces se espera hasta que se cargue un nuevo byte a la memoria. Una vez alcanzado el tope máximo del contador, es decir, 19200 entonces se carga este último byte y luego cuando href sea igual a cero se reinicia el contador y además se activa una señal de salida out_reset=1 que bloquea a los flip flops de vsync hasta que el usuario active un boton de entrada denominado inicio que llega a la entrada inicio del módulo contador de pixeles para realizar una nueva captura de imagen.

```verilog

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
```
### contador de pixeles de línea
 
Finalmente, el módulo cnt_ln_px se encarga de contar cuantos pixeles son grabados en cada linea horizontal de la pantalla. La condición básica es que si está activo write=1 y la variable cont_href es menor a 123 entonces aumente la cuenta en uno hasta llegar al tope maximo y luego se resetea e inicia una nueva cuenta.
```verilog
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
```


### Configuración de la cámara (Arduino)

Para la configuración de la cámara se utilizó arduino implementando el siguiente código para la configuración de registros, COM7, COM3, COM15, etc...
```arduino
   
  OV7670_write(0x12, 0x80);

  delay(100);
 
 OV7670_write(0x12, 0x0C);  //COM7: Set QCIF and RGB
 OV7670_write(0x11, 0xC0);       //CLKR: Set internal clock to use external clock
 OV7670_write(0x0C, 0x08);       //COM3: Enable Scaler
 OV7670_write(0x3E, 0x00);
 OV7670_write(0x40,0xD0);      //COM15: Set RGB 565

 //Color Bar
 //OV7670_write(0x42, 0x08); 
 //OV7670_write(0x12, 0x0E);


 //Registros Mágicos 
OV7670_write(0x3A,0x04);

 OV7670_write(0x14,0x18); // control de ganancia 


```



## simulaciones (TestBench):



### primeros resultados:

Luego de tener diseñado el módulo de captura de datos de la camara, se simuló para determinar las primeras fallas posibles. En la primera prueba se obtuvo el siguiente resultado, en donde se evidencia que hubo un problema con la inicializacion de las variables.

![calculos](https://github.com/unal-edigital1-2019-2/work03-smulacion-ov7670-grupo-06/blob/master/docs/figs/primer%20resultado%20simulacion.png)


En un principio se quería que el contador de pixeles empezara desde 0 hasta 19199. Sin embargo, el contador en el primer flanco de subida hacía que la cuenta empezara no en cero sino en uno, por lo que se decició inicializar la variable counter en -1, lo cual es un error, puesto que es indicarle al contador que empiece desde "11111111", rellenando así por fuera del marco de prueba con pixeles de color rojo. Para ines prácticos, se decidió hacer que el contador empezara desde 1 hasta 19200.

```verilog

module contador(input in_reset,input inicio,input vsync,input add_cnt,input href, input pclk,output reg [15:0] counter=-1, output reg out_reset=0);
  
```
En cuanto al recuadro de 120*160, el cual solo tomaba algunos pixeles rojos, se analizó el porqué se obtuvo el resultado que se aprecia en la imagen anterior. Se encontró en la gráfica de tiempos de la simulación que en el momento cuando href cambiaba su estado de 1 a 0, es decir, en el flanco de bajada de href, ese ultimo pixel no quedaba guardado donde correspondía, el cual se gurdaba en el primero de la siguiente linea. Fue necesario cambiar el módulo que realizaba la conversión a 332, para que tomara el último pixel cuando href fuese 0.

```verilog

if(href==0)//para cargar el dato cuando href sea cero
begin
out_dt<=PX_byte; //cargar dato
write=1;
end
```

![calculos](https://github.com/unal-edigital1-2019-2/work03-smulacion-ov7670-grupo-06/blob/master/docs/figs/segundo%20resultado.png)


Al corregir estos dos problemas principales,finalmente se obtuvo la simulación deseada, la cual se puede ver en la siguiente figura:

![calculos](https://github.com/unal-edigital1-2019-2/work03-smulacion-ov7670-grupo-06/blob/master/docs/figs/3er%20resultado.png)

como última prueba se quizo hacer un ensayo de forma particular, en el que la variable counter (que cuenta el número de pixeles)  se le bajo el máximo número que cuenta.  Esta variable se modificó de tal manera que el recuadro 120*160 mostrara un 80%  de rojo y el resto debía salir la imagen que venía por defecto. Por lo tanto, se modifico el contador para que este llegara hasta 15360 y no hasta 19200. Esto se realizó para comprobar que el contador paraba hasta cierto número máximo, y el resultado de esa simulacion se muestra a continuación.


![calculos](https://github.com/unal-edigital1-2019-2/work03-smulacion-ov7670-grupo-06/blob/master/docs/figs/4er%20resultado.png)


### Resultados laboratorio:

Una vez implementado el código y sintetizado, se cargó en la fpga NEXYS 4. Al parecer, debido a problemas con la señal del pulso de reloj del pclk o del xclk, no se pudo obtentener la imagen esperada pues se obtuvo la imagen que viene por defecto en el paquete de trabajo. Se intentó cambiar la configuración del clock con la misma que tenían otros compañeros a quienes si les funcionó, pero se obtuvo el mismo resultado.

![calculos](https://github.com/unal-edigital1-2019-2/work04-proyectofinal-grupo-6/blob/master/docs/figs/IMG_20200210_151628.jpg)

![calculos](https://github.com/unal-edigital1-2019-2/work04-proyectofinal-grupo-6/blob/master/docs/figs/IMG_20200210_151633.jpg)

![calculos](https://github.com/unal-edigital1-2019-2/work04-proyectofinal-grupo-6/blob/master/docs/figs/IMG_20200210_151636.jpg)

En la siguiente imagen se puede apreciar que si bien la simulacion funcionaba correctamente, al momento de cargar el código, se obtenía la imagen precargada en el paquete de trabajo.

![calculos](https://github.com/unal-edigital1-2019-2/work04-proyectofinal-grupo-6/blob/master/docs/figs/IMG_20200210_165046.jpg)







