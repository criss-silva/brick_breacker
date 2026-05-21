//  logica_jugador.dart


import 'package:moviles/modelos/barrel_modelos.dart';
//cuanto se va a mover
const double _paso = 0.2;

void moverIzquierdajugador(ModeloJugador jugador) { //esto es para moverse con las flechas
  if (jugador.x > -1) jugador.x -= _paso;
}

void moverDerechajugador(ModeloJugador jugador) {
  if (jugador.x + jugador.ancho < 1) jugador.x += _paso;
}
//este es para moverse con el arrastre del movil
void moverConArrastrejugador(ModeloJugador jugador, double deltaPx, double anchoPantalla) {
  final double delta = deltaPx / (anchoPantalla / 2);
  final double nuevo = jugador.x + delta;
  if (nuevo >= -1 && nuevo + jugador.ancho <= 1) {
    jugador.x = nuevo;
  }
}