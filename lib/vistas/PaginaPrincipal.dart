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
import 'package:provider/provider.dart';
import 'barrel_vistas.dart';
import 'package:moviles/modelos/barrel_modelos.dart';
import 'package:moviles/logica/barrel_logica.dart';


class PaginaPrincipal extends StatelessWidget {
  const PaginaPrincipal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final GameModel modelo = context.watch<GameModel>();

    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
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


                Cubierta(juegoEmpezado: modelo.juegoEmpezado),

                PantallaFinal(
                  juegoAcabado: modelo.juegoAcabado,
                  function:     () => context.read<GameModel>().reiniciar(),
                  vidas:        modelo.vidas,
                  puntuacion:   modelo.puntuacion,
                ),

                PantallaVictoria(
                  juegoGanado: modelo.juegoGanado,
                  onReiniciar: () => context.read<GameModel>().reiniciar(),
                  puntuacion:  modelo.puntuacion,
                ),

                VistaPelota(
                  posX:       modelo.pelota.x,
                  posY:       modelo.pelota.y,
                  invencible: modelo.bolaInvencible,
                ),

                VistaJugador(
                  posX:         modelo.jugador.x,
                  jugadorWidth: modelo.jugador.ancho,
                ),

                ...modelo.ladrillos.map((l) => VistaLadrillo(
                  ladrillo: l,
                  ancho:    anchoLadrillo,
                  alto:     altoLadrillo,
                )),

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