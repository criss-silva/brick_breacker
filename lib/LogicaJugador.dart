//  logica_jugador.dart
//  Movimiento de la raqueta. No importa Flutter.


import 'ModeloJugador.dart';
//cuanto se va a mover
const double _paso = 0.2;

void moverIzquierda(ModeloJugador jugador) { //esto es para moverse con las flechas
  if (jugador.x > -1) jugador.x -= _paso;
}

void moverDerecha(ModeloJugador jugador) {
  if (jugador.x + jugador.ancho < 1) jugador.x += _paso;
}
//este es para moverse con el arrastre del movil
void moverConArrastre(ModeloJugador jugador, double deltaPx, double anchoPantalla) {
  final double delta = deltaPx / (anchoPantalla / 2);
  final double nuevo = jugador.x + delta;
  if (nuevo >= -1 && nuevo + jugador.ancho <= 1) {
    jugador.x = nuevo;
  }
}