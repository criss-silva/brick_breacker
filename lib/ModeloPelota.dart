//  ModeloPelota.dart
//  Estado puro de la pelota: posición, dirección y velocidad.
//  No sabe nada fuera de la estructura.

enum Direcciones { arriba, abajo, izquierda, derecha } //hacia donde va la pelota

class ModeloPelota {
  double x;
  double y;
  Direcciones dirX;
  Direcciones dirY;

  // Velocidad dinámica
  double velocidadX;
  double velocidadY;

  static const double _velInicial    = 0.010;
  static const double _velMaxima     = 0.030; // tope de velocidad
  static const double _incremento    = 0.0008; // cuánto sube por rebote

  ModeloPelota({ //constructor de la pelota
    this.x    = 0,
    this.y    = 0,
    this.dirX = Direcciones.izquierda,
    this.dirY = Direcciones.abajo,
    this.velocidadX = _velInicial,
    this.velocidadY = _velInicial,
  });

  /// Llamar cada vez que la pelota rebota para incrementar la velocidad.
  void acelerar() {
    velocidadX = (velocidadX + _incremento).clamp(0, _velMaxima);
    velocidadY = (velocidadY + _incremento).clamp(0, _velMaxima);
  }

  void resetear() {
    x          = 0;
    y          = 0;
    dirX       = Direcciones.izquierda;
    dirY       = Direcciones.abajo;
    velocidadX = _velInicial;
    velocidadY = _velInicial;
  }
}