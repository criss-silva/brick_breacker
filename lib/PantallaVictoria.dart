// ============================================================
//  PantallaVictoria.dart
//  Pantalla WIN cuando se rompen todos los ladrillos.
//  Muestra la puntuación final.
// ============================================================

import 'package:flutter/material.dart';

class PantallaVictoria extends StatelessWidget {
  final bool juegoGanado;
  final VoidCallback onReiniciar;
  final int puntuacion;

  const PantallaVictoria({
    Key? key,
    required this.juegoGanado,
    required this.onReiniciar,
    required this.puntuacion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!juegoGanado) return const SizedBox.shrink();

    return Stack(
      children: [
        Container(color: Colors.black54),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 12),
              const Text(
                'W I N',
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  shadows: [Shadow(color: Colors.orange, blurRadius: 12)],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '¡Todos los ladrillos rotos!',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                'Puntuación: $puntuacion',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: onReiniciar,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    color: Colors.deepPurple,
                    child: const Text(
                      'Volver a jugar',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}