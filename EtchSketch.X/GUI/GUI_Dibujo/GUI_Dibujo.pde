//UVG Progra de Micros 2020
//Carlos Cuellar 19275
//GUI para proyecto 2; Panel de dibujo

//Importo mi librería para hacer botones
import controlP5.*;
ControlP5 cp5; //Se crea objeto de la librería ControlP5
PFont font; //Habilito la importacion de fuentes

//Importo mi librería para empezar el uso de funciones seriales
import processing.serial.*;
Serial myPort; //Se crea objeto de la librería Serial

int[] datosPIC = new int[2]; //Matriz que va a contener los datos enviados del PIC, cada celda es un BYTE
int xcor; //Coordenada en X
int ycor; //Coordenada en Y
int fill; //Relleno de mi pincel
int cont;  //Aumento dentro del array
boolean aver = false; //Var para sincronizar

void setup(){
 size(256,356); //Tamaño de mi canvas
 background(255); //Fondo blanco
 noStroke(); //No se dibuja
 cp5 = new ControlP5(this); //Empieza creación del boton
 font = createFont("Verdana Negrita Cursiva", 12);    //Importo la fuente a usar en el bot
  
  cp5.addButton("reset")//Nombre del boton
    .setPosition(110, 300)//posicion del boton
    .setSize(50, 50)//dimensiones del boton
    .setFont(font)//Implementación de la fuente en el boton
  ;   
  
 String puerto = Serial.list()[0]; //Ubico que puerto USB estoy usando
 myPort = new Serial(this, puerto, 9600); //BaudRate a la que escucha la compu

}

//Recepcion de datos
void serialEvent(Serial myPort){ 
 int  input = myPort.read();//Leo los bytes que manda mi PIC
 
   datosPIC[cont] = input; //Se agrega cada byte en una celda distinta
   cont++;
   
   //Una vez llena la matriz cada celda pasa a ser el valor de una variable de posicion
   if(cont > 1){
    xcor = datosPIC[0];
    delay(10);
    ycor = datosPIC[1];
    delay(10);
    fill = 0;
    delay(10);
    println(xcor + ", " + ycor); //Se imprimen las coordenadas en el formato requerido
    myPort.write('A'); //Enter en el shell
    cont = 0; //Se reinica el contador para volver a llenar las celdas
   }
 
}

void draw(){
 fill(fill,0,0); //Se selecciona el color de mi pincel (negro)
 ellipse(xcor, ycor, 15, 15); //Se plotean circulos en las coordenadas registradas
}

void reset(){
background(255); //Fondo blanco que se sobrepone a lo que ya habia pintado cuando apache
}
