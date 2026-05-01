// ============================================================
//  logica_powerups.dart
//  Funciones para generar, mover y recoger power-ups.
//  No importa Flutter.
//
//  NOTAS DE DISEÑO:
//  - bolaInvencible tiene probabilidad propia más baja.
//  - Los bloques pw* sueltan SIEMPRE su power-up al romperse
//    (eso lo decide logica_ladrillos). Esta función solo se usa
//    para ladrillos normales/regeneradores que sueltan power-ups
//    aleatorios con probabilidad.
//  - La velocidad de caída es más rápida que en la versión anterior.
// ============================================================

import 'dart:math';
import 'ModeloJugador.dart';
import 'modelos.dart';

const double velocidadCaidaPowerUp = 0.018;  // más rápido que antes (era 0.010)

// Probabilidad de que un ladrillo normal suelte power-up al romperse
const double probPowerUpNormal = 0.35;

// Probabilidad de bolaInvencible dentro del pool aleatorio
// (solo cuando se genera un pw aleatorio desde ladrillo normal)
const double probBolaInvencibleAleatoria = 0.08; // 8% del total de pw generados

final _rng = Random();

// ------------------------------------------------------------------
// spawnPowerUpFijo
// Genera un power-up del tipo indicado en la posición dada.
// Lo llama logica_ladrillos cuando un bloque pw* se rompe.
// ------------------------------------------------------------------
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

// ------------------------------------------------------------------
// intentarGenerarPowerUpAleatorio
// Para ladrillos normales/regeneradores que se rompen: con probabilidad
// [probPowerUpNormal] sueltan un power-up aleatorio.
// bolaInvencible aparece con [probBolaInvencibleAleatoria].
// ------------------------------------------------------------------
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

// ------------------------------------------------------------------
// moverPowerUps
// Baja todos los power-ups y elimina los que salen de pantalla.
// ------------------------------------------------------------------
void moverPowerUps(List<ModeloPowerUp> lista) {
  for (final pu in lista) {
    pu.y += velocidadCaidaPowerUp;
  }
  lista.removeWhere((pu) => pu.y > 1.0);
}

// ------------------------------------------------------------------
// comprobarRecogida
// Devuelve los power-ups que la raqueta ha recogido y los elimina.
// ------------------------------------------------------------------
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