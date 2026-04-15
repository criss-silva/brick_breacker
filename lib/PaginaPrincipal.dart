import 'package:flutter/material.dart';
import 'dart:async';
// Asegúrate de que este import sea correcto según tu proyecto
import 'package:moviles/pelota.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({Key? key}) : super(key: key);
  @override
  _PaginaPrincipalState createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  double ballX = 0;
  double ballY = 0;
  bool juegoEmpezado = false;

  void EmpezarJuego() {
    juegoEmpezado = true;
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      setState(() {
        ballY -= 0.01;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: EmpezarJuego,
      child: Scaffold(
        backgroundColor: Colors.deepPurpleAccent[100],
        body: Center(
          child: Stack(
            children: [
              // 1. Cubierta debe estar definida (la agrego abajo)
              Cubierta(juegoEmpezado: juegoEmpezado),

              // 2. Cambiamos ballX/Y por posX/posY (como definimos en la clase Pelota)
              Pelota(
                posX: ballX,
                posY: ballY,
              ), // 3. Quitamos el paréntesis extra que tenías aquí
            ],
          ),
        ),
      ),
    );
  }
}

// 4. Si el tutorial no te ha dado el código de 'Cubierta' aún,
// puedes usar este código temporal para que no te de error:
class Cubierta extends StatelessWidget {
  final bool juegoEmpezado;
  Cubierta({required this.juegoEmpezado});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(0, -0.2),
      child: Text(
        juegoEmpezado ? "" : "T A P  T O  P L A Y",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}