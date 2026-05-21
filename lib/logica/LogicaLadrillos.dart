//  logica_ladrillos.dart
//  Toda la lógica de los ladrillos: generación aleatoria por filas,
//  colisiones, rebote, regenerador, fantasma y puntuación.
//  No importa Flutter.


import 'dart:math';
import 'package:moviles/modelos/barrel_modelos.dart';

const int    numColumnas       = 7;
const int    numFilas          = 4;
const double anchoLadrillo     = 0.26;
const double altoLadrillo      = 0.06;
const double espacioHorizontal = 0.02;
const double espacioVertical   = 0.04;
const double primerLadrilloY   = -0.85;
const double _margenLateral    = 0.02;


const double _anchoTotal = numColumnas * anchoLadrillo +
    (numColumnas - 1) * espacioHorizontal;
const double primerLadrilloX = //esto es para centrar el bloque de ladrillos
    -1 + _margenLateral + (2 - 2 * _margenLateral - _anchoTotal) / 2;

final _rng = Random();


class ResultadoColision {

  final int puntosGanados;
  final bool multiplicarPuntuacion;
  final TipoPowerUp? tipoPowerUpSoltado;

  final double ladrilloX;

  final double ladrilloY;

  const ResultadoColision({
    this.puntosGanados         = 0,
    this.multiplicarPuntuacion = false,
    this.tipoPowerUpSoltado    = null,
    this.ladrilloX             = 0,
    this.ladrilloY             = 0,
  });
}


List<ModeloLadrillo> generarLadrillos() {
  final List<ModeloLadrillo> lista = [];
  bool fantasmaColocado = false;

  for (int fila = 0; fila < numFilas; fila++) {
    final double y = primerLadrilloY + fila * (altoLadrillo + espacioVertical);

    for (int col = 0; col < numColumnas; col++) {
      final double x =
          primerLadrilloX + col * (anchoLadrillo + espacioHorizontal);

      final TipoLadrillo tipo = _elegirTipo(fila, fantasmaColocado);
      if (tipo == TipoLadrillo.fantasma) fantasmaColocado = true;
      final int golpes = (fila == 3)
          ? _max3(ModeloLadrillo.golpesIniciales(tipo))
          : ModeloLadrillo.golpesIniciales(tipo);

      lista.add(ModeloLadrillo(
        x:               x,
        y:               y,
        tipo:            tipo,
        golpesRestantes: golpes,
      ));
    }
  }
  return lista;
}

int _max3(int v) => v < 3 ? 3 : v;

TipoLadrillo _elegirTipo(int fila, bool fantasmaColocado) {
  final double r = _rng.nextDouble();

  switch (fila) {
  // fila 1
    case 0:
      if (r < 0.15) return TipoLadrillo.special;
      if (r < 0.30) return TipoLadrillo.pwMorado;
      if (r < 0.45) return TipoLadrillo.pwRosa;
      if (!fantasmaColocado && r < 0.50) return TipoLadrillo.fantasma;
      if (r < 0.60) return TipoLadrillo.pwAzul;
      if (r < 0.75) return TipoLadrillo.pwAmarillo;
      return TipoLadrillo.normal1;

  // fila 2
    case 1:
      if (r < 0.10) return TipoLadrillo.special;
      if (r < 0.25) return TipoLadrillo.pwMorado;
      if (r < 0.40) return TipoLadrillo.regenerador;
      if (!fantasmaColocado && r < 0.50) return TipoLadrillo.fantasma;
      if (r < 0.55) return TipoLadrillo.pwRosa;
      if (r < 0.70) return TipoLadrillo.pwAzul;

      return TipoLadrillo.normal3;

  // fila 3
    case 2:
      if (!fantasmaColocado && r < 0.05) return TipoLadrillo.fantasma;
      if (r < 0.20) return TipoLadrillo.normal3;
      if (r < 0.40) return TipoLadrillo.pwAmarillo;
      if (r < 0.60) return TipoLadrillo.pwAzul;
      return TipoLadrillo.normal2;

  //fila 4
    case 3:
    default:
      if (r<0.3) return TipoLadrillo.normal3;
      if (r<0.5) return TipoLadrillo.normal2;
      if (r < 0.80) return TipoLadrillo.normal1;
      return TipoLadrillo.normal1;
  }
}


bool todosTroceados(List<ModeloLadrillo> ladrillos) =>
    ladrillos.every((l) => l.roto);

