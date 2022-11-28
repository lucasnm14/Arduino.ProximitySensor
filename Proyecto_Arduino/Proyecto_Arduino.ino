/*  Proyecto - Informática II
 *  Lucas Martinez
 *  UTN FRM - 2021 - 2R5 - Ing. Electronica
 */

#include <LiquidCrystal.h>
#include <Servo.h>
LiquidCrystal lcd(2,3,4,5,6,7);
Servo motor;
int posMot;
int MposMot;
int sTrigger = 9;
int sEcho = 8;
int trigger = 11;

int potenciometro = A0;
int potEnt;

int d; //Distancia medida
int sum[3];
const int dMax = 310; //Distancia máxima absoluta por el sensor (por datasheet)
const int dMin = 4; //Distancia mínima absoluta del sensor (por experimentos propios)
int t = 50; //Intervalo de tiempo entre cada medición en ms
int vel = 3; //Paso del servomotor (grados de avance por cada medida)
bool rev = false; // Permite que el servo se datoorra en sentido inverso al llegar a cierto angulo

int antBP = 0;
int BP = 0;
int tpo = 1;
float tactual = 0;
int dato;
int estado = 0;

// Conexiones

/* LCD      4   6   11  12  13  14
 * Arduino  2   3   4   5   6   7
 */

/*
 * A0 -> Potenciometro de velocidad
 * 10 -> Controlador servomotor (blanco)
 * 11 -> Pulsador ON/OFF
 */

/*
 * Sensor   marron  rojo  naranja amarillo
 * Arduino  gnd     8     9       5v VCC
 * estados: Distancia mínima: 4 cm
 *        Distancia máxima absoluta: 3100 cm
 */

void setup() {
  Serial.begin(9600);
  lcd.begin(16,2);
  pinMode(sTrigger,OUTPUT);
  pinMode(sEcho,INPUT);
  pinMode(trigger,INPUT);
  digitalWrite(sTrigger,LOW);
  motor.attach(10);
  posMot = map(posMot, 0, 1023, 0, 179);
}

