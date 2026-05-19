// ============================================================
//  moviles_imports.dart
//  Barrel de imports del proyecto.
//
//  En lugar de repetir todos los imports en cada archivo,
//  basta con escribir una sola línea:
//    import 'package:moviles/moviles_imports.dart';
//
//  Si añades un archivo nuevo al proyecto, agrégalo aquí
//  y automáticamente estará disponible en todos los sitios
//  que ya importen este barrel.
// ============================================================

// ── Flutter y Dart core ─────────────────────────────────────
export 'dart:async';
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';

// ── Modelos (estado puro, sin Flutter) ──────────────────────
export 'package:moviles/modelos/ModeloPelota.dart';
export 'package:moviles/modelos/ModeloJugador.dart';
export 'package:moviles/modelos/ModeloLadrillo.dart';
export 'package:moviles/modelos/modelos.dart';

// ── Lógica de juego (sin Flutter) ───────────────────────────
export 'package:moviles/logica/LogicaPelota.dart';
export 'package:moviles/logica/LogicaJugador.dart';
export 'package:moviles/logica/LogicaLadrillos.dart';
export 'package:moviles/logica/LogicaPowerups.dart';

// ── Vistas (widgets Flutter) ─────────────────────────────────
export 'package:moviles/vistas/VistaPelota.dart';
export 'package:moviles/vistas/VistaJugador.dart';
export 'package:moviles/vistas/VistaLadrillo.dart';
export 'package:moviles/vistas/Powerup.dart';
export 'package:moviles/vistas/PaginaDeCubierta.dart';
export 'package:moviles/vistas/Pantallafinal.dart';
export 'package:moviles/vistas/PantallaVictoria.dart';

// ── Estado global ────────────────────────────────────────────
export 'package:moviles/logica/game_state.dart';

// ── Lógica de control extraída de PaginaPrincipal ───────────
// Contiene _inicializarEstado, _empezarJuego, _perderVida, etc.
export 'package:moviles/logica/GameLogic.dart';