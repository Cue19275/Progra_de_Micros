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

//Importo librería para canción
import processing.sound.*;

//Variables para multimedia de la GUI
int temp;
PImage foto;
SoundFile file;
String cancion = "Jingle.mp3";
String path;
//Variables de SERIALCOM
int[] datosPIC = new int[2]; //Matriz que va a contener los datos enviados del PIC
int valpot;
int ledsend;
int cont;
int bit1;
int bit2;
int bit3;
int bit4;
int bit5;
int send;
int barridos;

void setup(){
  size(400, 420);
  background(200);
  stroke(255);
  strokeWeight(2);
  foto = loadImage("Tree.png");
  path = sketchPath(cancion);
  file = new SoundFile(this, path);
  file.play();
  file.amp(0.2);
  file.loop();
  
  send = 0;
  
  cp5 = new ControlP5(this); //Empieza creación del boton
  font = createFont("Verdana Negrita Cursiva", 12);    //Importo la fuente a usar en el bot
  
  cp5.addButton("LED1")//Nombre del boton
    .setPosition(10, 20)//posicion del boton
    .setSize(380, 20)//dimensiones del boton
    .setFont(font)//Implementación de la fuente en el boton
    .setColorBackground( color( 255,0,0 ) )
  ;   
  cp5.addButton("LED2")
     .setPosition(10, 50)//posicion del boton
    .setSize(380, 20)//dimensiones del boton
    .setFont(font)//Implementación de la fuente en el boton
    .setColorBackground( color( 0,100,0 ) )
    ;
  cp5.addButton("LED3")
     .setPosition(10, 80)//posicion del boton
    .setSize(380, 20)//dimensiones del boton
    .setFont(font)//Implementación de la fuente en el boton
    .setColorBackground( color( 255,0,0 ) )
    ;
   cp5.addButton("NO_LED")
     .setPosition(10, 110)//posicion del boton
    .setSize(380, 20)//dimensiones del boton
    .setFont(font)//Implementación de la fuente en el boton
    .setColorBackground( color( 0,100,0 ) )
    ;
    cp5.addButton("NO_GIRO")
     .setPosition(10, 140)//posicion del boton
    .setSize(380, 20)//dimensiones del boton
    .setFont(font)//Implementación de la fuente en el boton
    .setColorBackground( color( 255,0,0 ) )
    ;
   cp5.addButton("GIRO_LENTO")
     .setPosition(10, 170)//posicion del boton
    .setSize(380, 20)//dimensiones del boton
    .setFont(font)//Implementación de la fuente en el boton
    .setColorBackground( color( 0,100,0 ) )
    ;
    cp5.addButton("RAPIDO")
     .setPosition(10, 200)//posicion del boton
    .setSize(380, 20)//dimensiones del boton
    .setFont(font)//Implementación de la fuente en el boton
    .setColorBackground( color( 255,0,0 ) )
    ;
    
String puerto = Serial.list()[0]; //Ubico que puerto USB estoy usando
myPort = new Serial(this, puerto, 9600);
 
}

void serialEvent(Serial myPort){
int input = myPort.read();
  datosPIC[cont] = input;
  cont++;
  if (cont > 1){
     valpot = datosPIC[0];
     delay(5);
     println(valpot);
     //myPort.write('A');
     cont = 0;
     send = bit1 + bit2 + bit3 + bit4 + bit5;
     myPort.write(send);
     
     
  }
}

 
void draw(){
image(foto, 110, 225, width/2.2, height/2.2);
float playbackSpeed = map(valpot, 0, 255, 0.25, 4.0);
file.rate(playbackSpeed);
  }
  
void LED1(){
  bit1 = 2;
}

void LED2(){
  bit2 =4;
}

void LED3(){
  bit3 = 8;
}

void NO_LED(){
  bit1= 0;
  bit2 = 0;
  bit3 = 0;
}

void NO_GIRO(){
  bit4 = 0;
  bit5 = 0;
}

void GIRO_LENTO(){
  bit4 = 16;
  bit5 = 0;
}

void RAPIDO(){
  bit5 = 32;
  bit4 = 0;
}
