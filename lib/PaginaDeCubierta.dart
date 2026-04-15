import 'package:flutter/material.dart';

class Cubierta extends StatelessWidget {
  final bool juegoEmpezado;

  Cubierta({required this.juegoEmpezado});

  @override
  Widget build(BuildContext context) {
    return juegoEmpezado ?
    Container()
        : Container(
      alignment: Alignment(0, -0.2),
      child: Text('Pulsa para jugar',
        style: TextStyle(color: Colors.deepPurple[400]),
      ), //text
    ); //container
  }

}