// ============================================================
//  logica_jugador.dart
//  Movimiento de la raqueta. No importa Flutter.
// ============================================================

import 'ModeloJugador.dart';

const double _paso = 0.2;

void moverIzquierda(ModeloJugador jugador) {
  if (jugador.x > -1) jugador.x -= _paso;
}

void moverDerecha(ModeloJugador jugador) {
  if (jugador.x + jugador.ancho < 1) jugador.x += _paso;
}

void moverConArrastre(ModeloJugador jugador, double deltaPx, double anchoPantalla) {
  final double delta = deltaPx / (anchoPantalla / 2);
  final double nuevo = jugador.x + delta;
  if (nuevo >= -1 && nuevo + jugador.ancho <= 1) {
    jugador.x = nuevo;
  }
}