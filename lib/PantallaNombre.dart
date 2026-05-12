//  pantalla_nombre.dart
//
//  Primera pantalla que ve el jugador al abrir la app. Muestra
//  el título del juego y pide el nombre del jugador antes de
//  empezar. El nombre se guarda en GameState para usarse luego
//  en el ranking.

import 'package:flutter/material.dart';
import 'package:moviles/game_state.dart';
import 'package:moviles/PaginaPrincipal.dart';

class PantallaNombre extends StatefulWidget {
  const PantallaNombre({Key? key}) : super(key: key);

  @override
  State<PantallaNombre> createState() => _PantallaNombreState();
}

class _PantallaNombreState extends State<PantallaNombre> {
  // Controlador del campo de texto; nos permite leer su contenido
  // en cualquier momento sin necesidad de un setState.
  final _controller = TextEditingController();

  // Valida que el nombre no esté vacío, lo persiste en GameState y navega
  // a PaginaPrincipal reemplazando la ruta actual (el usuario no podrá
  // volver atrás a esta pantalla con el botón de retroceso).
  void _guardarYContinuar() {
    final nombre = _controller.text.trim(); // quitamos espacios extra
    if (nombre.isEmpty) return;             // no hacemos nada si está vacío

    // Guardamos el nombre en el estado global para que todas las pantallas
    // (ranking, victoria, game over) puedan acceder a él sin pasarlo por props.
    GameState.JugadorActual = nombre;

    // pushReplacement elimina esta pantalla de la pila; si el usuario pulsa
    // "atrás" desde PaginaPrincipal, la app se cierra en lugar de volver aquí.
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

            // Título del juego
            const Text(
              'BRICK BREAKER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            //  Etiqueta del campo
            const Text(
              'Nombre del jugador',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 20),

            //  Campo de texto
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
                  // Borde cuando el campo no está enfocado
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // Borde cuando el campo está activo (más grueso para resaltar)
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // Permite confirmar con la tecla "Intro" del teclado virtual
                onSubmitted: (_) => _guardarYContinuar(),
              ),
            ),
            const SizedBox(height: 30),

            //  Botón JUGAR
            // Usa GestureDetector + Container en lugar de ElevatedButton
            // para tener control total sobre el estilo visual.
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