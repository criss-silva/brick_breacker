// ============================================================
//  pantallafinal.dart
//  Pantalla de Game Over con botón para reiniciar.
//  Ahora también recibe las vidas para mostrarlas en el HUD
//  (la barra de información durante la partida).
// ============================================================

import 'package:flutter/material.dart';

class PantallaFinal extends StatelessWidget {
  // true cuando el jugador ha perdido todas las vidas
  final bool juegoAcabado;

  // Función de callback para reiniciar (viene de PaginaPrincipal)
  final VoidCallback function;

  // Número de vidas actuales (para el HUD durante la partida)
  final int vidas;

  const PantallaFinal({
    Key? key,
    required this.juegoAcabado,
    required this.function,
    required this.vidas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si el juego ha acabado mostramos la pantalla de Game Over
    if (juegoAcabado) {
      return Stack(
        children: [
          // Texto "GAME OVER"
          Container(
            alignment: const Alignment(0, -0.3),
            child: const Text(
              'G A M E   O V E R',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Botón "PLAY AGAIN"
          Container(
            alignment: const Alignment(0, 0),
            child: GestureDetector(
              onTap: function,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.deepPurple,
                  child: const Text(
                    'PLAY AGAIN',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Si el juego está en curso, mostramos el HUD con las vidas
    // en la parte superior izquierda de la pantalla
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mostramos un corazón por cada vida que tiene el jugador
            // (máximo 5, ver constante en PaginaPrincipal)
            ...List.generate(
              vidas,
                  (index) => const Icon(
                Icons.favorite,
                color: Colors.redAccent,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}