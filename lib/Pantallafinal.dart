// ============================================================
//  Pantallafinal.dart
//  Pantalla Game Over + HUD de vidas y puntuación.
// ============================================================

import 'package:flutter/material.dart';

class PantallaFinal extends StatelessWidget {
  final bool juegoAcabado;
  final VoidCallback function;
  final int vidas;
  final int puntuacion;

  const PantallaFinal({
    Key? key,
    required this.juegoAcabado,
    required this.function,
    required this.vidas,
    required this.puntuacion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (juegoAcabado) {
      return Stack(
        children: [
          Container(color: Colors.black54),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'G A M E   O V E R',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Puntuación: $puntuacion',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: function,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      color: Colors.deepPurple,
                      child: const Text(
                        'PLAY AGAIN',
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

    // HUD durante la partida: vidas + puntuación
    return Stack(
      children: [
        // Vidas (esquina superior izquierda)
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                vidas,
                    (_) => const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
              ),
            ),
          ),
        ),
        // Puntuación (esquina superior derecha)
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              '$puntuacion',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}