//  vista_pelota.dart
//  Esto es el widget visual como tal, solo se dibuja y ya.

import 'package:flutter/material.dart';

class VistaPelota extends StatelessWidget {
  final double posX;
  final double posY;
  // true cuando el power-up bolaInvencible está activo
  final bool invencible;

  const VistaPelota({
    Key? key,
    required this.posX,
    required this.posY,
    this.invencible = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color color = invencible ? Colors.deepPurpleAccent : Colors.lightBlueAccent;
    return Container( // el dibujo de la pelota en sí
      alignment: Alignment(posX, posY),
      child: Container(
        height: 15,
        width: 15,
        decoration: BoxDecoration(
          color: color, //el color asignado arriba
          shape: BoxShape.circle, //es un circulo
          boxShadow: invencible
              ? [BoxShadow(color: Colors.deepPurple.withOpacity(0.7), blurRadius: 10, spreadRadius: 2)]
              : null,
        ),
      ),
    );
  }
}