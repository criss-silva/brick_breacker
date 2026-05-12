//  game_logic.dart
//  Extraemos toda la lógica de la página principal
//
//  Todas las funciones reciben el estado como parámetros y
//  devuelven un GameControlResult que PaginaPrincipal aplica
//  con setState, manteniendo así una separación clara entre
//  lógica y UI.


import 'dart:async';
import 'package:moviles/ModeloPelota.dart';
import 'package:moviles/ModeloJugador.dart';
import 'package:moviles/ModeloLadrillo.dart';
import 'package:moviles/modelos.dart';
import 'package:moviles/LogicaLadrillos.dart';
import 'package:moviles/LogicaPelota.dart';
import 'package:moviles/LogicaPowerups.dart';

const int kVidasIniciales       = 3;     // vidas al empezar una partida nueva
const int kVidasMaximas         = 5;     // techo al recoger vidaExtra
const int kDuracionEfectoMs     = 7000;  // duración de raqueta grande y tiempo lento (ms)
const int kDuracionInvencibleMs = 5000;  // duración de la bola invencible (ms)

//  Cuando todos los ladrillos se rompen no terminamos el juego:
//  regeneramos una nueva oleada y seguimos. Este objeto le
//  indica a PaginaPrincipal qué cambió para que llame setState.
class ResultadoOleada {
  // Nueva lista de ladrillos recién generada
  final List<ModeloLadrillo> nuevosLadrillos;

  // Puntos de bonus por completar la oleada
  final int bonusOleada;

  const ResultadoOleada({
    required this.nuevosLadrillos,
    required this.bonusOleada,
  });
}

//  INICIALIZAR ESTADO
//  Crea los modelos desde cero. Se llama al arrancar la app y
// Devuelve pelota, jugador y ladrillos en su estado inicial.
// PaginaPrincipal asigna los valores retornados con setState.
({
ModeloPelota pelota,
ModeloJugador jugador,
List<ModeloLadrillo> ladrillos,
}) inicializarEstado() {
  return (
  pelota:    ModeloPelota(),
  jugador:   ModeloJugador(),
  ladrillos: generarLadrillos(),
  );
}

//  APLICAR EFECTO DE POWER-UP
//  Cada power-up recogido por la raqueta produce un efecto. La función
//  devuelve los timers que hay que guardar en PaginaPrincipal
//  para poder cancelarlos más tarde.
//
//  Parámetros:
//    tipo             → qué power-up se recogió
//    jugador          → modelo de la raqueta (para cambiar su ancho)
//    vidas / vidasMax → estado actual de vidas
//    onEstadoCambiado → callback que ejecuta setState en la UI
//    timerRaqueta, timerLento, timerInvencible → timers actuales
//      (se cancelan y reemplazan si el efecto ya estaba activo)

({
Timer? timerRaqueta,
Timer? timerLento,
Timer? timerInvencible,
bool   bolaInvencible,
int    vidas,
}) aplicarEfectoPowerUp({
  required TipoPowerUp tipo,
  required ModeloJugador jugador,
  required int  vidas,
  required int  vidasMax,
  required void Function(void Function()) onEstadoCambiado,
  Timer? timerRaqueta,
  Timer? timerLento,
  Timer? timerInvencible,
  required bool bolaInvencible,
}) {
  // Valores de salida: por defecto se conservan los actuales
  Timer? nuevoTimerRaqueta    = timerRaqueta;
  Timer? nuevoTimerLento      = timerLento;
  Timer? nuevoTimerInvencible = timerInvencible;
  bool   nuevaBolaInvencible  = bolaInvencible;
  int    nuevasVidas          = vidas;

  switch (tipo) {

  // Rosa: amplía la raqueta durante kDuracionEfectoMs ms.
  // Si ya estaba activo reinicia el contador.
    case TipoPowerUp.racketaGrande:
      nuevoTimerRaqueta?.cancel();
      jugador.ancho = ModeloJugador.anchoGrande;
      nuevoTimerRaqueta = Timer(
        const Duration(milliseconds: kDuracionEfectoMs),
            () => onEstadoCambiado(() {
          jugador.ancho    = ModeloJugador.anchoNormal;
          nuevoTimerRaqueta = null;
        }),
      );
      break;

  // Azul: activa el flag de tiempo lento que moverPelota consulta.
  // El timer simplemente anula el flag al expirar.
    case TipoPowerUp.tiempoLento:
      nuevoTimerLento?.cancel();
      nuevoTimerLento = Timer(
        const Duration(milliseconds: kDuracionEfectoMs),
            () => onEstadoCambiado(() => nuevoTimerLento = null),
      );
      break;

  // Amarillo: suma una vida sin superar el máximo permitido
    case TipoPowerUp.vidaExtra:
      if (vidas < vidasMax) nuevasVidas++;
      break;

  // Morado: la bola rompe cualquier ladrillo de un golpe.
  // Reinicia el contador si ya estaba activo.
    case TipoPowerUp.bolaInvencible:
      nuevoTimerInvencible?.cancel();
      nuevaBolaInvencible = true;
      nuevoTimerInvencible = Timer(
        const Duration(milliseconds: kDuracionInvencibleMs),
            () => onEstadoCambiado(() {
          nuevaBolaInvencible  = false;
          nuevoTimerInvencible = null;
        }),
      );
      break;
  }

  return (
  timerRaqueta:   nuevoTimerRaqueta,
  timerLento:     nuevoTimerLento,
  timerInvencible: nuevoTimerInvencible,
  bolaInvencible: nuevaBolaInvencible,
  vidas:          nuevasVidas,
  );
}

