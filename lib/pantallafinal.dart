import 'package:flutter/material.dart';

class pantallaFinal extends StatelessWidget {
  final bool juegoAcabado;
  final function;
 pantallaFinal({required this.juegoAcabado, this.function});
  @override
  Widget build(BuildContext context) {
    return juegoAcabado
    ? Stack (children: [
      Container(
      alignment: Alignment(0, -0.3),
        child: Text('G A M E    O V E R', style: TextStyle(color : Colors.redAccent),),
    ),
      Container(
        alignment: Alignment(0, 0),
      child: GestureDetector(
      onTap: function ,
      child : ClipRRect(
        borderRadius:  BorderRadius.circular(12),
      child: Container (
        padding: EdgeInsets.all(10),
        color: Colors.deepPurple,
    child: Text (
    'PLAY AGAIN',
    style:  TextStyle(color:  Colors.white),

      ),
      ),
    ),
    ),
    )
    ]

    )





    : Container( );
  }
}