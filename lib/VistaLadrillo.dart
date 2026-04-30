// ============================================================
//  vista_ladrillo.dart
//  Widget visual de un ladrillo. Solo sabe dibujarse.
//  Si ladrilloRoto == true devuelve un contenedor vacío (invisible).
// ============================================================

import 'package:flutter/material.dart';

class VistaLadrillo extends StatelessWidget {
  final double ladrilloX;
  final double ladrilloY;
  final double ladrilloAlto;
  final double ladrilloAncho;
  final bool   ladrilloRoto;

  const VistaLadrillo({
    Key? key,
    required this.ladrilloX,
    required this.ladrilloY,
    required this.ladrilloAlto,
    required this.ladrilloAncho,
    required this.ladrilloRoto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (ladrilloRoto) return Container();

    return Container(
      alignment: Alignment(
        (2 * ladrilloX + ladrilloAncho) / (2 - ladrilloAncho),
        ladrilloY,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: MediaQuery.of(context).size.height * ladrilloAlto / 2,
          width:  MediaQuery.of(context).size.width  * ladrilloAncho / 2,
          color: Colors.deepOrange,
        ),
      ),
    );
  }
}