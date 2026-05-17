// ============================================================
//  PaginaPrincipal.dart
//
//  Ahora este widget es casi completamente "tonto":
//  - NO tiene estado propio (es StatelessWidget)
//  - Lee el estado de GameModel con context.watch<GameModel>()
//  - Llama a métodos de GameModel con context.read<GameModel>()
//
//  ¿Qué es context.watch vs context.read?
//
//  context.watch<GameModel>()
//    → Suscribe este widget al modelo. Cada vez que GameModel
//      llama notifyListeners(), este widget se reconstruye.
//      Úsalo en build() para leer valores que se muestran en pantalla.
//
//  context.read<GameModel>()
//    → Accede al modelo UNA VEZ sin suscribirse.
//      Úsalo en callbacks (onTap, onKey…) donde no necesitas
//      reconstruir el widget, solo llamar a un método.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';       // <-- necesario para watch/read
import 'package:moviles/GameModel.dart';        // <-- el nuevo modelo central
import 'package:moviles/VistaJugador.dart';
import 'package:moviles/VistaPelota.dart';
import 'package:moviles/VistaLadrillo.dart';
import 'package:moviles/Powerup.dart';
import 'package:moviles/Pantallafinal.dart';
import 'package:moviles/PantallaVictoria.dart';
import 'package:moviles/PaginaDeCubierta.dart';
import 'package:moviles/LogicaLadrillos.dart';  // anchoLadrillo, altoLadrillo

// PaginaPrincipal ahora es StatelessWidget.
// Ya no necesita ser Stateful porque el estado vive en GameModel.
class PaginaPrincipal extends StatelessWidget {
  const PaginaPrincipal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // context.watch<GameModel>() suscribe este widget al modelo.
    // Cada llamada a notifyListeners() en GameModel reconstruye este build().
    final GameModel modelo = context.watch<GameModel>();

    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        // context.read: solo necesitamos llamar al método, no suscribirnos.
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          context.read<GameModel>().moverIzquierda();
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          context.read<GameModel>().moverDerecha();
        }
      },
      child: GestureDetector(
        onTap: () => context.read<GameModel>().empezarJuego(),
        onHorizontalDragUpdate: (details) {
          context.read<GameModel>().moverConArrasteDedo(
            details.delta.dx,
            MediaQuery.of(context).size.width,
          );
        },
        child: Scaffold(
          backgroundColor: Colors.deepPurpleAccent[100],
          body: Center(
            child: Stack(
              children: [

                // 1. Pantalla de inicio
                Cubierta(juegoEmpezado: modelo.juegoEmpezado),

                // 2. HUD de vidas y puntos / overlay Game Over
                PantallaFinal(
                  juegoAcabado: modelo.juegoAcabado,
                  function:     () => context.read<GameModel>().reiniciar(),
                  vidas:        modelo.vidas,
                  puntuacion:   modelo.puntuacion,
                ),

                // 3. Overlay de victoria
                PantallaVictoria(
                  juegoGanado: modelo.juegoGanado,
                  onReiniciar: () => context.read<GameModel>().reiniciar(),
                  puntuacion:  modelo.puntuacion,
                ),

                // 4. Pelota
                VistaPelota(
                  posX:       modelo.pelota.x,
                  posY:       modelo.pelota.y,
                  invencible: modelo.bolaInvencible,
                ),

                // 5. Raqueta
                VistaJugador(
                  posX:         modelo.jugador.x,
                  jugadorWidth: modelo.jugador.ancho,
                ),

                // 6. Ladrillos
                ...modelo.ladrillos.map((l) => VistaLadrillo(
                  ladrillo: l,
                  ancho:    anchoLadrillo,
                  alto:     altoLadrillo,
                )),

                // 7. Power-ups cayendo
                ...modelo.powerUpsActivos.map((pu) => PowerUpWidget(
                  posX: pu.x,
                  posY: pu.y,
                  tipo: pu.tipo,
                )),

              ],
            ),
          ),
        ),
      ),
    );
  }
}