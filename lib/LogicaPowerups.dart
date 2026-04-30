// ============================================================
//  logica_powerups.dart
//  Funciones para generar, mover y recoger power-ups.
//  No importa Flutter. Opera sobre ModeloPowerUp y ModeloJugador.
// ============================================================

import 'dart:math';
import 'ModeloJugador.dart';
import 'modelos.dart';

const double velocidadCaidaPowerUp = 0.010;
const double probabilidadPowerUp   = 0.6;

final Random _random = Random();

// ------------------------------------------------------------------
// intentarGenerarPowerUp
// Con probabilidad [probabilidadPowerUp] añade un nuevo power-up a
// [lista] centrado en la posición del ladrillo roto (lx, ly).
// ------------------------------------------------------------------
void intentarGenerarPowerUp(
    List<ModeloPowerUp> lista,
    double lx,
    double ly,
    double anchoLadrillo,
    ) {
  if (_random.nextDouble() > probabilidadPowerUp) return;

  final TipoPowerUp tipo =
  TipoPowerUp.values[_random.nextInt(TipoPowerUp.values.length)];

  lista.add(ModeloPowerUp(
    x: lx + anchoLadrillo / 2,
    y: ly,
    tipo: tipo,
  ));
}

// ------------------------------------------------------------------
// moverPowerUps
// Baja todos los power-ups activos y elimina los que salen de pantalla.
// ------------------------------------------------------------------
void moverPowerUps(List<ModeloPowerUp> lista) {
  for (final pu in lista) {
    pu.y += velocidadCaidaPowerUp;
  }
  lista.removeWhere((pu) => pu.y > 1.0);
}

// ------------------------------------------------------------------
// comprobarRecogida
// Devuelve la lista de power-ups que la raqueta ha recogido en este
// frame (los elimina de [lista] internamente).
// ------------------------------------------------------------------
List<ModeloPowerUp> comprobarRecogida(
    List<ModeloPowerUp> lista,
    ModeloJugador jugador,
    ) {
  final List<ModeloPowerUp> recogidos = lista.where((pu) {
    final bool alturaCorrecta = pu.y >= 0.85 && pu.y <= 0.95;
    final bool dentroRaqueta  = pu.x >= jugador.x && pu.x <= jugador.x + jugador.ancho;
    return alturaCorrecta && dentroRaqueta;
  }).toList();

  lista.removeWhere(recogidos.contains);
  return recogidos;
}