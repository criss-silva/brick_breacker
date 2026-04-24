import 'package:flutter/material.dart';

class pantallaFinal extends StatelessWidget {
  final bool juegoAcabado;
  pantallaFinal({required this.juegoAcabado});

  @override
  Widget build(BuildContext context) {
    return juegoAcabado
    ? Container(
      alignment: Alignment(0, -0.3),
      child: Text('G A M E    O V E R', style: TextStyle(color : Colors.redAccent),),
    )
    : Container( );
  }
}