//  LogicaPelota.dart
//  Movimiento y colisión de bordes/raqueta de la pelota.
//  No importa Flutter.

import 'package:moviles/modelos/barrel_modelos.dart';


const double _factorLento = 0.5;

void moverPelota(ModeloPelota pelota, {bool tiempoLento = false}) {
  final double factor = tiempoLento ? _factorLento : 1.0;
  final double velX   = pelota.velocidadX * factor;
  final double velY   = pelota.velocidadY * factor;

  pelota.y += pelota.dirY == Direcciones.abajo   ?  velY : -velY;
  pelota.x += pelota.dirX == Direcciones.derecha ?  velX : -velX;
}

void actualizarDireccion(ModeloPelota pelota, ModeloJugador jugador) {

  if (pelota.y <= -1) {
    pelota.dirY = Direcciones.abajo;
    pelota.acelerar();
  } // acelera cuando rebota con un bloque

  if (pelota.y >= 0.9 &&
      pelota.x >= jugador.x &&
      pelota.x <= jugador.x + jugador.ancho) {
    pelota.dirY = Direcciones.arriba;
  }

  if (pelota.x >= 1) {
    pelota.dirX = Direcciones.izquierda;
  }
  if (pelota.x <= -1) {
    pelota.dirX = Direcciones.derecha;

  }
}

bool pelotaFueraDePantalla(ModeloPelota pelota) => pelota.y >= 1;