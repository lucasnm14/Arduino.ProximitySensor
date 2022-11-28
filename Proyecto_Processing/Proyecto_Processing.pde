/*  Proyecto - Informática II
 *  Lucas Martínez
 *  UTN FRM - 2021 - 2R5 - Ing. Electrónica
 */
import processing.serial.*; 
Serial Puerto;
String datos;
PrintWriter archivo;

PFont fuente;
HScrollbar  Sgxc, Sdmax, Sman;
boton Br, Bm, Benc;
int dist;
int ang;
int Mang;
int t;
int vel;
int dmax;
int multi;
long tpo = 0;
String distancia;
int ultDist;
int ultAng;
int envio;

void setup (){
  //Puerto = new Serial (this, Serial.list()[0], 9600);
  Puerto = new Serial (this, "COM3", 9600);
  Puerto.bufferUntil ('.');
  
  size (1000, 600);
  background (9, 37, 61);
  ang = 0;
  multi = 1;
  tpo = millis ();
  
  fuente = createFont ("SF.otf", 10);
  textFont (fuente);
  
  Sgxc = new HScrollbar (700, 90 + 70, 200, 18, 3, 0.3);
  Sdmax = new HScrollbar (700, 90 + 2 * 70, 200, 18, 3, 0.2);
  Sman = new HScrollbar (700, 90 + 3 * 70, 200, 18, 3, 0.5);
  
  Br = new boton (700, 340, 200, 40);
  Bm = new boton (700, 400, 200, 40);
  Benc = new boton (700, 460, 200, 40);
  Br.texto ("Grabar");
  Br.textoEnc ("Grabando...");
  Bm.texto ("Automatico");
  Bm.textoEnc ("Manual");
  Benc.texto ("Paro");
  Benc.textoEnc ("Marcha");
}

void draw (){
  // Toma de datos por processing (scrollbar)
  vel = (int) (Sgxc.getPos() - 770) / 20 + 1;
  dmax = ((int) ((Sdmax.getPos() - 770 + 8) * 3 / 2) / 10) * 10;
  Mang = (int) ((Sman.getPos() - 770 - 99) * 0.81) + 90;
  
  // Red de referencias
  noFill ();
  strokeWeight (1);
  stroke (69, 97, 121);
  for (int i = 600; i > 0; i -= 100) arc (350, 350, 600 - i, 600 - i, PI, 2 * PI, CHORD);
  for (int i = 15; i < 166; i += 15) line (350, 350, 350 + cos (i * PI / 180) * 310, 350 - sin (i * PI / 180) * 310);
  strokeWeight (2);
  stroke (112, 224, 208);
  
  //  Fondo para textos
  fill (9, 37, 61);
  noStroke ();
  rect (0, 355, width, height);
  rect (670, 0, width - 650, height);
  
  // Semicirculo principal
  strokeWeight (3);
  stroke (112, 224, 208);
  fill (9, 37, 61, 15); //[ultimo parametro] = Blur de señal
  arc (350, 350, 600, 600, PI, 2 * PI, CHORD);
  
  // Dibujo de linea de distancias
  float factor;
  if (dist < dmax && dist > 0) {
    factor = (float) dist / dmax;
    ultDist = dist;
    ultAng = ang;
  }
  else factor = 1;
  line (350, 
        350, 
        350 - cos (ang * PI / 180) * 300,
        350 - sin (ang * PI / 180) * 300);
  stroke (204, 101, 41);
  if (factor < 1) 
    line (350 - cos (ang * PI / 180) * (300 * factor),
    350 - sin (ang * PI / 180) * (300 * factor),
    350 - cos (ang * PI / 180) * 300,
    350 - sin (ang * PI / 180) * 300);
  
  // Radar
  fill (112, 224, 208);
  noStroke ();
  circle (350, 350, 15);

  // Slidebars
  Sgxc.update ();
  Sgxc.display ();
  Sdmax.update ();
  Sdmax.display ();
  Sman.update ();
  Sman.display ();
  
  // Botones
  Br.dibujar ();
  Bm.dibujar ();
  Benc.dibujar ();
  
  // Salida de textos
  fill (255);
  textSize (16);  //16
  for (int i = 0; i < 6; i++) text((int) dmax - i * (dmax / 6), 637 - i * 50, 375);
  text ("[cm]", 333, 375);
  
  textSize (20);  //20
  text ("Periodo [mS]", 700, 98);
  text (t, 910, 98);
  text ("Grados por ciclo", 700, 70 + 70);
  text (vel, 910, 98 + 70);
  text ("Distancia maxima [cm]", 700, 70 + 2 * 70);
  text (dmax, 910, 98 + 2 * 70);
  text ("Angulo", 700, 70 + 3 * 70);
  if (Bm.enc == true) text (Mang, 910, 98 + 3 * 70);
  
  text ("Angulo: " + ang + "°", 40, 430);
  if ((dist < 2) && (dist > 400)) distancia = "-";
  else distancia = dist + "cm";
  text ("Distancia: " + dist + "cm", 40, 460);
  if (ultDist != 0) text ("Ultimo objeto detectado: " + ultDist + " cm a " + ultAng + "°", 40, 490);
  else text ("Ultimo objeto detectado: No se detectaron objetos", 40, 490);
  
  textSize (30);//30
  text ("Configuracion", 700, 50);
  text ("Salida", 40, 400);
  
  System.out.println (envio);
}

//  Toma y envio de datos (ver formato en código en Arduino)
void serialEvent (Serial Puerto){
  //  Entrada de datos
  datos = Puerto.readStringUntil ('.');
  datos = datos.substring(0, datos.length () - 1);//Borra punto y 'd' inicial
  int inda = datos.indexOf ('a');
  int indt = datos.indexOf ('t');
  dist = int (datos.substring (3, inda));
  ang = int (datos.substring (inda + 1, indt));
  t = int (datos.substring (indt + 1, datos.length ()));
  Benc.enc = false;
  
  /*
    Para el envio de datos, se usara el siguiente protocolo:
    0        ->  Paro/Marcha
    1 a 19   ->  Indicacion de grados por ciclo
    >20      ->  Grados + 20 para el avance manual. En aduino se le restaran 20 para saber los grados
  */
  
  //  Salida de datos
  if (Bm.enc) envio = Mang + 20;
  else envio = vel;
  Puerto.write (envio);
  
  if (Br.enc){
    //  Toma de datos para grabacion
    if (dist < dmax && dist > 3) archivo.println (
      hour () + ":" + minute () + ":" + second () + 
      " -> Deteccion a " + dist + "cm a " + ang + "°");
  }
}

void mousePressed (){
  if (Br.overRect ()){
    Br.enc = !Br.enc;
    if (Br.enc){
      //  Inicio de grabacion
      archivo = createWriter (
        "Radar " + day () + "-" + month () + "-" + year () + " " +
        hour () + ":" + minute () + ":" + second () + ".txt");
      archivo.println (
      "Datos de radar del dia " + day () + "-" + month () + "-" + year () +
      " a partir de las " + hour () + ":" + minute () + ":" + second ());
    }
    else{
      //  Fin de grabacion
      archivo.flush ();
      archivo.close ();
    }
  }
  if (Bm.overRect ()) Bm.enc = !Bm.enc;
  if (Benc.overRect ()) {
    Bm.enc = false;
    Br.enc = false;
    envio = 0;
    Puerto.write (envio);
    Benc.enc = true;
  }
}
