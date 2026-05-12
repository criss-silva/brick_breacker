import 'package:flutter/material.dart';

//clase que define los ladrillos, statelesswidget porque no tiene un estado mutable que maneje
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
        ? Container() //ssi está roto devuelve el container vacio y si no está roto se dibuja el ladrillo
        : Container(alignment: Alignment((2*ladrilloX+ladrilloAncho)/(2-ladrilloAncho), ladrilloY), //este container solo define donde se dibuja
          child: ClipRRect( //se dibuja
          borderRadius: BorderRadius.circular(5),
          child: Container(//este es el objeto que en si recibe el color anccho y alto
            height: MediaQuery.of(context).size.height*ladrilloAlto/2,
            width: MediaQuery.of(context).size.width*ladrilloAncho/2,
            color : Colors.deepOrange
        ),
      ),
    );
  }
}