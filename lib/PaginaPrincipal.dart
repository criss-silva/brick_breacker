// ============================================================
//  PaginaPrincipal.dart
//  Orquestador principal del juego.
//  SOLO coordina el estado y llama a los módulos de lógica.
//  No contiene ninguna función de física ni de colisión inline.
//
//  Módulos de modelos:
//    modelo_pelota.dart   → ModeloPelota, Direcciones
//    modelo_jugador.dart  → ModeloJugador
//    modelo_ladrillo.dart → ModeloLadrillo
//    modelos.dart         → ModeloPowerUp, TipoPowerUp
//
//  Módulos de lógica:
//    logica_pelota.dart   → moverPelota, actualizarDireccion, pelotaFueraDePantalla
//    logica_jugador.dart  → moverIzquierda, moverDerecha, moverConArrastre
//    logica_ladrillos.dart→ generarLadrillos, comprobarColisionLadrillos, todosTroceados
//    logica_powerups.dart → intentarGenerarPowerUp, moverPowerUps, comprobarRecogida
//
//  Módulos de vista:
//    vista_pelota.dart    → VistaPelota
//    vista_jugador.dart   → VistaJugador
//    vista_ladrillo.dart  → VistaLadrillo
//    Powerup.dart         → PowerUpWidget
//    PaginaDeCubierta.dart→ Cubierta
//    Pantallafinal.dart   → PantallaFinal
//    PantallaVictoria.dart→ PantallaVictoria  ← NUEVO
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---- Modelos ----
import 'package:moviles/ModeloPelota.dart';
import 'package:moviles/ModeloJugador.dart';
import 'package:moviles/ModeloLadrillo.dart';
import 'package:moviles/modelos.dart';

// ---- Lógica ----
import 'package:moviles/LogicaPelota.dart';
import 'package:moviles/LogicaJugador.dart';
import 'package:moviles/LogicaLadrillos.dart';
import 'package:moviles/LogicaPowerups.dart';

// ---- Vistas ----
import 'package:moviles/VistaPelota.dart';
import 'package:moviles/VistaJugador.dart';
import 'package:moviles/VistaLadrillo.dart';
import 'package:moviles/Powerup.dart';
import 'package:moviles/PaginaDeCubierta.dart';
import 'package:moviles/Pantallafinal.dart';
import 'package:moviles/PantallaVictoria.dart';

// ============================================================
//  PaginaPrincipal (StatefulWidget)
// ============================================================
class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({Key? key}) : super(key: key);

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

// ============================================================
//  _PaginaPrincipalState
//  Solo mantiene el estado y delega la lógica a los módulos.
// ============================================================
class _PaginaPrincipalState extends State<PaginaPrincipal> {

  // ----------------------------------------------------------------
  //  CONSTANTES DEL JUEGO
  // ----------------------------------------------------------------
  static const int    _vidasIniciales   = 3;
  static const int    _vidasMaximas     = 5;
  static const int    _duracionEfectoMs = 7000; // 7 s

  // ----------------------------------------------------------------
  //  MODELOS DE ESTADO
  // ----------------------------------------------------------------
  late ModeloPelota   _pelota;
  late ModeloJugador  _jugador;
  late List<ModeloLadrillo> _ladrillos;

  // ----------------------------------------------------------------
  //  ESTADO GENERAL DEL JUEGO
  // ----------------------------------------------------------------
  bool _juegoEmpezado = false;
  bool _juegoAcabado  = false;
  bool _juegoGanado   = false;   // ← NUEVO: condición de victoria
  int  _vidas         = _vidasIniciales;

  // ----------------------------------------------------------------
  //  POWER-UPS EN PANTALLA
  // ----------------------------------------------------------------
  final List<ModeloPowerUp> _powerUpsActivos = [];

  // ----------------------------------------------------------------
  //  TIMERS
  // ----------------------------------------------------------------
  Timer? _timerPrincipal;
  Timer? _timerEfectoRaqueta;
  Timer? _timerEfectoLento;

  // ================================================================
  //  INICIALIZACIÓN
  // ================================================================

  @override
  void initState() {
    super.initState();
    _inicializarEstado();
  }

  void _inicializarEstado() {
    _pelota    = ModeloPelota();
    _jugador   = ModeloJugador();
    _ladrillos = generarLadrillos();
  }

  // ================================================================
  //  BUCLE PRINCIPAL DEL JUEGO
  // ================================================================

