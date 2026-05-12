//  modelo_jugador.dart
//  Estado puro de la raqueta: posición y ancho.
//  Solo es la arquitectura en sí, no sabe nada de lo que pasa fuera de su estructura

class ModeloJugador {
  double x;
  double ancho;

  ModeloJugador({
    this.x     = -0.2,
    this.ancho = ModeloJugador.anchoNormal,
  });

  static const double anchoNormal = 0.4;
  static const double anchoGrande = 0.65;

  void resetear() { //por si usamos algun power up
    x     = -0.2;
    ancho = anchoNormal;
  }
}