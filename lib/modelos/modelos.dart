


enum TipoPowerUp {
  racketaGrande,   // power up rosa
  tiempoLento,     // power up Azul claro
  vidaExtra,       // power up Amarillo
  bolaInvencible,  // power up morado
}


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