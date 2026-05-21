//  pantalla_nombre.dart
//
//  Primera pantalla que ve el jugador al abrir la app. Muestra
//  el título del juego y pide el nombre del jugador antes de
//  empezar. El nombre se guarda en GameState para usarse luego
//  en el ranking.

import 'package:flutter/material.dart';
import 'barrel_vistas.dart';
import 'package:moviles/logica/barrel_logica.dart';

class PantallaNombre extends StatefulWidget {
  const PantallaNombre({Key? key}) : super(key: key);

  @override
  State<PantallaNombre> createState() => _PantallaNombreState();
}

class _PantallaNombreState extends State<PantallaNombre> {

  final _controller = TextEditingController();
  void _guardarYContinuar() {
    final nombre = _controller.text.trim();
    if (nombre.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Falta tu nombre!'),
          content: const Text('Debes introducir un nombre para poder jugar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    GameState.JugadorActual = nombre;

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
          mainAxisSize: MainAxisSize.min, // el Column solo ocupa lo necesario
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
                autofocus: true,           // el teclado aparece al entrar a la pantalla
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 12),
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