void tickRegeneradores(List<ModeloLadrillo> ladrillos) {
  final int ahora = DateTime.now().millisecondsSinceEpoch;
  for (final l in ladrillos) {
    if (l.tipo != TipoLadrillo.regenerador) continue;
    if (l.roto) continue;
    final int golpesMax = ModeloLadrillo.golpesIniciales(l.tipo);
    if (l.golpesRestantes == golpesMax) continue; // ya está sano
    if (l.ultimoGolpeMs == null) continue;
    if (ahora - l.ultimoGolpeMs! >= kRegenSeg * 1000) {
      l.regenerar();
    }
  }
}

const int kFantasmaIntervaloMs = 1500; // alterna cada 1.5 s
// visibilidad bloque fantasma
void tickFantasma(List<ModeloLadrillo> ladrillos, int ahoraMs) {
  for (final l in ladrillos) {
    if (l.tipo != TipoLadrillo.fantasma || l.roto) continue;
    final int ciclo = ahoraMs ~/ kFantasmaIntervaloMs;
    l.visible = ciclo.isEven;
  }
}



List<ResultadoColision> comprobarColisionLadrillos(
    ModeloPelota pelota,
    List<ModeloLadrillo> ladrillos, {
      bool bolaInvencible = false,
    }) {
  final List<ResultadoColision> resultados = [];

  for (final l in ladrillos) {
    if (l.roto) continue;

    if (l.tipo == TipoLadrillo.fantasma && !l.visible) continue;
    final double margen = (l.tipo == TipoLadrillo.normal1) ? 0.01 : 0.005;
    final bool colision =
        pelota.x + margen >= l.x &&
            pelota.x - margen <= l.x + anchoLadrillo &&
            pelota.y + margen <= l.y + altoLadrillo &&
            pelota.y - margen >= l.y - altoLadrillo;

    if (!colision) continue;


    _rebotar(pelota, l.x, l.y);

    // Daño
    if (bolaInvencible) {
      l.golpesRestantes = 0;
    } else {
      l.golpesRestantes--;
      if (l.tipo == TipoLadrillo.regenerador) {
        l.ultimoGolpeMs = DateTime.now().millisecondsSinceEpoch;
      }

      if (l.tipo == TipoLadrillo.normal1) {
        l.golpesRestantes = 0;
      }
    }
    if (l.roto) {
      // Solo soltar power-up si no es normal1
      TipoPowerUp? powerUpSoltado = null;
      if (l.tipo != TipoLadrillo.normal1) {
        powerUpSoltado = _powerUpDeTipo(l.tipo);
      }
      resultados.add(ResultadoColision(
        puntosGanados:          ModeloLadrillo.puntosPorTipo(l.tipo),
        multiplicarPuntuacion:  l.tipo == TipoLadrillo.fantasma,
        tipoPowerUpSoltado:     powerUpSoltado,
        ladrilloX:              l.x,
        ladrilloY:              l.y,
      ));
    } else {
      resultados.add(ResultadoColision(
        ladrilloX: l.x,
        ladrilloY: l.y,
      ));
    }
  }

  return resultados;
}
//tipos de power up segun el ladrillo
TipoPowerUp? _powerUpDeTipo(TipoLadrillo t) {
  switch (t) {
    case TipoLadrillo.pwRosa:     return TipoPowerUp.racketaGrande;
    case TipoLadrillo.pwAzul:     return TipoPowerUp.tiempoLento;
    case TipoLadrillo.pwAmarillo: return TipoPowerUp.vidaExtra;
    case TipoLadrillo.pwMorado:   return TipoPowerUp.bolaInvencible;
    default:                      return null;
  }
}


void _rebotar(ModeloPelota pelota, double lx, double ly) {
  final double distIzq    = (pelota.x - lx).abs();
  final double distDer    = (pelota.x - (lx + anchoLadrillo)).abs();
  final double distArriba = (pelota.y - ly).abs();
  final double distAbajo  = (pelota.y - (ly + altoLadrillo)).abs();

  final double minDist =
  [distIzq, distDer, distArriba, distAbajo].reduce((a, b) => a < b ? a : b);

  if (minDist == distIzq)         pelota.dirX = Direcciones.izquierda;
  else if (minDist == distDer)    pelota.dirX = Direcciones.derecha;
  else if (minDist == distArriba) pelota.dirY = Direcciones.arriba;
  else                            pelota.dirY = Direcciones.abajo;
}