// ============================================================
//  modelo_jugador.dart
//  Estado puro de la raqueta: posición y ancho.
//  No sabe nada de Flutter.
// ============================================================

class ModeloJugador {
  double x;
  double ancho;

  ModeloJugador({
    this.x     = -0.2,
    this.ancho = ModeloJugador.anchoNormal,
  });

  static const double anchoNormal = 0.4;
  static const double anchoGrande = 0.65;

  void resetear() {
    x     = -0.2;
    ancho = anchoNormal;
  }
}