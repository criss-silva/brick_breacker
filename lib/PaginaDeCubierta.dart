// ============================================================
//  PaginaDeCubierta.dart
//  Pantalla de inicio que se muestra antes de que el jugador
//  pulse para empezar. No tiene cambios de lógica, solo
//  se añade un pequeño texto explicativo de los power-ups.
// ============================================================

import 'package:flutter/material.dart';

class Cubierta extends StatelessWidget {
  // true cuando el juego ya ha empezado (se oculta esta pantalla)
  final bool juegoEmpezado;

  const Cubierta({Key? key, required this.juegoEmpezado}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si el juego ya empezó, devolvemos un contenedor vacío (invisible)
    if (juegoEmpezado) return Container();

    // Pantalla de bienvenida con instrucciones básicas
    return Container(
      alignment: const Alignment(0, -0.1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pulsa para jugar',
            style: TextStyle(
              color: Colors.deepPurple[400],
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Pequeña leyenda de power-ups para que el jugador sepa qué son
          const Text(
            '🩷 Raqueta grande   🔵 Tiempo lento   💛 Vida extra',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}