//  CANCELAR EFECTOS TEMPORALES
//  Para todas las consecuencias visuales y mecánicas de los
//  power-ups activos. Se llama al perder una vida o al reiniciar
//  para que el próximo intento empiece limpio.

//Cancela los tres timers de efectos, restaura el ancho de la
// raqueta y devuelve los timers a null para que PaginaPrincipal
// los actualice en su estado.
({
Timer? timerRaqueta,
Timer? timerLento,
Timer? timerInvencible,
bool   bolaInvencible,
}) cancelarEfectosTemporales({
  required ModeloJugador jugador,
  Timer? timerRaqueta,
  Timer? timerLento,
  Timer? timerInvencible,
}) {
  timerRaqueta?.cancel();
  timerLento?.cancel();
  timerInvencible?.cancel();
  jugador.ancho = ModeloJugador.anchoNormal; // restauramos el ancho normal
  return (
  timerRaqueta:    null,
  timerLento:      null,
  timerInvencible: null,
  bolaInvencible:  false,
  );
}

//  PERDER VIDA
//  Descuenta una vida y decide si la partida continúa o termina.
//  Si quedan vidas, resetea pelota, raqueta y power-ups activos
//  para el siguiente intento.
//
//  Retorna un record que PaginaPrincipal aplica con setState.

({
int  vidas,
bool juegoAcabado,
bool juegoEmpezado,
}) perderVida({
  required int                vidas,
  required ModeloPelota       pelota,
  required ModeloJugador      jugador,
  required List<ModeloPowerUp> powerUpsActivos,
}) {
  final int nuevasVidas = vidas - 1;

  if (nuevasVidas <= 0) {
    // Sin vidas → pantalla de Game Over
    return (
    vidas:         0,
    juegoAcabado:  true,
    juegoEmpezado: false,
    );
  }

  // Queda al menos una vida: reseteamos posiciones para el nuevo intento
  pelota.resetear();
  jugador.resetear();
  powerUpsActivos.clear(); // los power-ups en vuelo desaparecen

  return (
  vidas:         nuevasVidas,
  juegoAcabado:  false,
  juegoEmpezado: false, // falso para que el tap vuelva a arrancar el bucle
  );
}

//  NUEVA OLEADA
//  Cuando todos los ladrillos de la pantalla actual se rompen,
//  en lugar de mostrar la pantalla de victoria regeneramos una
//  nueva tanda. La pelota y la raqueta se resetean
//  Se suma un bonus de puntuación proporcional a las vidas
//  restantes como recompensa por llegar a nueva oleada.

// Genera una nueva oleada de ladrillos y calcula el bonus.
// PaginaPrincipal debe cancelar los timers del bucle actual y
// volver a llamar a _empezarJuego() tras aplicar este resultado.
ResultadoOleada nuevaOleada({
  required int           vidas,
  required ModeloPelota  pelota,
  required ModeloJugador jugador,
  required List<ModeloPowerUp> powerUpsActivos,
}) {
  // Pequeño bonus por completar la oleada con las vidas que quedan
  final int bonus = vidas * 50;

  // Reseteamos pelota y raqueta igual que al perder una vida
  pelota.resetear();
  jugador.resetear();
  powerUpsActivos.clear();

  return ResultadoOleada(
    nuevosLadrillos: generarLadrillos(), // cuadrícula completamente nueva
    bonusOleada:     bonus,
  );
}

//  REINICIO COMPLETO
//  Restaura absolutamente todo al estado inicial de partida.
//  Devuelve los nuevos modelos; PaginaPrincipal cancela los
//  timers antes de llamar a esta función.

({
ModeloPelota         pelota,
ModeloJugador        jugador,
List<ModeloLadrillo> ladrillos,
int   vidas,
int   puntuacion,
bool  juegoEmpezado,
bool  juegoAcabado,
bool  juegoGanado,
bool  multiplicadorx2,
}) reiniciarEstado() {
  return (
  pelota:         ModeloPelota(),
  jugador:        ModeloJugador(),
  ladrillos:      generarLadrillos(),
  vidas:          kVidasIniciales,
  puntuacion:     0,
  juegoEmpezado:  false,
  juegoAcabado:   false,
  juegoGanado:    false,
  multiplicadorx2: false,
  );
}