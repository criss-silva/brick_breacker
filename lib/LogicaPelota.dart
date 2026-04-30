// ============================================================
//  logica_pelota.dart
//  Funciones puras de movimiento y colisión de la pelota.
//  No importa Flutter. Recibe modelos y devuelve nuevos estados.
// ============================================================

import 'ModeloPelota.dart';
import 'ModeloJugador.dart';

// Constantes de velocidad
const double velocidadBaseX  = 0.01;
const double velocidadBaseY  = 0.01;
const double velocidadLentaX = 0.005;
const double velocidadLentaY = 0.005;

// ------------------------------------------------------------------
// moverPelota
// Avanza la pelota una unidad según su dirección actual.
// [tiempoLento] determina si se usa la velocidad reducida.
// Muta el objeto pelota directamente (estilo del proyecto original).
// ------------------------------------------------------------------
void moverPelota(ModeloPelota pelota, {bool tiempoLento = false}) {
  final double velX = tiempoLento ? velocidadLentaX : velocidadBaseX;
  final double velY = tiempoLento ? velocidadLentaY : velocidadBaseY;

  pelota.y += pelota.dirY == Direcciones.abajo   ?  velY : -velY;
  pelota.x += pelota.dirX == Direcciones.derecha ?  velX : -velX;
}

// ------------------------------------------------------------------
// actualizarDireccion
// Comprueba bordes y raqueta para rebotar la pelota.
// Muta el objeto pelota (dirX / dirY).
// ------------------------------------------------------------------
void actualizarDireccion(ModeloPelota pelota, ModeloJugador jugador) {
  // ---- Vertical ----
  // Techo
  if (pelota.y <= -1) {
    pelota.dirY = Direcciones.abajo;
  }
  // Raqueta
  if (pelota.y >= 0.9 &&
      pelota.x >= jugador.x &&
      pelota.x <= jugador.x + jugador.ancho) {
    pelota.dirY = Direcciones.arriba;
  }

  // ---- Horizontal ----
  if (pelota.x >= 1)  pelota.dirX = Direcciones.izquierda;
  if (pelota.x <= -1) pelota.dirX = Direcciones.derecha;
}

// ------------------------------------------------------------------
// pelotaFueraDePantalla
// Devuelve true si la pelota ha caído por debajo del límite inferior.
// ------------------------------------------------------------------
bool pelotaFueraDePantalla(ModeloPelota pelota) => pelota.y >= 1;