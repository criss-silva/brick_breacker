//  vista_pelota.dart
//  Esto es el widget visual como tal, solo se dibuja y ya.

import 'package:flutter/material.dart';

class VistaPelota extends StatelessWidget {
  final double posX;
  final double posY;
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