//  pantalla_final.dart
//
//  Widget que se muestra encima del juego cuando el jugador pierde
//  todas las vidas (Game Over). Tiene dos modos de renderizado:
//
//  · juegoAcabado = true  → muestra el overlay de "GAME OVER" con
//    la puntuación final y tres botones de acción.
//  · juegoAcabado = false → actúa como HUD en partida: muestra
//    los corazones de vida y el marcador en las esquinas.
//
//  Al montarse, intenta guardar automáticamente el resultado en el
//  ranking (solo una vez, gracias al flag _guardado).

import 'package:flutter/material.dart';
import 'package:moviles/game_state.dart';
import 'package:moviles/PantallaRanking.dart';
import 'package:moviles/PantallaNombre.dart';

class PantallaFinal extends StatefulWidget {
  // true cuando el jugador ha perdido y queremos mostrar el Game Over
  final bool juegoAcabado;

  // Callback para reiniciar la partida (lo conecta PaginaPrincipal)
  final VoidCallback function;

  // Número de vidas restantes (se usan para los iconos de corazón en el HUD)
  final int vidas;

  // Puntuación acumulada en esta partida
  final int puntuacion;

  const PantallaFinal({
    Key? key,
    required this.juegoAcabado,
    required this.function,
    required this.vidas,
    required this.puntuacion,
  }) : super(key: key);

  @override
  State<PantallaFinal> createState() => _PantallaFinalState();
}

class _PantallaFinalState extends State<PantallaFinal> {
  // Evita guardar el resultado más de una vez si el widget se reconstruye
  bool _guardado = false;

  @override
  void initState() {
    super.initState();
    // Intentamos guardar en cuanto el widget se monta por primera vez
    _guardarResultado();
  }

  // Lee el nombre del jugador de GameState y añade la entrada al ranking.
  // La guarda de _guardado impide duplicados si build() llama a este método
  Future<void> _guardarResultado() async {
    if (widget.juegoAcabado && !_guardado) {
      _guardado = true;
      final nombre = GameState.JugadorActual;
      final score  = widget.puntuacion;
      if (nombre.isNotEmpty) {
        await RankingManager().AnadirResultado(name: nombre, score: score);
      }
    }
  }

  // Navega a la pantalla de ranking sin eliminar la pila de navegación,
  // para que el usuario pueda volver atrás con el botón de retroceso.
  void _verRanking() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PantallaRanking()),
    );
  }

  // Vuelve al menú principal limpiando todo el historial de navegación
  // y reseteando el estado global de la partida.
  void _volverMenu() {
    GameState.reset();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PantallaNombre()),
          (route) => false, // elimina todas las rutas anteriores
    );
  }

  // Decide qué renderizar según el estado del juego:
  //   · Si juegoAcabado → overlay completo de Game Over
  //   · Si no            → HUD con solo vidas y puntuacion
  @override
  Widget build(BuildContext context) {
    if (widget.juegoAcabado) {
      // Llamada de seguridad extra por si initState no llegó a guardar
      _guardarResultado();

      // GAME OVER
      return Stack(
        children: [
          // Fondo semitransparente para oscurecer el juego por debajo
          Container(color: Colors.black54),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Título
                const Text(
                  'G A M E   O V E R',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Puntuación final
                Text(
                  'Puntuación: ${widget.puntuacion}',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 24),

                // Botón PLAY AGAIN: llama al callback de PaginaPrincipal
                // que reinicia el estado del juego sin salir de la pantalla
                GestureDetector(
                  onTap: widget.function,
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
                const SizedBox(height: 12),

                // Botón VER RANKING: abre PantallaRanking sobre la actual
                GestureDetector(
                  onTap: _verRanking,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      color: Colors.deepPurple[700],
                      child: const Text(
                        'VER RANKING',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Botón MENÚ PRINCIPAL: sale completamente y limpia la sesión
                GestureDetector(
                  onTap: _volverMenu,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      color: Colors.grey[700],
                      child: const Text(
                        'MENÚ PRINCIPAL',
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

    // Cuando el juego sigue activo este widget actúa como capa de información:
    // corazones a la izquierda y puntuación a la derecha.
    return Stack(
      children: [
        // Corazones de vida (uno por cada vida restante)
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                widget.vidas,
                    (_) => const Icon(
                  Icons.favorite,
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
            ),
          ),
        ),

        // Marcador de puntuación en la esquina superior derecha
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              '${widget.puntuacion}',
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