// ============================================================
//  logica_ladrillos.dart
//  Funciones para generar ladrillos, detectar colisiones con la
//  pelota y calcular el rebote correspondiente.
//  No importa Flutter. Opera sobre ModeloLadrillo y ModeloPelota.
// ============================================================

import 'ModeloLadrillo.dart';
import 'ModeloPelota.dart';

// ---- Constantes de la cuadrícula de ladrillos ----
const int    numeroLadrillos        = 3;
const double anchoLadrillo          = 0.4;
const double altoLadrillo           = 0.05;
const double espacioEntreladrillos  = 0.2;
const double primerLadrilloY        = -0.9;

// Calcula el X de inicio para que los ladrillos queden centrados
const double _espacioPared =
    0.5 * (2 - numeroLadrillos * anchoLadrillo - (numeroLadrillos - 1) * espacioEntreladrillos);
const double primerLadrilloX = -1 + _espacioPared;

// ------------------------------------------------------------------
// generarLadrillos
// Devuelve la lista de ladrillos en su posición inicial (sin romper).
// ------------------------------------------------------------------
List<ModeloLadrillo> generarLadrillos() {
  return List.generate(numeroLadrillos, (i) {
    return ModeloLadrillo(
      x: primerLadrilloX + i * (anchoLadrillo + espacioEntreladrillos),
      y: primerLadrilloY,
    );
  });
}

// ------------------------------------------------------------------
// todosTroceados
// Devuelve true cuando todos los ladrillos están rotos (condición WIN).
// ------------------------------------------------------------------
bool todosTroceados(List<ModeloLadrillo> ladrillos) =>
    ladrillos.every((l) => l.roto);

// ------------------------------------------------------------------
// comprobarColisionLadrillos
// Itera la lista de ladrillos y comprueba si la pelota colisiona con
// alguno. Si colisiona: marca el ladrillo como roto y llama a
// [onColision] con la posición del ladrillo (para generar power-ups).
// Retorna true si hubo al menos una colisión en este frame.
// ------------------------------------------------------------------
bool comprobarColisionLadrillos(
    ModeloPelota pelota,
    List<ModeloLadrillo> ladrillos, {
      required void Function(double lx, double ly) onColision,
    }) {
  bool huboColision = false;

  for (final ladrillo in ladrillos) {
    if (ladrillo.roto) continue;

    final bool colision = pelota.x >= ladrillo.x &&
        pelota.x <= ladrillo.x + anchoLadrillo &&
        pelota.y <= ladrillo.y + altoLadrillo &&
        pelota.y >= ladrillo.y - altoLadrillo;

    if (colision) {
      ladrillo.roto = true;
      _rebotar(pelota, ladrillo.x, ladrillo.y);
      onColision(ladrillo.x, ladrillo.y);
      huboColision = true;
    }
  }

  return huboColision;
}

// ------------------------------------------------------------------
// _rebotar (privado)
// Calcula la distancia de la pelota a cada cara del ladrillo y
// invierte la dirección correspondiente al lado más cercano.
// ------------------------------------------------------------------
void _rebotar(ModeloPelota pelota, double lx, double ly) {
  final double distIzq    = (pelota.x - lx).abs();
  final double distDer    = (pelota.x - (lx + anchoLadrillo)).abs();
  final double distArriba = (pelota.y - ly).abs();
  final double distAbajo  = (pelota.y - (ly + altoLadrillo)).abs();

  final double minDist = [distIzq, distDer, distArriba, distAbajo]
      .reduce((a, b) => a < b ? a : b);

  if (minDist == distIzq)         pelota.dirX = Direcciones.izquierda;
  else if (minDist == distDer)    pelota.dirX = Direcciones.derecha;
  else if (minDist == distArriba) pelota.dirY = Direcciones.arriba;
  else                            pelota.dirY = Direcciones.abajo;
}