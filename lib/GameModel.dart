// ============================================================
//  GameModel.dart
//  Modelo central del juego que implementa ChangeNotifier.
//
//  ¿Qué es ChangeNotifier?
//  Es una clase de Flutter que permite notificar a los widgets
//  que escuchan cuando el estado interno cambia. En lugar de
//  llamar setState() desde el widget, llamamos notifyListeners()
//  desde aquí, y Flutter reconstruye solo los widgets que
//  dependen de este modelo (los que usan context.watch<GameModel>).
//
//  ¿Qué ha cambiado respecto a antes?
//  Antes: _PaginaPrincipalState tenía el estado + los timers
//         + llamaba a setState() cada vez que algo cambiaba.
//  Ahora: GameModel tiene el estado + los timers
//         + llama a notifyListeners() cuando algo cambia.
//         PaginaPrincipal queda como un widget "tonto" que
//         solo dibuja lo que GameModel le dice.
// ============================================================

import 'dart:async';
import 'package:flutter/foundation.dart'; // ChangeNotifier vive aquí
import 'package:moviles/ModeloPelota.dart';
import 'package:moviles/ModeloJugador.dart';
import 'package:moviles/ModeloLadrillo.dart';
import 'package:moviles/modelos.dart';
import 'package:moviles/GameLogic.dart';
import 'package:moviles/LogicaJugador.dart' as logicaJugador;
import 'package:moviles/LogicaPelota.dart';
import 'package:moviles/LogicaLadrillos.dart';
import 'package:moviles/LogicaPowerups.dart';
import 'package:moviles/game_state.dart';

class GameModel extends ChangeNotifier {

  // ──────────────────────────────────────────────
  // MODELOS DE ESTADO
  // Los mismos de antes, pero ahora viven aquí.
  // ──────────────────────────────────────────────
  late ModeloPelota         _pelota;
  late ModeloJugador        _jugador;
  late List<ModeloLadrillo> _ladrillos;

  // Getters públicos de solo lectura para que los widgets puedan leer
  // el estado sin poder modificarlo directamente (encapsulamiento).
  ModeloPelota         get pelota    => _pelota;
  ModeloJugador        get jugador   => _jugador;
  List<ModeloLadrillo> get ladrillos => _ladrillos;

  // ──────────────────────────────────────────────
  // ESTADO GENERAL DE LA PARTIDA
  // ──────────────────────────────────────────────
  bool _juegoEmpezado  = false;
  bool _juegoAcabado   = false;
  bool _juegoGanado    = false;
  int  _vidas          = kVidasIniciales;
  int  _puntuacion     = 0;
  bool _multiplicadorx2 = false;
  bool _bolaInvencible  = false;

  // Getters públicos (los widgets solo leen, no escriben)
  bool get juegoEmpezado   => _juegoEmpezado;
  bool get juegoAcabado    => _juegoAcabado;
  bool get juegoGanado     => _juegoGanado;
  int  get vidas           => _vidas;
  int  get puntuacion      => _puntuacion;
  bool get bolaInvencible  => _bolaInvencible;

  // ──────────────────────────────────────────────
  // POWER-UPS EN PANTALLA
  // ──────────────────────────────────────────────
  final List<ModeloPowerUp> _powerUpsActivos = [];
  List<ModeloPowerUp> get powerUpsActivos => List.unmodifiable(_powerUpsActivos);

  // ──────────────────────────────────────────────
  // TIMERS
  // Exactamente los mismos de antes, ahora dentro del modelo.
  // ──────────────────────────────────────────────
  Timer? _timerPrincipal;
  Timer? _timerEfectoRaqueta;
  Timer? _timerEfectoLento;
  Timer? _timerBolaInvencible;
  Timer? _timerRegeneradores;

  // ──────────────────────────────────────────────
  // CONSTRUCTOR
  // Inicializamos el estado al crear el modelo.
  // ──────────────────────────────────────────────
  GameModel() {
    _inicializar();
  }

  void _inicializar() {
    final estado = inicializarEstado();
    _pelota    = estado.pelota;
    _jugador   = estado.jugador;
    _ladrillos = estado.ladrillos;
  }

