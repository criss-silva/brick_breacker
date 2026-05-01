// ============================================================
//  modelo_pelota.dart
//  Estado puro de la pelota: posición y dirección.
//  No sabe nada de Flutter.
// ============================================================

enum Direcciones { arriba, abajo, izquierda, derecha }

class ModeloPelota {
  double x;
  double y;
  Direcciones dirX;
  Direcciones dirY;

  ModeloPelota({
    this.x    = 0,
    this.y    = 0,
    this.dirX = Direcciones.izquierda,
    this.dirY = Direcciones.abajo,
  });

  void resetear() {
    x    = 0;
    y    = 0;
    dirX = Direcciones.izquierda;
    dirY = Direcciones.abajo;
  }
}