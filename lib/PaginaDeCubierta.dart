// ============================================================
//  PaginaDeCubierta.dart
//  Pantalla de inicio antes de pulsar para jugar.
// ============================================================

import 'package:flutter/material.dart';

class Cubierta extends StatelessWidget {
  final bool juegoEmpezado;

  const Cubierta({Key? key, required this.juegoEmpezado}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (juegoEmpezado) return const SizedBox.shrink();

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
          const SizedBox(height: 14),
          const Text(
            '🩷 Raqueta grande   🔵 Tiempo lento   💛 Vida extra   🟣 Bola invencible',
            style: TextStyle(color: Colors.white70, fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            '👻 Fantasma = ×2 puntos   ♻️ Regenerador = se repara solo',
            style: TextStyle(color: Colors.white60, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}