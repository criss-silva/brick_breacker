import 'package:flutter/material.dart';

class Jugador extends StatelessWidget{
  final posX;
  final jugadorWidth;
  Jugador({this.posX, this.jugadorWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment((2*posX+jugadorWidth)/(2-jugadorWidth), 0.9),
      child:  ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(10),
        child: Container(
          height: 10,
          width: MediaQuery.of(context).size.width * jugadorWidth/2,
          color: Colors.deepPurple),
      ),
    );
  }
}