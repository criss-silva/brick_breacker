// ============================================================
//  PaginaPrincipal.dart
//  Orquestador principal. Solo gestiona estado y coordina módulos.
//
//  MAPA DE MÓDULOS:
//  ┌──────────────────────┬──────────────────────────────────────┐
//  │ Archivo              │ Responsabilidad                       │
//  ├──────────────────────┼──────────────────────────────────────┤
//  │ modelo_pelota        │ Posición y dirección de la pelota     │
//  │ modelo_jugador       │ Posición y ancho de la raqueta        │
//  │ modelo_ladrillo      │ Estado de cada ladrillo (tipo, vida)  │
//  │ modelos              │ ModeloPowerUp y TipoPowerUp            │
//  ├──────────────────────┼──────────────────────────────────────┤
//  │ logica_pelota        │ Movimiento y rebote de bordes/raqueta │
//  │ logica_jugador       │ Mover raqueta con teclado/arrastre    │
//  │ logica_ladrillos     │ Generación, colisiones, regen, fantasma│
//  │ logica_powerups      │ Spawn, caída y recogida de power-ups  │
//  ├──────────────────────┼──────────────────────────────────────┤
//  │ vista_pelota         │ Widget pelota                         │
//  │ vista_jugador        │ Widget raqueta                        │
//  │ vista_ladrillo       │ Widget ladrillo (color por tipo/vida) │
//  │ Powerup              │ Widget power-up cayendo               │
//  │ PaginaDeCubierta     │ Pantalla de inicio                    │
//  │ Pantallafinal        │ HUD vidas+puntos / Game Over          │
//  │ PantallaVictoria     │ Pantalla WIN                          │
//  └──────────────────────┴──────────────────────────────────────┘
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Modelos ──────────────────────────────────────────────────────────
import 'package:moviles/ModeloPelota.dart';
import 'package:moviles/ModeloJugador.dart';
import 'package:moviles/ModeloLadrillo.dart';
import 'package:moviles/modelos.dart';

// ── Lógica ───────────────────────────────────────────────────────────
import 'package:moviles/LogicaPelota.dart';
import 'package:moviles/LogicaJugador.dart';
import 'package:moviles/LogicaLadrillos.dart';
import 'package:moviles/LogicaPowerups.dart';

// ── Vistas ───────────────────────────────────────────────────────────
import 'package:moviles/VistaPelota.dart';
import 'package:moviles/VistaJugador.dart';
import 'package:moviles/VistaLadrillo.dart';
import 'package:moviles/Powerup.dart';
import 'package:moviles/PaginaDeCubierta.dart';
import 'package:moviles/Pantallafinal.dart';
import 'package:moviles/PantallaVictoria.dart';

// ── Estado ──────────────────────────────────────────────────────────
import 'package:moviles/game_state.dart';

