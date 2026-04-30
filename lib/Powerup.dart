// ============================================================
//  powerup.dart
//  Widget visual para dibujar un power-up en pantalla.
//  Es un círculo de color que cae desde el último ladrillo roto.
//  El color y creacion depende del archivo de modelos
// ============================================================

import 'package:flutter/material.dart';
import 'modelos.dart';

class PowerUpWidget extends StatelessWidget { //no tiene estado mutable, no se va a redibujar, eso se hace mediante la rejilla como la raqueta o pelota
  final double posX;
  final double posY;

  // Tipo de power-up (decide el color del círculo)
  final TipoPowerUp tipo;

  const PowerUpWidget({
    Key? key,
    required this.posX,
    required this.posY,
    required this.tipo,
  }) : super(key: key);

  // _obtenerColor
  // Devuelve el color del círculo según el tipo de power-up.

  Color _obtenerColor() {
    switch (tipo) {
      case TipoPowerUp.racketaGrande:
        return Colors.pinkAccent;   // Rosa → raqueta más grande
      case TipoPowerUp.tiempoLento:
        return Colors.lightBlueAccent; // Azul → tiempo lento
      case TipoPowerUp.vidaExtra:
        return Colors.yellowAccent; // Amarillo → vida extra
    }
  }
//La construcción en sí de la vista
  @override
  Widget build(BuildContext context) {
    return Container(
      // Usamos Alignment para posicionar igual que la pelota y los ladrillos ya que cae del último impacto
      alignment: Alignment(posX, posY),
      child: Container( //crea el power up en sí
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: _obtenerColor(), //color para el widget
          shape: BoxShape.circle,
          // Pequeño borde blanco para que destaque sobre el fondo
          border: Border.all(color: Colors.white, width: 1.5),
        ),
      ),
    );
  }
}