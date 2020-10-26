//UVG Progra de Micros 2020
//Carlos Cuellar 19275
//GUI para proyecto 2; Panel de dibujo

//Importo mi librería para hacer botones
import controlP5.*;
ControlP5 cp5;

//Importo mi librería para empezar el uso de funciones seriales
import processing.serial.*;
Serial myPort;

int[] datosPIC = new int[3];
int xcor; //Coordenada en X
int ycor; //Coordenada en Y
int fill; //Relleno de mi pincel
int cont;  //Aumento dentro del array
boolean aver = false; //Var para sincronizar

void setup(){
 size(256,256); //Tamaño de mi canvas
 background(255); //Fondo blanco
 noStroke(); //No se dibuja
 cp5 = new ControlP5(this);
 
 String puerto = Serial.list()[0]; //Ubico que puerto USB estoy usando
 myPort = new Serial(this, puerto, 9600);

}

//Recepcion de datos
void serialEvent(Serial myPort){ 
 int  input = myPort.read();
 //println(input);
 
   datosPIC[cont] = input;
   cont++;
   
   if(cont > 2){
    xcor = datosPIC[0];
    delay(10);
    ycor = datosPIC[1];
    delay(10);
    fill = 0;
    delay(10);
    println(xcor + ", " + ycor);
    myPort.write('A');
    cont = 0;
   }
 
}

void draw(){
 fill(fill,0,0);
 ellipse(xcor, ycor, 15, 15);
}
