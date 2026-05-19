//  vista_ladrillo.dart
//  Widget visual de un ladrillo. Solo sabe dibujarse.
//
//  CODIFICCACION COLORES:
//  Cada TipoLadrillo tiene hasta 3 tonos (oscureciendo con cada golpe).
//  El fantasma tiene un borde punteado y es semi-transparente.

import 'package:flutter/material.dart';
import 'package:moviles/modelos/barrel_modelos.dart';


class VistaLadrillo extends StatelessWidget {
  final ModeloLadrillo ladrillo;
  final double ancho;
  final double alto;

  const VistaLadrillo({
    Key? key,
    required this.ladrillo,
    required this.ancho,
    required this.alto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //los ladrillos que estan rotos o los que son del tipo invisible no se dibujan
    if (ladrillo.roto) return const SizedBox.shrink();
    if (ladrillo.tipo == TipoLadrillo.fantasma && !ladrillo.visible) {
      return const SizedBox.shrink();
    }

    final Color color = _colorActual();
    final bool esFantasma = ladrillo.tipo == TipoLadrillo.fantasma;

    return Container(
      alignment: Alignment(
        (2 * ladrillo.x + ancho) / (2 - ancho),
        ladrillo.y,
      ),
      child: Container(
        width:  MediaQuery.of(context).size.width  * ancho / 2,
        height: MediaQuery.of(context).size.height * alto  / 2,
        decoration: BoxDecoration(
          color:        esFantasma ? color.withOpacity(0.55) : color,
          borderRadius: BorderRadius.circular(5),
          border: esFantasma
              ? Border.all(color: Colors.white70, width: 1.5)
              : null,

          gradient: esFantasma
              ? null
              : LinearGradient(
            begin: Alignment.topCenter,
            end:   Alignment.bottomCenter,
            colors: [
              color.withOpacity(0.85),
              color,
            ],
          ),
        ),
        child: _indicadorVida(),
      ),
    );
  }

  Color _colorActual() {
    final int g = ladrillo.golpesRestantes;
    final int gMax = ModeloLadrillo.golpesIniciales(ladrillo.tipo);

    switch (ladrillo.tipo) {

      case TipoLadrillo.normal1:
        return const Color(0xFFB0BEC5);

      case TipoLadrillo.normal2:
        return g == 2
            ? const Color(0xFF78909C)
            : const Color(0xFF455A64);
      case TipoLadrillo.normal3:
        if (g == 3) return const Color(0xFF546E7A);
        if (g == 2) return const Color(0xFF37474F);
        return       const Color(0xFF1C313A);

      case TipoLadrillo.pwRosa:
        return g == 2
            ? const Color(0xFFF48FB1)
            : const Color(0xFFAD1457);

      case TipoLadrillo.pwAzul:
        return g == 2
            ? const Color(0xFF81D4FA)
            : const Color(0xFF01579B);
      case TipoLadrillo.pwAmarillo:
        return g == 2
            ? const Color(0xFFFFF176)
            : const Color(0xFFF57F17);

      case TipoLadrillo.pwMorado:
        return const Color(0xFFCE93D8);


      case TipoLadrillo.regenerador:
        return (g == gMax)
            ? const Color(0xFFA5D6A7)
            : const Color(0xFF2E7D32);


      case TipoLadrillo.fantasma:
        return g == 2
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF9E9E9E);

      case TipoLadrillo.special:
        return const Color(0xFFFFD700);
    }
  }


  Widget _indicadorVida() {
    final int g    = ladrillo.golpesRestantes;
    final int gMax = ModeloLadrillo.golpesIniciales(ladrillo.tipo);
    if (gMax <= 1) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(gMax, (i) {
            final bool activo = i < g;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activo
                    ? Colors.white.withOpacity(0.9)
                    : Colors.white.withOpacity(0.25),
              ),
            );
          }),
        ),
      ),
    );
  }
}