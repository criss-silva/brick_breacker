//  game_logic.dart
//  Extraemos toda la lógica de la página principal
//
//  Todas las funciones reciben el estado como parámetros y
//  devuelven un GameControlResult que PaginaPrincipal aplica
//  con setState, manteniendo así una separación clara entre
//  lógica y UI.


import 'dart:async';
import 'package:moviles/modelos/barrel_modelos.dart';
import 'package:moviles/logica/LogicaLadrillos.dart';
import 'barrel_logica.dart';

const int kVidasIniciales       = 3;     // vidas al empezar una partida nueva
const int kVidasMaximas         = 5;     // techo al recoger vidaExtra
const int kDuracionEfectoMs     = 7000;  // duración de raqueta grande y tiempo lento (ms)
const int kDuracionInvencibleMs = 5000;  // duración de la bola invencible (ms)


class ResultadoOleada {
  // Nueva lista de ladrillos recién generada
  final List<ModeloLadrillo> nuevosLadrillos;

  //puntos extra cada vez que se completa una oleada entera de ladrillos
  final int bonusOleada;

  const ResultadoOleada({
    required this.nuevosLadrillos,
    required this.bonusOleada,
  });
}


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


    case TipoPowerUp.tiempoLento:
      nuevoTimerLento?.cancel();
      nuevoTimerLento = Timer(
        const Duration(milliseconds: kDuracionEfectoMs),
            () => onEstadoCambiado(() => nuevoTimerLento = null),
      );
      break;

    case TipoPowerUp.vidaExtra:
      if (vidas < vidasMax) nuevasVidas++;
      break;

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

    return (
    vidas:         0,
    juegoAcabado:  true,
    juegoEmpezado: false,
    );
  }


  pelota.resetear();
  jugador.resetear();
  powerUpsActivos.clear();

  return (
  vidas:         nuevasVidas,
  juegoAcabado:  false,
  juegoEmpezado: false, // falso para que el tap vuelva a arrancar el bucle
  );
}

ResultadoOleada nuevaOleada({
  required int           vidas,
  required ModeloPelota  pelota,
  required ModeloJugador jugador,
  required List<ModeloPowerUp> powerUpsActivos,
}) {
  // pequeño bonus por completar la oleada con las vidas que quedan
  final int bonus = vidas * 50;

  // reseteamos pelota y raqueta igual que al perder una vida
  pelota.resetear();
  jugador.resetear();
  powerUpsActivos.clear();

  return ResultadoOleada(
    nuevosLadrillos: generarLadrillos(), // cuadrícula completamente nueva
    bonusOleada:     bonus,
  );
}


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