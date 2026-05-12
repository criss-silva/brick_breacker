
//  jugador.dart
//  Widget de la raqueta del jugador.
//  jugadorWidth puede cambiar dinámicamente desde PaginaPrincipal
//  cuando el power-up rosa esté activo, ya que hace crecer al jugador.


import 'package:flutter/material.dart';
//el jugador no se redibuja ni cambia su estado por lo tanto es statelessWidget
class Jugador extends StatelessWidget {
  // Posición horizontal de la raqueta (-1.0 a 1.0)
  final double posX;

  // Ancho de la raqueta en unidades de Alignment (0.0 a 2.0)
  // Normalmente es 0.4, pero el power-up rosa lo sube a 0.6
  final double jugadorWidth;

  const Jugador({ //constructor del jugador
    Key? key,
    required this.posX,
    required this.jugadorWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(//este es el dibujo del jugador
      // Calculamos el Alignment.x para que la raqueta empiece en posX
      // y tenga el ancho correcto centrado en ese punto
      alignment: Alignment( //posiciona la raqueta
        (2 * posX + jugadorWidth) / (2 - jugadorWidth),
        0.9,
      ),
      child: ClipRRect( //esto es el rectangulo redondeado
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 10,
          // El ancho en píxeles es proporcional al ancho de pantalla
          width: MediaQuery.of(context).size.width * jugadorWidth / 2,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}