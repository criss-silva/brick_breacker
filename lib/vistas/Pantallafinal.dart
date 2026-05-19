

import 'package:flutter/material.dart';
import 'barrel_vistas.dart';
import 'package:moviles/logica/barrel_logica.dart';

class PantallaFinal extends StatefulWidget {
  // true cuando el jugador ha perdido y queremos mostrar el Game Over
  final bool juegoAcabado;


  final VoidCallback function;

  // vidas restantes
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
  State<PantallaFinal> createState() => _PantallaFinalState();
}

class _PantallaFinalState extends State<PantallaFinal> {
  bool _guardado = false;

  @override
  void initState() {
    super.initState();

    _guardarResultado();
  }


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


  void _verRanking() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PantallaRanking()),
    );
  }


  void _volverMenu() {
    GameState.reset();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PantallaNombre()),
          (route) => false, // elimina todas las rutas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.juegoAcabado) {

      _guardarResultado();


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
//boton para el menu
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


    return Stack(
      children: [
 //corazones de vidas restantes
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 20, right: 10,),
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

        //ountuacion
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 20, right: 10,),
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