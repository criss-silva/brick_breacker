//  pantalla_victoria.dart
//
//  Overlay que aparece cuando el jugador destruye todos los ladrillos.
//  Muestra un mensaje de victoria con la puntuación final y ofrece
//  tres opciones: volver a jugar, ver el ranking o ir al menú.
//
//  Al igual que PantallaFinal, guarda el resultado en el ranking
//  al montarse, protegido por un flag para evitar duplicados.
//
//  Flujo de navegación desde aquí:
//    · Volver a jugar → callback onReiniciar (sin salir de PaginaPrincipal)
//    · Ver Ranking    → push PantallaRanking (volvible con "atrás")
//    · Menú principal → pushAndRemoveUntil PantallaNombre (limpia la pila)


import 'package:flutter/material.dart';
import 'package:moviles/game_state.dart';
import 'package:moviles/PantallaRanking.dart';
import 'package:moviles/PantallaNombre.dart';

class PantallaVictoria extends StatefulWidget {
  // true cuando todos los ladrillos han sido destruidos
  final bool juegoGanado;

  // Callback que reinicia la partida desde PaginaPrincipal
  final VoidCallback onReiniciar;

  // Puntuación obtenida en esta partida
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
  // Previene que el resultado se guarde más de una vez si el widget
  // se reconstruye por cualquier motivo mientras está visible.
  bool _guardado = false;

  @override
  void initState() {
    super.initState();
    _guardarResultado();
  }

  // Persiste el resultado solo cuando hay victoria real y el nombre del
  // jugador está disponible en GameState.
  Future<void> _guardarResultado() async {
    if (widget.juegoGanado && !_guardado) {
      _guardado = true;
      final nombre = GameState.JugadorActual;
      final score  = widget.puntuacion;
      if (nombre.isNotEmpty) {
        await RankingManager().AnadirResultado(name: nombre, score: score);
      }
    }
  }

  // Abre el ranking encima de la pantalla actual; el usuario puede
  // volver atrás con el botón de retroceso del AppBar.
  void _verRanking() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PantallaRanking()),
    );
  }

  // Vuelve al menú principal eliminando todas las rutas anteriores
  // y reseteando el estado global de la sesión.
  void _volverMenu() {
    GameState.reset();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PantallaNombre()),
          (route) => false, // descarta toda la pila de navegación
    );
  }


  // Si todavía no hay victoria, devuelve un widget vacío para no interferir
  // con el renderizado del juego. Cuando juegoGanado == true, muestra el
  // overlay completo sobre el juego.
  @override
  Widget build(BuildContext context) {
    // Mientras el juego sigue en marcha este widget no pinta nada
    if (!widget.juegoGanado) return const SizedBox.shrink();

    // Llamada de seguridad por si initState no llegó a ejecutarse
    _guardarResultado();

    return Stack(
      children: [
        // Capa semitransparente que oscurece el tablero de juego
        Container(color: Colors.black54),

        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Icono y título
              const Text('🏆', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 12),
              const Text(
                'W I N',
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  // Sombra anaranjada para dar sensación de brillo/fuego
                  shadows: [Shadow(color: Colors.orange, blurRadius: 12)],
                ),
              ),
              const SizedBox(height: 8),

              // Mensaje secundario descriptivo
              const Text(
                '¡Todos los ladrillos rotos!',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Puntuación final en grande
              Text(
                'Puntuación: ${widget.puntuacion}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Botón VOLVER A JUGAR
              // Invoca el callback de PaginaPrincipal para reiniciar sin
              // abandonar la pantalla de juego.
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

              // Botón VER RANKING
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