void loop() {
  // Toma de estados pulsador de paro/marcha
  BP = digitalRead(trigger);
  if(BP == HIGH && antBP == LOW){
    lcd.clear();
    if(estado < 1) estado = 3;
    else estado = 0;
  }
  
  if(estado != 0){
    //  Toma de estados del sensor ultrasonico
    //  Automatico
    if(estado > 0 && estado < 20){
          if (tpo == 1){
            vel = estado;
            //  Giro al llegar a los angulos maximos y minimos
            if(posMot > 175) {
              posMot = 175;  
              rev = true;
            }
            else if(posMot < 5){
              posMot = 5;
              rev = false;
            }
            motor.write(posMot);
            digitalWrite(sTrigger,HIGH);
            tpo = 2;
          }
          if (tpo == 2 && millis() > tactual + 5){
              digitalWrite(sTrigger,LOW);
              sum[0] = pulseIn(sEcho,HIGH)/59;
              tpo = 3;
              digitalWrite(sTrigger,HIGH);
          }
          if (tpo == 3 && millis() > tactual + 10){
              digitalWrite(sTrigger,LOW);
              sum[1] = pulseIn(sEcho,HIGH)/59;
              tpo = 4;
              digitalWrite(sTrigger,HIGH);
          }
          if (tpo == 4 && millis() > tactual + 15){
              digitalWrite(sTrigger,LOW);
              sum[2] = pulseIn(sEcho,HIGH)/59;
              
              for(int i = 0; i < 3; i ++) d += sum[i];
              d /= 3.8;
               //  Limpieza de LCD (solo medidas)
              lcd.setCursor(5,0);
              lcd.print("   ");
              lcd.setCursor(14,0);
              lcd.print("  ");
              lcd.setCursor(4,1);
              lcd.print("   ");
              lcd.setCursor(11,1);
              lcd.print("     ");
              
              //  Salida de estados por LCD
              lcd.setCursor(0,0);
              lcd.print("D:");
              if(d < dMax){lcd.print(d);
                           lcd.print("cm");}
              else lcd.print(" -   ");
          
              lcd.setCursor(9,0);
              lcd.print("Ang:");
              lcd.print(posMot);
              
              lcd.setCursor(0,1);
              lcd.print("P:");
              lcd.print(t);
              lcd.print("ms");
              lcd.setCursor(9,1);
              lcd.print("V:");
              lcd.print(vel);

              /*  Envio de estados
               *  Formato: d[distancia]a[angulo]t[paso].
               *  Ejemplo: d50a47t50.
               *     Objeto detectado con distancia 50cm a 47° con 50ms entre medicion avanzando 6 grados por cada una
               *  Atencion: El punto indica el fin de la cadena
               */
            
               Serial.print("d");
               Serial.print(d);
               Serial.print("a");
               Serial.print(posMot);
               Serial.print("t");
               Serial.print(t);
               Serial.print(".");
               Serial.println();
               tpo = 5;
          }
        
          //  Espera hasta proximo escaneo e inversion del sentido
          if(tpo == 5 && millis() > tactual + t){
            if(rev) posMot -= vel;
            else posMot += vel;
            tpo = 1;
            tactual = millis();
            if(dato != 0)estado = dato;
          }
     }
     if(estado > 20){
            if(tpo == 1){            
              motor.write(posMot);
              digitalWrite(sTrigger,HIGH);
              tpo = 2; 
            }
            if (tpo == 2 && millis() > tactual + 10){
                posMot = estado - 20;
                motor.write(posMot);
                digitalWrite(sTrigger,LOW);
                sum[0] = pulseIn(sEcho,HIGH)/59;
                digitalWrite(sTrigger,HIGH);
                tpo = 3;
            }
            if (tpo == 3 && millis() > tactual + 20){
                digitalWrite(sTrigger,LOW);
                sum[1] = pulseIn(sEcho,HIGH)/59;
                tpo = 4;
                digitalWrite(sTrigger,HIGH);
            }
            if (tpo == 4 && millis() > tactual + 30){
                digitalWrite(sTrigger,LOW);
                sum[2] = pulseIn(sEcho,HIGH)/59;
                
                for(int i = 0; i < 3; i ++) d += sum[i];
                d /= 3.8;
                
                 //  Limpieza de LCD (solo medidas)
                lcd.setCursor(5,0);
                lcd.print("   ");
                lcd.setCursor(14,0);
                lcd.print("  ");
                lcd.setCursor(4,1);
                lcd.print("   ");
                lcd.setCursor(11,1);
                lcd.print("     ");
                
                //  Salida de estados por LCD
                lcd.setCursor(0,0);
                lcd.print("D:");
                if(d < dMax){lcd.print(d);
                             lcd.print("cm");}
            
                lcd.setCursor(9,0);
                lcd.print("Ang:");
                lcd.print(posMot);
                
                lcd.setCursor(0,1);
                lcd.print("Manual        ");
  
                //  Envio de estados
                 Serial.print("d");
                 Serial.print(d);
                 Serial.print("a");
                 Serial.print(posMot);
                 Serial.print("t");
                 Serial.print(t);
                 Serial.print(".");
                 Serial.println();
                 tpo = 5;
            }
            if(tpo == 5 && millis() > tactual + 50) {
                tpo = 1;
                tactual = millis();
                estado = dato;
            }
          }
  }
  else{
    lcd.setCursor(0,0);
    lcd.print("Proyecto radar");
    lcd.setCursor(0,1);
    lcd.print("Estado: Paro");
  }
  
  antBP = BP;
  //  Toma de estados del paso (tiempo entre escaneos)
  potEnt = analogRead(potenciometro);
  t = ((int)(potEnt / 10.22) * 2) + 17;
}

void serialEvent(){
  if (Serial.available() > 0){
    dato = Serial.read();
  }
  if(dato == 0){
    lcd.clear();
    if(estado < 1) {
      estado = 3;
    }
    else estado = 0;
  }
}
