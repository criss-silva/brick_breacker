import 'package:flutter/material.dart';
import 'package:moviles/game_state.dart';
import 'package:moviles/PantallaRanking.dart';
import 'package:moviles/PantallaNombre.dart';

class PantallaVictoria extends StatefulWidget {
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
  State<PantallaVictoria> createState() => _PantallaVictoriaState();
}

class _PantallaVictoriaState extends State<PantallaVictoria> {
  bool _guardado = false;

  @override
  void initState() {
    super.initState();
    _guardarResultado();
  }

  Future<void> _guardarResultado() async {
    if (widget.juegoGanado && !_guardado) {
      _guardado = true;
      final nombre = GameState.currentPlayerName;
      final score = widget.puntuacion;
      if (nombre.isNotEmpty) {
        await RankingManager().addResult(name: nombre, score: score);
      }
    }
  }

  //boton para ver el ranking
  void _verRanking() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PantallaRanking()),
    );
  }

  //boton para ver el menu
  void _volverMenu() {
    GameState.reset();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PantallaNombre()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.juegoGanado) return const SizedBox.shrink();

    _guardarResultado();

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
                'Puntuación: ${widget.puntuacion}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: widget.onReiniciar,
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
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _verRanking,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    color: Colors.deepPurple[700],
                    child: const Text(
                      'Ver Ranking',
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