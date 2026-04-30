// ============================================================
//  vista_pelota.dart
//  Widget visual de la pelota. Solo sabe dibujarse.
//  Recibe posición (x, y) como valores de Alignment.
// ============================================================

import 'package:flutter/material.dart';

class VistaPelota extends StatelessWidget {
  final double posX;
  final double posY;

  const VistaPelota({Key? key, required this.posX, required this.posY})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(posX, posY),
      child: Container(
        height: 15,
        width: 15,
        decoration: const BoxDecoration(
          color: Colors.lightBlueAccent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}