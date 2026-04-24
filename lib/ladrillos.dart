import 'package:flutter/material.dart';

class Ladrillos extends StatelessWidget{
  final ladrilloX;
  final ladrilloY;
  final ladrilloAlto;
  final ladrilloAncho;
  final bool ladrilloRoto;

  Ladrillos({this.ladrilloAncho, this.ladrilloAlto, this.ladrilloX, this.ladrilloY,required this.ladrilloRoto});

  @override
  Widget build(BuildContext context) {
    return ladrilloRoto
        ? Container()
        : Container(alignment: Alignment(ladrilloX, ladrilloY),
          child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            height: MediaQuery.of(context).size.height*ladrilloAlto/2,
            width: MediaQuery.of(context).size.width*ladrilloAncho/2,
            color : Colors.deepOrange
        ),
      ),
    );
  }
}