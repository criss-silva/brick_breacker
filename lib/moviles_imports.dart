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
export 'package:moviles/ModeloPelota.dart';
export 'package:moviles/ModeloJugador.dart';
export 'package:moviles/ModeloLadrillo.dart';
export 'package:moviles/modelos.dart';

// ── Lógica de juego (sin Flutter) ───────────────────────────
export 'package:moviles/LogicaPelota.dart';
export 'package:moviles/LogicaJugador.dart';
export 'package:moviles/LogicaLadrillos.dart';
export 'package:moviles/LogicaPowerups.dart';

// ── Vistas (widgets Flutter) ─────────────────────────────────
export 'package:moviles/VistaPelota.dart';
export 'package:moviles/VistaJugador.dart';
export 'package:moviles/VistaLadrillo.dart';
export 'package:moviles/Powerup.dart';
export 'package:moviles/PaginaDeCubierta.dart';
export 'package:moviles/Pantallafinal.dart';
export 'package:moviles/PantallaVictoria.dart';

// ── Estado global ────────────────────────────────────────────
export 'package:moviles/game_state.dart';

// ── Lógica de control extraída de PaginaPrincipal ───────────
// Contiene _inicializarEstado, _empezarJuego, _perderVida, etc.
export 'package:moviles/GameLogic.dart';