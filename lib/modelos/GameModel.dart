// ============================================================

// clase para gestionar el change notifier


import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:moviles/modelos/barrel_modelos.dart';
import 'package:moviles/logica/barrel_logica.dart';

class GameModel extends ChangeNotifier {

  late ModeloPelota         _pelota;
  late ModeloJugador        _jugador;
  late List<ModeloLadrillo> _ladrillos;


  ModeloPelota         get pelota    => _pelota;
  ModeloJugador        get jugador   => _jugador;
  List<ModeloLadrillo> get ladrillos => _ladrillos;

// estaod partida
  bool _juegoEmpezado  = false;
  bool _juegoAcabado   = false;
  bool _juegoGanado    = false;
  int  _vidas          = kVidasIniciales;
  int  _puntuacion     = 0;
  bool _multiplicadorx2 = false;
  bool _bolaInvencible  = false;

  bool get juegoEmpezado   => _juegoEmpezado;
  bool get juegoAcabado    => _juegoAcabado;
  bool get juegoGanado     => _juegoGanado;
  int  get vidas           => _vidas;
  int  get puntuacion      => _puntuacion;
  bool get bolaInvencible  => _bolaInvencible;


  final List<ModeloPowerUp> _powerUpsActivos = [];
  List<ModeloPowerUp> get powerUpsActivos => List.unmodifiable(_powerUpsActivos);

  Timer? _timerPrincipal;
  Timer? _timerEfectoRaqueta;
  Timer? _timerEfectoLento;
  Timer? _timerBolaInvencible;
  Timer? _timerRegeneradores;

  GameModel() {
    _inicializar();
  }

  void _inicializar() {
    final estado = inicializarEstado();
    _pelota    = estado.pelota;
    _jugador   = estado.jugador;
    _ladrillos = estado.ladrillos;
  }


  void empezarJuego() {
    if (_juegoEmpezado) return;

    _juegoEmpezado = true;
    notifyListeners();
    _timerRegeneradores = Timer.periodic(const Duration(seconds: 1), (_) {
      tickRegeneradores(_ladrillos);
      notifyListeners(); // puede haber cambiado el estado de un ladrillo
    });


    _timerPrincipal = Timer.periodic(const Duration(milliseconds: 10), (timer) {


      actualizarDireccion(_pelota, _jugador); //direccion pelota


      moverPelota(_pelota, tiempoLento: _timerEfectoLento != null); // movimiento de la pelota


      moverPowerUps(_powerUpsActivos); //movimiento power ups


      tickFantasma(_ladrillos, DateTime.now().millisecondsSinceEpoch); //visibilidad del laddrillo fantasma


      final colisiones = comprobarColisionLadrillos(
        _pelota, _ladrillos, bolaInvencible: _bolaInvencible,
      ); // colisiones ladrillos

      for (final col in colisiones) {

        if (col.puntosGanados > 0) {
          int pts = col.puntosGanados;
          if (_multiplicadorx2) pts *= 2;
          if (col.multiplicarPuntuacion) {
            pts *= 2;
            _multiplicadorx2 = true;
          }
          _puntuacion += pts;
        }

        if (col.tipoPowerUpSoltado != null) {
          spawnPowerUpFijo(_powerUpsActivos, col.tipoPowerUpSoltado!,
              col.ladrilloX, col.ladrilloY, anchoLadrillo);
        } else if (col.puntosGanados > 0) {
          intentarGenerarPowerUpAleatorio(_powerUpsActivos,
              col.ladrilloX, col.ladrilloY, anchoLadrillo);
        }
      }


      if (todosTroceados(_ladrillos)) { // para regenerar  ladrillos cuando esten todos rotos
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


      final recogidos = comprobarRecogida(_powerUpsActivos, _jugador);
      for (final pu in recogidos) {
        _aplicarEfectoPowerUp(pu.tipo);
      }


      if (pelotaFueraDePantalla(_pelota)) {
        timer.cancel();
        _timerRegeneradores?.cancel();
        _procesarPerdidaDeVida();
        return;
      }


      notifyListeners();
    });
  }


  void moverIzquierda() {
    moverIzquierdajugador(_jugador);
    notifyListeners();
  }

  void moverDerecha() {
    moverDerechajugador(_jugador);
    notifyListeners();
  }

  void moverConArrasteDedo(double deltaPx, double anchoPantalla) {
    moverConArrastrejugador(_jugador, deltaPx, anchoPantalla);
    notifyListeners();
  }


  void _aplicarEfectoPowerUp(TipoPowerUp tipo) {

    final resultado = aplicarEfectoPowerUp(
      tipo:             tipo,
      jugador:          _jugador,
      vidas:            _vidas,
      vidasMax:         kVidasMaximas,
      bolaInvencible:   _bolaInvencible,
      onEstadoCambiado: (fn) { fn(); notifyListeners(); },
      timerRaqueta:     _timerEfectoRaqueta,
      timerLento:       _timerEfectoLento,
      timerInvencible:  _timerBolaInvencible,
    );

    _vidas = resultado.vidas;


    if (tipo == TipoPowerUp.tiempoLento) {
      _timerEfectoLento?.cancel();
      _timerEfectoLento = Timer(const Duration(seconds: 10), () {
        _timerEfectoLento = null;
        notifyListeners();
      });
    }


    if (tipo == TipoPowerUp.bolaInvencible) {
      _bolaInvencible = true;
      _timerBolaInvencible?.cancel();
      _timerBolaInvencible = Timer(const Duration(seconds: 10), () {
        _bolaInvencible = false;
        _timerBolaInvencible = null;
        notifyListeners();
      });
    }


    if (tipo == TipoPowerUp.racketaGrande) {
      _timerEfectoRaqueta?.cancel();
      _jugador.ancho = ModeloJugador.anchoGrande;
      _timerEfectoRaqueta = Timer(const Duration(seconds: 10), () {
        _jugador.resetear();
        _timerEfectoRaqueta = null;
        notifyListeners();
      });
    }
  }

  void _cancelarEfectos() {

    _timerEfectoRaqueta?.cancel();
    _timerEfectoLento?.cancel();
    _timerBolaInvencible?.cancel();


    _timerEfectoRaqueta  = null;
    _timerEfectoLento    = null;
    _timerBolaInvencible = null;

    _bolaInvencible = false;
    _jugador.resetear();
  }


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
    notifyListeners();
  }


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

    notifyListeners();
  }


  @override
  void dispose() {
    _timerPrincipal?.cancel();
    _timerRegeneradores?.cancel();
    _cancelarEfectos();
    super.dispose(); // libera los listeners de ChangeNotifier
  }
}