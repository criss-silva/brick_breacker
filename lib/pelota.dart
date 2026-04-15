import 'package:flutter/material.dart';

class Pelota extends StatelessWidget {
  final double posX;
  final double posY;

  // 1. Agregamos 'required' para el Null Safety
  // 2. Agregamos el ';' al final
  Pelota({required this.posX, required this.posY});

  @override
  Widget build(BuildContext context) {
    return Container(
      // El Alignment usa valores de -1.0 a 1.0
      alignment: Alignment(posX, posY),
      child: Container(
        height: 15,
        width: 15,
        // El color DEBE ir dentro de BoxDecoration, no fuera
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}