  void _empezarJuego() {
    if (_juegoEmpezado) return;
    setState(() => _juegoEmpezado = true);

    _timerPrincipal = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      // 1. Actualizar dirección (bordes + raqueta)
      actualizarDireccion(_pelota, _jugador);

      // 2. Mover pelota
      final bool lento = _timerEfectoLento != null;
      setState(() => moverPelota(_pelota, tiempoLento: lento));

      // 3. Mover power-ups
      setState(() => moverPowerUps(_powerUpsActivos));

      // 4. Colisiones con ladrillos
      setState(() {
        comprobarColisionLadrillos(
          _pelota,
          _ladrillos,
          onColision: (lx, ly) => intentarGenerarPowerUp(
            _powerUpsActivos, lx, ly, anchoLadrillo,
          ),
        );
      });

      // 5. Comprobar victoria (todos los ladrillos rotos)
      if (todosTroceados(_ladrillos)) {
        timer.cancel();
        setState(() => _juegoGanado = true);
        return;
      }

      // 6. Recoger power-ups
      final List<ModeloPowerUp> recogidos =
      comprobarRecogida(_powerUpsActivos, _jugador);
      if (recogidos.isNotEmpty) {
        setState(() {
          for (final pu in recogidos) {
            _aplicarEfectoPowerUp(pu.tipo);
          }
        });
      }

      // 7. Comprobar muerte
      if (pelotaFueraDePantalla(_pelota)) {
        timer.cancel();
        _perderVida();
      }
    });
  }

  // ================================================================
  //  EFECTOS DE POWER-UPS
  //  Esta lógica permanece aquí porque necesita setState y Timers.
  // ================================================================

  void _aplicarEfectoPowerUp(TipoPowerUp tipo) {
    switch (tipo) {

    // ---- Rosa: raqueta grande ----
      case TipoPowerUp.racketaGrande:
        _timerEfectoRaqueta?.cancel();
        _jugador.ancho = ModeloJugador.anchoGrande;
        _timerEfectoRaqueta = Timer(
          const Duration(milliseconds: _duracionEfectoMs),
              () => setState(() {
            _jugador.ancho        = ModeloJugador.anchoNormal;
            _timerEfectoRaqueta   = null;
          }),
        );
        break;

    // ---- Azul: tiempo lento ----
      case TipoPowerUp.tiempoLento:
        _timerEfectoLento?.cancel();
        _timerEfectoLento = Timer(
          const Duration(milliseconds: _duracionEfectoMs),
              () => setState(() => _timerEfectoLento = null),
        );
        break;

    // ---- Amarillo: vida extra ----
      case TipoPowerUp.vidaExtra:
        if (_vidas < _vidasMaximas) _vidas++;
        break;
    }
  }

  void _cancelarEfectosTemporales() {
    _timerEfectoRaqueta?.cancel();
    _timerEfectoRaqueta = null;
    _timerEfectoLento?.cancel();
    _timerEfectoLento = null;
    _jugador.ancho = ModeloJugador.anchoNormal;
  }

  // ================================================================
  //  PERDER VIDA
  // ================================================================

  void _perderVida() {
    setState(() {
      _vidas--;
      if (_vidas <= 0) {
        _juegoAcabado = true;
        _cancelarEfectosTemporales();
      } else {
        _pelota.resetear();
        _jugador.resetear();
        _powerUpsActivos.clear();
        _cancelarEfectosTemporales();
        _juegoEmpezado = false;
      }
    });
  }

  // ================================================================
  //  REINICIO COMPLETO
  // ================================================================

  void _reiniciar() {
    _timerPrincipal?.cancel();
    _cancelarEfectosTemporales();
    setState(() {
      _pelota        = ModeloPelota();
      _jugador       = ModeloJugador();
      _ladrillos     = generarLadrillos();
      _juegoEmpezado = false;
      _juegoAcabado  = false;
      _juegoGanado   = false;
      _vidas         = _vidasIniciales;
      _powerUpsActivos.clear();
    });
  }

  // ================================================================
  //  LIMPIEZA
  // ================================================================

  @override
  void dispose() {
    _timerPrincipal?.cancel();
    _cancelarEfectosTemporales();
    super.dispose();
  }

  // ================================================================
  //  BUILD: solo composición de widgets
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          setState(() => moverIzquierda(_jugador));
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          setState(() => moverDerecha(_jugador));
        }
      },
      child: GestureDetector(
        onTap: _empezarJuego,
        onHorizontalDragUpdate: (details) {
          setState(() => moverConArrastre(
            _jugador,
            details.delta.dx,
            MediaQuery.of(context).size.width,
          ));
        },
        child: Scaffold(
          backgroundColor: Colors.deepPurpleAccent[100],
          body: Center(
            child: Stack(
              children: [

                // ---- 1. Pantalla de inicio ----
                Cubierta(juegoEmpezado: _juegoEmpezado),

                // ---- 2. HUD de vidas / Game Over ----
                PantallaFinal(
                  juegoAcabado: _juegoAcabado,
                  function: _reiniciar,
                  vidas: _vidas,
                ),

                // ---- 3. Pantalla de VICTORIA ----
                PantallaVictoria(
                  juegoGanado: _juegoGanado,
                  onReiniciar: _reiniciar,
                ),

                // ---- 4. Pelota ----
                VistaPelota(posX: _pelota.x, posY: _pelota.y),

                // ---- 5. Raqueta ----
                VistaJugador(posX: _jugador.x, jugadorWidth: _jugador.ancho),

                // ---- 6. Ladrillos ----
                ..._ladrillos.map((l) => VistaLadrillo(
                  ladrilloX:     l.x,
                  ladrilloY:     l.y,
                  ladrilloAlto:  altoLadrillo,
                  ladrilloAncho: anchoLadrillo,
                  ladrilloRoto:  l.roto,
                )),

                // ---- 7. Power-ups cayendo ----
                ..._powerUpsActivos.map((pu) => PowerUpWidget(
                  posX: pu.x,
                  posY: pu.y,
                  tipo: pu.tipo,
                )),

              ],
            ),
          ),
        ),
      ),
    );
  }
}