  // ============================================================
  //  ARRANCAR EL JUEGO
  //  Mismo flujo que antes, pero notifyListeners() en vez de
  //  setState(). Los widgets que hacen context.watch<GameModel>()
  //  se reconstruyen automáticamente.
  // ============================================================
  void empezarJuego() {
    if (_juegoEmpezado) return;

    _juegoEmpezado = true;
    notifyListeners(); // avisamos: el juego ha empezado (oculta la cubierta)

    // Timer de regeneradores: cada segundo repara ladrillos regeneradores
    _timerRegeneradores = Timer.periodic(const Duration(seconds: 1), (_) {
      tickRegeneradores(_ladrillos);
      notifyListeners(); // puede haber cambiado el estado de un ladrillo
    });

    // Timer principal: bucle del juego a 10 ms
    _timerPrincipal = Timer.periodic(const Duration(milliseconds: 10), (timer) {

      // 1. Dirección de la pelota (rebotes en bordes y raqueta)
      actualizarDireccion(_pelota, _jugador);

      // 2. Mover la pelota (lenta si el power-up azul está activo)
      moverPelota(_pelota, tiempoLento: _timerEfectoLento != null);

      // 3. Bajar los power-ups que caen por pantalla
      moverPowerUps(_powerUpsActivos);

      // 4. Actualizar visibilidad del ladrillo fantasma
      tickFantasma(_ladrillos, DateTime.now().millisecondsSinceEpoch);

      // 5. Colisiones pelota-ladrillos
      final colisiones = comprobarColisionLadrillos(
        _pelota, _ladrillos, bolaInvencible: _bolaInvencible,
      );

      for (final col in colisiones) {
        // Sumar puntos (con posible multiplicador x2 del fantasma)
        if (col.puntosGanados > 0) {
          int pts = col.puntosGanados;
          if (_multiplicadorx2) pts *= 2;
          if (col.multiplicarPuntuacion) {
            pts *= 2;
            _multiplicadorx2 = true;
          }
          _puntuacion += pts;
        }

        // Spawnear power-up del ladrillo roto
        if (col.tipoPowerUpSoltado != null) {
          spawnPowerUpFijo(_powerUpsActivos, col.tipoPowerUpSoltado!,
              col.ladrilloX, col.ladrilloY, anchoLadrillo);
        } else if (col.puntosGanados > 0) {
          intentarGenerarPowerUpAleatorio(_powerUpsActivos,
              col.ladrilloX, col.ladrilloY, anchoLadrillo);
        }
      }

      // 6. ¿Todos los ladrillos rotos? → nueva oleada
      if (todosTroceados(_ladrillos)) {
        timer.cancel();
        _timerRegeneradores?.cancel();

        final resultado = nuevaOleada(
          vidas:           _vidas,
          pelota:          _pelota,
          jugador:         _jugador,
          powerUpsActivos: _powerUpsActivos,
        );

        _ladrillos       = resultado.nuevosLadrillos;
        _puntuacion     += resultado.bonusOleada;
        _juegoEmpezado   = false;
        _multiplicadorx2 = false;

        notifyListeners();
        empezarJuego(); // arrancamos la nueva oleada automáticamente
        return;
      }

      // 7. Recoger power-ups que hayan tocado la raqueta
      final recogidos = comprobarRecogida(_powerUpsActivos, _jugador);
      for (final pu in recogidos) {
        _aplicarEfectoPowerUp(pu.tipo);
      }

      // 8. Pelota fuera → perder vida
      if (pelotaFueraDePantalla(_pelota)) {
        timer.cancel();
        _timerRegeneradores?.cancel();
        _procesarPerdidaDeVida();
        return; // salimos del tick sin notifyListeners adicional
      }

      // Notificamos UNA sola vez al final del frame para que Flutter
      // reconstruya los widgets solo una vez por tick, no varias.
      notifyListeners();
    });
  }

  // ============================================================
  //  MOVIMIENTO DE LA RAQUETA
  //  Los widgets llaman a estos métodos directamente.
  //  Cada uno notifica para que la raqueta se redibuje.
  // ============================================================
  void moverIzquierda() {
    logicaJugador.moverIzquierda(_jugador); // función de LogicaJugador
    notifyListeners();
  }

