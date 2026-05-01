// ============================================================
//  vista_pelota.dart
//  Widget visual de la pelota. Solo sabe dibujarse.
// ============================================================

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
    return Container(
      alignment: Alignment(posX, posY),
      child: Container(
        height: 15,
        width: 15,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: invencible
              ? [BoxShadow(color: Colors.deepPurple.withOpacity(0.7), blurRadius: 10, spreadRadius: 2)]
              : null,
        ),
      ),
    );
  }
}