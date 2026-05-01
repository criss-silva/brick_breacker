// ============================================================
//  logica_pelota.dart
//  Movimiento y colisión de bordes/raqueta de la pelota.
//  No importa Flutter.
// ============================================================

import 'ModeloPelota.dart';
import 'ModeloJugador.dart';

const double velocidadBaseX  = 0.01;
const double velocidadBaseY  = 0.01;
const double velocidadLentaX = 0.005;
const double velocidadLentaY = 0.005;

void moverPelota(ModeloPelota pelota, {bool tiempoLento = false}) {
  final double velX = tiempoLento ? velocidadLentaX : velocidadBaseX;
  final double velY = tiempoLento ? velocidadLentaY : velocidadBaseY;

  pelota.y += pelota.dirY == Direcciones.abajo   ?  velY : -velY;
  pelota.x += pelota.dirX == Direcciones.derecha ?  velX : -velX;
}

void actualizarDireccion(ModeloPelota pelota, ModeloJugador jugador) {
  // Techo
  if (pelota.y <= -1) pelota.dirY = Direcciones.abajo;

  // Raqueta
  if (pelota.y >= 0.9 &&
      pelota.x >= jugador.x &&
      pelota.x <= jugador.x + jugador.ancho) {
    pelota.dirY = Direcciones.arriba;
  }

  // Paredes laterales
  if (pelota.x >= 1)  pelota.dirX = Direcciones.izquierda;
  if (pelota.x <= -1) pelota.dirX = Direcciones.derecha;
}

bool pelotaFueraDePantalla(ModeloPelota pelota) => pelota.y >= 1;