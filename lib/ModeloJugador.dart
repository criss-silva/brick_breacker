// ============================================================
//  modelo_jugador.dart
//  Representa el estado puro de la raqueta: posición y ancho.
//  No sabe nada de Flutter ni de widgets.
// ============================================================

class ModeloJugador {
  // Posición horizontal en unidades Alignment (-1.0 a 1.0)
  double x;

  // Ancho en unidades Alignment (0.0 a 2.0)
  double ancho;

  ModeloJugador({
    this.x     = -0.2,
    this.ancho = ModeloJugador.anchoNormal,
  });

  // Anchos predefinidos (constantes de clase para que la lógica
  // pueda referenciarlos sin necesitar una instancia)
  static const double anchoNormal = 0.4;
  static const double anchoGrande = 0.65;

  void resetear() {
    x     = -0.2;
    ancho = anchoNormal;
  }
}