// ============================================================
//  modelos.dart
//  Modelos de datos de los power-ups.
//
//  TIPOS DE POWER-UP:
//  ┌─────────────────┬──────────┬──────────────────────────────┐
//  │ TipoPowerUp     │ Color    │ Efecto                        │
//  ├─────────────────┼──────────┼──────────────────────────────┤
//  │ racketaGrande   │ Rosa     │ Ensancha la raqueta 7 s       │
//  │ tiempoLento     │ Azul     │ Ralentiza la pelota 7 s       │
//  │ vidaExtra       │ Amarillo │ Suma una vida (máx 5)         │
//  │ bolaInvencible  │ Morado   │ La pelota rompe todo de un    │
//  │                 │          │ golpe durante 5 s. Baja prob. │
//  └─────────────────┴──────────┴──────────────────────────────┘
// ============================================================

enum TipoPowerUp {
  racketaGrande,   // Rosa
  tiempoLento,     // Azul claro
  vidaExtra,       // Amarillo
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