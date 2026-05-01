// ============================================================
//  vista_jugador.dart
//  Widget visual de la raqueta. Solo sabe dibujarse.
// ============================================================

import 'package:flutter/material.dart';

class VistaJugador extends StatelessWidget {
  final double posX;
  final double jugadorWidth;

  const VistaJugador({
    Key? key,
    required this.posX,
    required this.jugadorWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(
        (2 * posX + jugadorWidth) / (2 - jugadorWidth),
        0.9,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 10,
          width: MediaQuery.of(context).size.width * jugadorWidth / 2,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}