  void moverDerecha() {
    logicaJugador.moverDerecha(_jugador);
    notifyListeners();
  }

  void moverConArrasteDedo(double deltaPx, double anchoPantalla) {
    logicaJugador.moverConArrastre(_jugador, deltaPx, anchoPantalla);
    notifyListeners();
  }

  // ============================================================
  //  EFECTOS DE POWER-UPS
  //  Igual que antes pero notifyListeners() reemplaza setState.
  // ============================================================
  void _aplicarEfectoPowerUp(TipoPowerUp tipo) {
    // Pasamos notifyListeners como callback para que los timers
    // de expiración también puedan notificar a los widgets.
    // La firma es void Function(void Function()) igual que antes con setState.
    final resultado = aplicarEfectoPowerUp(
      tipo:             tipo,
      jugador:          _jugador,
      vidas:            _vidas,
      vidasMax:         kVidasMaximas,
      bolaInvencible:   _bolaInvencible,
      onEstadoCambiado: (fn) { fn(); notifyListeners(); }, // <-- aquí el cambio clave
      timerRaqueta:     _timerEfectoRaqueta,
      timerLento:       _timerEfectoLento,
      timerInvencible:  _timerBolaInvencible,
    );
    _timerEfectoRaqueta  = resultado.timerRaqueta;
    _timerEfectoLento    = resultado.timerLento;
    _timerBolaInvencible = resultado.timerInvencible;
    _bolaInvencible      = resultado.bolaInvencible;
    _vidas               = resultado.vidas;
  }

  void _cancelarEfectos() {
    final resultado = cancelarEfectosTemporales(
      jugador:        _jugador,
      timerRaqueta:   _timerEfectoRaqueta,
      timerLento:     _timerEfectoLento,
      timerInvencible: _timerBolaInvencible,
    );
    _timerEfectoRaqueta  = resultado.timerRaqueta;
    _timerEfectoLento    = resultado.timerLento;
    _timerBolaInvencible = resultado.timerInvencible;
    _bolaInvencible      = resultado.bolaInvencible;
  }

  // ============================================================
  //  PERDER VIDA
  // ============================================================
  void _procesarPerdidaDeVida() {
    _cancelarEfectos();
    final resultado = perderVida(
      vidas:           _vidas,
      pelota:          _pelota,
      jugador:         _jugador,
      powerUpsActivos: _powerUpsActivos,
    );
    _vidas         = resultado.vidas;
    _juegoAcabado  = resultado.juegoAcabado;
    _juegoEmpezado = resultado.juegoEmpezado;
    notifyListeners(); // los widgets reaccionan: muestra Game Over o reinicia
  }

  // ============================================================
  //  REINICIO COMPLETO
  //  Llamado desde el botón "Play Again" de PantallaFinal.
  // ============================================================
  void reiniciar() {
    _timerPrincipal?.cancel();
    _timerRegeneradores?.cancel();
    _cancelarEfectos();

    final r = reiniciarEstado();
    _pelota          = r.pelota;
    _jugador         = r.jugador;
    _ladrillos       = r.ladrillos;
    _vidas           = r.vidas;
    _puntuacion      = r.puntuacion;
    _juegoEmpezado   = r.juegoEmpezado;
    _juegoAcabado    = r.juegoAcabado;
    _juegoGanado     = r.juegoGanado;
    _multiplicadorx2 = r.multiplicadorx2;
    _powerUpsActivos.clear();

    notifyListeners(); // los widgets vuelven a la pantalla de inicio
  }

  // ============================================================
  //  DISPOSE
  //  ChangeNotifier ya tiene su propio dispose() que libera
  //  los listeners. Nosotros lo sobreescribimos para cancelar
  //  también los timers del juego antes de llamar a super.
  // ============================================================
  @override
  void dispose() {
    _timerPrincipal?.cancel();
    _timerRegeneradores?.cancel();
    _cancelarEfectos();
    super.dispose(); // libera los listeners de ChangeNotifier
  }
}