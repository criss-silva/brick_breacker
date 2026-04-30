// ============================================================
//  modelos.dart
//  Modelos de datos de los power-ups.
//  Los modelos de pelota, jugador y ladrillo están en sus
//  propios archivos (modelo_pelota.dart, etc.).
// ============================================================

// TipoPowerUp
// Enumerado con los tres tipos de power-up que existen en el juego.
enum TipoPowerUp {
  racketaGrande, // Rosa     → raqueta más grande
  tiempoLento,   // Azul     → ralentiza la pelota
  vidaExtra,     // Amarillo → suma una vida (máximo 5)
}

// ModeloPowerUp
// Representa UN power-up concreto que está cayendo por la pantalla.
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