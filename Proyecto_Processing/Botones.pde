class boton {
  int x, y;
  boolean enc;
  int ancho;
  int alto;
  String texto;
  String textoEnc;
  
  boton(int cx, int cy, int wi, int he){
    x = cx;
    y = cy;
    ancho = wi;
    alto = he;
  }
  
  boolean overRect(){
  if (mouseX >= x && mouseX <= x+ancho && mouseY >= y && mouseY <= y+alto) {
    return true;
  }
  else return false;
  }
  
  void dibujar(){
    stroke(112,224,208);
    fill(9,37,61);
    if(enc) fill(18,74,122);
    rect(x,y,ancho,alto);
    fill(255);
    textSize(20);
    if(!enc)text(texto,x+30,y+30);
    else text(textoEnc,x+30,y+30);
    fill(9,37,61);
  }
  
  void texto(String cad) {
    texto = cad;
    textoEnc = cad;
  }

  void textoEnc(String cad) {
    textoEnc = cad;
  }
}
