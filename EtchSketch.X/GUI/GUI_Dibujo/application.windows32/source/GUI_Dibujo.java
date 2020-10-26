import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class GUI_Dibujo extends PApplet {

//UVG Progra de Micros 2020
//Carlos Cuellar 19275
//GUI para proyecto 2; Panel de dibujo

//Importo mi librería para hacer botones

ControlP5 cp5; //Se crea objeto de la librería ControlP5
PFont font; //Habilito la importacion de fuentes

//Importo mi librería para empezar el uso de funciones seriales

Serial myPort; //Se crea objeto de la librería Serial

int[] datosPIC = new int[2]; //Matriz que va a contener los datos enviados del PIC, cada celda es un BYTE
int xcor; //Coordenada en X
int ycor; //Coordenada en Y
int xsend; //BYTE 1 DE Envío de X al PIC
int ysend; //BYTE 2 DE Envío de Y al PIC
int sendf; //Sostiene ambos BYTES de envío al PIC
int fill; //Relleno de mi pincel
int fill2;//Relleno de mi pincel
int fill3;//Relleno de mi pincel
int cont;  //Aumento dentro del array
int flag; //Bandera para MUX de envío

//Condiciones iniciales del programa
public void setup(){
  //Tamaño de mi canvas
 background(255); //Fondo blanco
 fill = 0; //Valores iniciales de mi pincel (negro)
 fill2 = 0;
 fill3 = 0;
 flag = 0; //Variable para multiplexar el envío de datos
 noStroke(); //No se dibuja
 cp5 = new ControlP5(this); //Empieza creación del boton
 font = createFont("Verdana Negrita Cursiva", 12);    //Importo la fuente a usar en el bot
  
  cp5.addButton("reset")//Nombre del boton
    .setPosition(10, 270)//posicion del boton
    .setSize(230, 20)//dimensiones del boton
    .setFont(font)//Implementación de la fuente en el boton
  ;   
  cp5.addButton("azul")
     .setPosition(190, 300)//posicion del boton
    .setSize(50, 50)//dimensiones del boton
    .setFont(font)//Implementación de la fuente en el boton
    ;
  cp5.addButton("negro")
     .setPosition(10, 300)//posicion del boton
    .setSize(50, 50)//dimensiones del boton
    .setFont(font)//Implementación de la fuente en el boton
    ;
   cp5.addButton("verde")
     .setPosition(70, 300)//posicion del boton
    .setSize(50, 50)//dimensiones del boton
    .setFont(font)//Implementación de la fuente en el boton
    ;
    cp5.addButton("cyan")
     .setPosition(130, 300)//posicion del boton
    .setSize(50, 50)//dimensiones del boton
    .setFont(font)//Implementación de la fuente en el boton
    ;
  
 String puerto = Serial.list()[0]; //Ubico que puerto USB estoy usando
 myPort = new Serial(this, puerto, 9600); //BaudRate a la que escucha la compu

}

//Recepcion de datos
public void serialEvent(Serial myPort){ 
 int  input = myPort.read();//Leo los bytes que manda mi PIC
 
   datosPIC[cont] = input; //Se agrega cada byte en una celda distinta
   cont++;
   
   //Una vez llena la matriz cada celda pasa a ser el valor de una variable de posicion
   if(cont > 1){
    xcor = datosPIC[0]; //Asigno el primer valor recibido por el pic
    delay(5);
    ycor = datosPIC[1]; //Asigno el segundo valor recibido por el pic
    delay(5);
    println(xcor + ", " + ycor); //Se imprimen las coordenadas en el formato requerido
    myPort.write('A'); //Enter en el shell
    cont = 0; //Se reinica el contador para volver a llenar las celdas
    xsend = PApplet.parseInt(map(xcor, 0, 255, 0, 15)); //Mapeo de variables para enviarl la posicion al pic
    ysend = 16*PApplet.parseInt(map(ycor, 0, 255, 0, 15));
    sendf = ysend+xsend; //Combinacion de los dos nibbles de envío
    if(flag == 0){ //MUX de envío
      myPort.write(sendf); //Acción de envío de la variable senf hacia el pic
      flag = 1;
      delay(5);
    } else {
      //myPort.write(ysend);
      flag = 0;
    }
   }
}

public void draw(){
 fill(fill,fill2,fill3); //Se selecciona el color de mi pincel
 ellipse(xcor, ycor, 15, 15); //Se plotean circulos en las coordenadas registradas
}

public void reset(){
background(255); //Fondo blanco que se sobrepone a lo que ya habia pintado cuando apache
}

public void azul(){ //Acción de cada boton, modifican las variables de relleno del pincel
  fill = 0;
 fill2 = 0;
 fill3 = 200; 
}
public void verde(){
  fill = 0;
 fill2 = 200;
 fill3 = 0; 
}

public void negro(){
  fill = 0;
 fill2 = 0;
 fill3 = 0; 
}

public void cyan(){
  fill = 0;
 fill2 = 250;
 fill3 = 250; 
}


  public void settings() {  size(256,356); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "GUI_Dibujo" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
