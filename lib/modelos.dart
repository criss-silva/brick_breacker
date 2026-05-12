//  modelos.dart
//  Modelos de datos de los power-ups.


enum TipoPowerUp {
  racketaGrande,   // power up rosa
  tiempoLento,     // power up Azul claro
  vidaExtra,       // power up Amarillo
  bolaInvencible,  // Morado — rompe cualquier bloque de 1 golpe
}

/// Representa un power-up cayendo por la pantalla
class ModeloPowerUp {
  double x;
  double y;
  final TipoPowerUp tipo;

  ModeloPowerUp({
    required this.x,
    required this.y,
    required this.tipo,
  });
}