import 'package:flutter/material.dart';
import 'package:moviles/game_state.dart';
import 'package:moviles/PaginaPrincipal.dart';

class PantallaNombre extends StatefulWidget {
  const PantallaNombre({Key? key}) : super(key: key);

  @override
  State<PantallaNombre> createState() => _PantallaNombreState();
}

class _PantallaNombreState extends State<PantallaNombre> {
  final _controller = TextEditingController();

  void _guardarYContinuar() {
    final nombre = _controller.text.trim();
    if (nombre.isEmpty) return;

    GameState.currentPlayerName = nombre;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PaginaPrincipal()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent[100],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'BRICK BREAKER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Nombre del jugador',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'Escribe tu nombre',
                  hintStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => _guardarYContinuar(),
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _guardarYContinuar,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'JUGAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}