import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moviles/jugador.dart';
import 'package:moviles/ladrillos.dart';
import 'package:moviles/pantallafinal.dart';
import 'dart:async';
// Asegúrate de que este import sea correcto según tu proyecto
import 'package:moviles/pelota.dart';


enum direcciones{ARR, AB, IZQ, DER}

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({Key? key}) : super(key: key);
  @override
  _PaginaPrincipalState createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  double ballX = 0;
  double ballY = 0;
  double incrementoBolaX= 0.1;
  double incrementoBolaY= 0.1;
  var direcionXBola= direcciones.AB;
  var direcionYBola= direcciones.IZQ;

  //posiciones jugador
  double jugadorX =-0.2;
  double jugadorWidth = 0.4;
  bool juegoEmpezado = false;
  bool juegoAcabado = false;
  //variables para los bloques
  double ladrilloX =0;
  double ladrilloY = -0.9;
  double ladrilloAncho = 0.4;
  double ladrilloAlto = 0.05;
  bool ladrilloRoto=false;
//empezar juego
  void EmpezarJuego() {
    juegoEmpezado = true;
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      //actualizamos direccion
      actualizarDirecion();

      //movemos la pelota
      moverPelota();

      //perder, jugador muere
      if(jugadorMuerto()){
        timer.cancel();
        juegoAcabado=true;
      }

      //comprobamos si golpeamos un ladrillo
      comprobarLadrillosRotos();

      });

  }

bool jugadorMuerto(){
    if(ballY>=1){
      return true ;
    }

    return false;
  }

void actualizarDirecion(){
    setState(() {
      //comprobaciones verticales
    if(ballY>=0.9 && ballX >= jugadorX && ballX <= jugadorX + jugadorWidth){ //la ultima parte la añadimos porque antes "rebotaba con el sueli aunque no hubiese raqueta"
      direcionYBola = direcciones.ARR;

    }else if( ballY<= -1 ){
      direcionYBola = direcciones.AB;
    }
    //comprobaciones horizontales
      if(ballX >=1){
        direcionXBola = direcciones.IZQ;
      }else if(ballX <= 0.1){
        direcionXBola = direcciones.DER;
      }
    });
}
void moverPelota(){
    setState(() {
      //movimiento vertical
      if(direcionYBola==direcciones.AB){
          ballY += incrementoBolaY;
      }else if(direcionYBola==direcciones.ARR){
        ballY -= incrementoBolaY;
      }
      //movimiento horizontal
      if(direcionXBola==direcciones.IZQ){
        ballX -= incrementoBolaX;
      }else if(direcionXBola==direcciones.DER){
        ballX += incrementoBolaX;
      }
    });
}

void comprobarLadrillosRotos(){
    if( ballX >= ladrilloX &&
        ballX <= ladrilloX + ladrilloAncho &&
        ballY <=ladrilloY + ladrilloAlto &&
        ladrilloRoto == false ){
      setState(() {
            ladrilloRoto=true;
            direcionYBola=direcciones.AB;
      });
    }
}
//movimientos a los lados
void moveLeft(){
  setState(() {
    if(!(jugadorX - 0.2 <=-1 ))
    {jugadorX -= 0.2;}
  });
}

void moveRight(){
  setState(() {
    if(!(jugadorX +0.2 >=1))
    {jugadorX += 0.2;}
  });
  }
  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event){
        if(event.isKeyPressed(LogicalKeyboardKey.arrowLeft)){
          moveLeft();
        }else if(event.isKeyPressed(LogicalKeyboardKey.arrowRight)){
          moveRight();
        }
      },
      child: GestureDetector(
        onTap: EmpezarJuego,
        child: Scaffold(
          backgroundColor: Colors.deepPurpleAccent[100],
          body: Center(
            child: Stack(
              children: [
                // 1. Cubierta del juego
                Cubierta(juegoEmpezado: juegoEmpezado),
                // 2.  final del juego
                pantallaFinal(juegoAcabado: juegoAcabado),
                // 3. Creamos la pelota en si
                Pelota(
                  posX: ballX,
                  posY: ballY,
                ), // 4 jugador
                Jugador(
                  posX: jugadorX,
                  jugadorWidth: jugadorWidth,
                ),//ladrillo
                Ladrillos(
                  ladrilloX: ladrilloX,
                  ladrilloY: ladrilloY,
                  ladrilloAlto: ladrilloAlto,
                  ladrilloAncho: ladrilloAncho,
                  ladrilloRoto: ladrilloRoto,
                )
              ],
            ),
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