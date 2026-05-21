//  logica_powerups.dart
//  Funciones para generar, mover y recoger power-ups.


import 'dart:math';
import 'package:moviles/modelos/barrel_modelos.dart';

const double velocidadCaidaPowerUp = 0.018;

const double probPowerUpNormal = 0.35;


const double probBolaInvencibleAleatoria = 0.08;

final _rng = Random();


void spawnPowerUpFijo(
    List<ModeloPowerUp> lista,
    TipoPowerUp tipo,
    double lx,
    double ly,
    double anchoLadrillo,
    ) {
  lista.add(ModeloPowerUp(
    x: lx + anchoLadrillo / 2,
    y: ly,
    tipo: tipo,
  ));
}


void intentarGenerarPowerUpAleatorio(
    List<ModeloPowerUp> lista,
    double lx,
    double ly,
    double anchoLadrillo,
    ) {
  if (_rng.nextDouble() > probPowerUpNormal) return;

  final TipoPowerUp tipo = _elegirTipoAleatorio();
  lista.add(ModeloPowerUp(
    x: lx + anchoLadrillo / 2,
    y: ly,
    tipo: tipo,
  ));
}
//sacamos un tipo de power up aleatorio seleccionando un indice aleatorio
TipoPowerUp _elegirTipoAleatorio() {
  final double r = _rng.nextDouble();
  if (r < probBolaInvencibleAleatoria) return TipoPowerUp.bolaInvencible;
  // El resto se reparte entre los 3 tipos normales
  final int idx = _rng.nextInt(3);
  return [
    TipoPowerUp.racketaGrande,
    TipoPowerUp.tiempoLento,
    TipoPowerUp.vidaExtra,
  ][idx];
}

// moverPowerUps
// Baja todos los power-ups y elimina los que salen de pantalla
void moverPowerUps(List<ModeloPowerUp> lista) {
  for (final pu in lista) {
    pu.y += velocidadCaidaPowerUp;
  }
  lista.removeWhere((pu) => pu.y > 1.0);
}

// comprobar recogida de los power ups con la raqueta
List<ModeloPowerUp> comprobarRecogida(
    List<ModeloPowerUp> lista,
    ModeloJugador jugador,
    ) {
  final List<ModeloPowerUp> recogidos = lista.where((pu) {
    final bool altura = pu.y >= 0.85 && pu.y <= 0.95;
    final bool dentro = pu.x >= jugador.x && pu.x <= jugador.x + jugador.ancho;
    return altura && dentro;
  }).toList();

  lista.removeWhere(recogidos.contains);
  return recogidos;
}