// ============================================================
class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({Key? key}) : super(key: key);

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {

  // ── Constantes ──────────────────────────────────────────────────
  static const int _vidasIniciales       = 3;
  static const int _vidasMaximas         = 5;
  static const int _duracionEfectoMs     = 7000; // 7 s (raqueta, lento)
  static const int _duracionInvencibleMs = 5000; // 5 s (bola invencible)

  // ── Modelos de estado ───────────────────────────────────────────
  late ModeloPelota         _pelota;
  late ModeloJugador        _jugador;
  late List<ModeloLadrillo> _ladrillos;

  // ── Estado general ──────────────────────────────────────────────
  bool _juegoEmpezado = false;
  bool _juegoAcabado  = false;
  bool _juegoGanado   = false;
  int  _vidas         = _vidasIniciales;

  // ── Puntuación ──────────────────────────────────────────────────
  int  _puntuacion        = 0;
  bool _multiplicadorx2   = false; // activado al romper el fantasma

  // ── Power-ups en pantalla ───────────────────────────────────────
  final List<ModeloPowerUp> _powerUpsActivos = [];

  // ── Timers ──────────────────────────────────────────────────────
  Timer? _timerPrincipal;
  Timer? _timerEfectoRaqueta;
  Timer? _timerEfectoLento;
  Timer? _timerBolaInvencible;
  Timer? _timerRegeneradores; // tick cada 1 s para regeneradores
  Timer? _timerFantasma;      // tick para actualizar visibilidad

  // ── Flags de efectos activos ────────────────────────────────────
  bool _bolaInvencible = false;

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
  //  PEDIR NOMBRE ANTES DE JUGAR
  // ================================================================

  Future<void> _pedirNombreYEmpezar() async {
    if (_juegoEmpezado) return;
    if (GameState.currentPlayerName.isNotEmpty) {
      _empezarJuego();
      return;
    }
    _empezarJuego();
  }

  // ================================================================
  //  BUCLE PRINCIPAL
  // ================================================================

  void _empezarJuego() {
    if (_juegoEmpezado) return;
    setState(() => _juegoEmpezado = true);

    // Timer de regeneradores: comprueba cada segundo
    _timerRegeneradores = Timer.periodic(const Duration(seconds: 1), (_) {
      tickRegeneradores(_ladrillos);
    });

    // Timer principal: 10 ms = ~100 fps de lógica
    _timerPrincipal = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      // 1. Dirección pelota (bordes + raqueta)
      actualizarDireccion(_pelota, _jugador);

      // 2. Mover pelota
      final bool lento = _timerEfectoLento != null;
      setState(() {
        moverPelota(_pelota, tiempoLento: lento);
      });

      // 3. Mover power-ups
      setState(() => moverPowerUps(_powerUpsActivos));

      // 4. Fantasma: actualizar visibilidad cada frame
      final int ahora = DateTime.now().millisecondsSinceEpoch;
      setState(() => tickFantasma(_ladrillos, ahora));

      // 5. Colisiones con ladrillos
      final List<ResultadoColision> colisiones = comprobarColisionLadrillos(
        _pelota,
        _ladrillos,
        bolaInvencible: _bolaInvencible,
      );

      if (colisiones.isNotEmpty) {
        setState(() {
          for (final col in colisiones) {
            // Sumar puntos (con multiplicador si corresponde)
            if (col.puntosGanados > 0) {
              int pts = col.puntosGanados;
              if (_multiplicadorx2) pts *= 2;
              if (col.multiplicarPuntuacion) {
                // El propio bloque fantasma activa el x2 Y da puntos x2
                pts *= 2;
                _multiplicadorx2 = true;
              }
              _puntuacion += pts;
            }

            // Spawnear power-up fijo si el ladrillo tiene uno asignado
            if (col.tipoPowerUpSoltado != null) {
              spawnPowerUpFijo(
                _powerUpsActivos,
                col.tipoPowerUpSoltado!,
                col.ladrilloX,
                col.ladrilloY,
                anchoLadrillo,
              );
            } else if (col.puntosGanados > 0) {
              // Ladrillo normal roto: intentar soltar pw aleatorio
              intentarGenerarPowerUpAleatorio(
                _powerUpsActivos,
                col.ladrilloX,
                col.ladrilloY,
                anchoLadrillo,
              );
            }
          }
        });
      }

      // 6. Victoria
      if (todosTroceados(_ladrillos)) {
        timer.cancel();
        _timerRegeneradores?.cancel();
        setState(() => _juegoGanado = true);
        return;
      }

      // 7. Recoger power-ups
      final List<ModeloPowerUp> recogidos =
      comprobarRecogida(_powerUpsActivos, _jugador);
      if (recogidos.isNotEmpty) {
        setState(() {
          for (final pu in recogidos) {
            _aplicarEfectoPowerUp(pu.tipo);
          }
        });
      }

      // 8. Muerte
      if (pelotaFueraDePantalla(_pelota)) {
        timer.cancel();
        _timerRegeneradores?.cancel();
        _perderVida();
      }
    });
  }

  // ================================================================
  //  EFECTOS DE POWER-UPS
  //  Aquí porque necesitan setState y Timer.
  // ================================================================

  void _aplicarEfectoPowerUp(TipoPowerUp tipo) {
    switch (tipo) {

    // ── Rosa: raqueta grande ─────────────────────────────────────
      case TipoPowerUp.racketaGrande:
        _timerEfectoRaqueta?.cancel();
        _jugador.ancho = ModeloJugador.anchoGrande;
        _timerEfectoRaqueta = Timer(
          const Duration(milliseconds: _duracionEfectoMs),
              () => setState(() {
            _jugador.ancho      = ModeloJugador.anchoNormal;
            _timerEfectoRaqueta = null;
          }),
        );
        break;

    // ── Azul: tiempo lento ───────────────────────────────────────
      case TipoPowerUp.tiempoLento:
        _timerEfectoLento?.cancel();
        _timerEfectoLento = Timer(
          const Duration(milliseconds: _duracionEfectoMs),
              () => setState(() => _timerEfectoLento = null),
        );
        break;

    // ── Amarillo: vida extra ─────────────────────────────────────
      case TipoPowerUp.vidaExtra:
        if (_vidas < _vidasMaximas) {
          setState(() => _vidas++);
        }
        break;

    // ── Morado: bola invencible ──────────────────────────────────
      case TipoPowerUp.bolaInvencible:
        _timerBolaInvencible?.cancel();
        _bolaInvencible = true;
        _timerBolaInvencible = Timer(
          const Duration(milliseconds: _duracionInvencibleMs),
              () => setState(() {
            _bolaInvencible      = false;
            _timerBolaInvencible = null;
          }),
        );
        break;
    }
  }

  void _cancelarEfectosTemporales() {
    _timerEfectoRaqueta?.cancel();  _timerEfectoRaqueta  = null;
    _timerEfectoLento?.cancel();    _timerEfectoLento    = null;
    _timerBolaInvencible?.cancel(); _timerBolaInvencible = null;
    _jugador.ancho  = ModeloJugador.anchoNormal;
    _bolaInvencible = false;
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
    _timerRegeneradores?.cancel();
    _timerFantasma?.cancel();
    _cancelarEfectosTemporales();
    setState(() {
      _pelota          = ModeloPelota();
      _jugador         = ModeloJugador();
      _ladrillos       = generarLadrillos();
      _juegoEmpezado   = false;
      _juegoAcabado    = false;
      _juegoGanado     = false;
      _vidas           = _vidasIniciales;
      _puntuacion      = 0;
      _multiplicadorx2 = false;
      _powerUpsActivos.clear();
    });
  }

  // ================================================================
  //  DISPOSE
  // ================================================================

  @override
  void dispose() {
    _timerPrincipal?.cancel();
    _timerRegeneradores?.cancel();
    _timerFantasma?.cancel();
    _cancelarEfectosTemporales();
    super.dispose();
  }

  // ================================================================
  //  BUILD
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
        onTap: _pedirNombreYEmpezar,
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

                // ── 1. Pantalla de inicio ──────────────────────────
                Cubierta(juegoEmpezado: _juegoEmpezado),

                // ── 2. HUD vidas+puntos / Game Over ───────────────
                PantallaFinal(
                  juegoAcabado: _juegoAcabado,
                  function:     _reiniciar,
                  vidas:        _vidas,
                  puntuacion:   _puntuacion,
                ),

                // ── 3. Pantalla de VICTORIA ────────────────────────
                PantallaVictoria(
                  juegoGanado: _juegoGanado,
                  onReiniciar: _reiniciar,
                  puntuacion:  _puntuacion,
                ),

                // ── 4. Pelota (color especial si invencible) ───────
                VistaPelota(
                  posX:       _pelota.x,
                  posY:       _pelota.y,
                  invencible: _bolaInvencible,
                ),

                // ── 5. Raqueta ─────────────────────────────────────
                VistaJugador(
                  posX:          _jugador.x,
                  jugadorWidth:  _jugador.ancho,
                ),

                // ── 6. Ladrillos ───────────────────────────────────
                ..._ladrillos.map((l) => VistaLadrillo(
                  ladrillo: l,
                  ancho:    anchoLadrillo,
                  alto:     altoLadrillo,
                )),

                // ── 7. Power-ups cayendo ───────────────────────────
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