//  Powerup.dart
//  Widget visual de un power-up cayendo.
//  El color y forma dependen del TipoPowerUp.

import 'package:flutter/material.dart';
import 'modelos.dart';

class PowerUpWidget extends StatelessWidget {
  final double posX;
  final double posY;
  final TipoPowerUp tipo;

  const PowerUpWidget({
    Key? key,
    required this.posX,
    required this.posY,
    required this.tipo,
  }) : super(key: key);

  Color _color() {
    switch (tipo) {
      case TipoPowerUp.racketaGrande:  return Colors.pinkAccent;
      case TipoPowerUp.tiempoLento:    return Colors.lightBlueAccent;
      case TipoPowerUp.vidaExtra:      return Colors.yellowAccent;
      case TipoPowerUp.bolaInvencible: return Colors.deepPurpleAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(posX, posY),
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color:  _color(),
          shape:  BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _color().withOpacity(0.6),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}