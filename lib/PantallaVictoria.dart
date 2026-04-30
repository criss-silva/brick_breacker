// ============================================================
//  PantallaVictoria.dart
//  Pantalla WIN que se muestra cuando el jugador rompe todos
//  los ladrillos. Muestra un mensaje de victoria y un botón
//  para volver a jugar.
// ============================================================

import 'package:flutter/material.dart';

class PantallaVictoria extends StatelessWidget {
  // true cuando el jugador ha roto todos los ladrillos
  final bool juegoGanado;

  // Callback para reiniciar (viene de PaginaPrincipal)
  final VoidCallback onReiniciar;

  const PantallaVictoria({
    Key? key,
    required this.juegoGanado,
    required this.onReiniciar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!juegoGanado) return Container();

    return Stack(
      children: [
        // ---- Fondo semitransparente ----
        Container(color: Colors.black45),

        // ---- Contenido centrado ----
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji trofeo
              const Text(
                '🏆',
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),

              // Texto WIN
              const Text(
                'W I N',
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  shadows: [
                    Shadow(
                      color: Colors.orange,
                      blurRadius: 12,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Subtítulo
              const Text(
                '¡Todos los ladrillos rotos!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // Botón "Volver a jugar"
              GestureDetector(
                onTap: onReiniciar,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    color: Colors.deepPurple,
                    child: const Text(
                      'Volver a jugar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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