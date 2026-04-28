import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moviles/jugador.dart';
import 'package:moviles/ladrillos.dart';
import 'package:moviles/pantallafinal.dart';
import 'package:moviles/PaginaDeCubierta.dart';
import 'dart:async';
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
  double incrementoBolaX= 0.015;
  double incrementoBolaY= 0.021;
  var direcionXBola= direcciones.IZQ;
  var direcionYBola= direcciones.AB;

  //posiciones jugador
  double jugadorX =-0.2;
  double jugadorWidth = 0.4;
  bool juegoEmpezado = false;
  bool juegoAcabado = false;
  //variables para los bloques
  static double primerladrilloX =-1+espaciopared;
  static double primerladrilloY = -0.9;
  static double ladrilloAncho = 0.4;
  static double ladrilloAlto = 0.05;
  static double espacioladrillo = 0.2;
  static int numeroladrillos=3;
  static double espaciopared= 0.5 * (2-numeroladrillos*ladrilloAncho - (numeroladrillos-1)*espacioladrillo);
  bool ladrilloRoto=false;


 List miladrillo= [
   [primerladrilloX +0*(ladrilloAncho+espacioladrillo),primerladrilloY,false],
  [primerladrilloX +1*(ladrilloAncho+espacioladrillo),primerladrilloY,false],
  [primerladrilloX +2*(ladrilloAncho+espacioladrillo),primerladrilloY,false]

 ];

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
      }else if(ballX <= -1){
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

//funcion para encontrar la distancia minima
  String findMin(double a, double b, double c, double d){
    List<double> lista =[ a,b,c,d];
    double currentmin =a;
    if ((currentmin-a).abs() <0.01) {
      return 'izq';
    }
    else if ((currentmin-b).abs() <0.01) {
      return 'der';
    } else
    if ((currentmin-c).abs() <0.01) {
      return 'arriba';
    }
    if ((currentmin-d).abs() <0.01){
      return 'abajo';
    }
    return '';
  }

void comprobarLadrillosRotos(){
    for (int i=0; i<miladrillo.length;i++) {
      if (ballX >= miladrillo[i][0] &&
          ballX <= miladrillo[i][0] + ladrilloAncho &&
          ballY <= miladrillo[i][1] + ladrilloAlto &&
          miladrillo[i][2] == false) {
        setState(() {
          miladrillo[i][2] = true;

          // como el ladrillo esta roto vamos a actualizar la direccion de la bola según en que lado del ladrillo toque
          //lo hacemos calculando la distancia de la bola a cada lado y la mas paqueña sera la elegida

          double ladoizqdistancia= (miladrillo[i][0] - ballX.abs());
          double ladoderdistancia= (miladrillo[i][0] +ladrilloAncho- ballX.abs());
          double ladoarribadistancia= (miladrillo[i][1] - ballX.abs());
          double ladoabajodistancia= (miladrillo[i][1] +ladrilloAncho -ballX.abs());
          String min = findMin(ladoizqdistancia,ladoderdistancia,ladoarribadistancia,ladoabajodistancia);
          switch (min){
            case 'izq':
              direcionXBola=direcciones.IZQ;
            break;
            case 'der':
              direcionXBola=direcciones.DER;
              break;
            case 'arriba':
              direcionYBola=direcciones.ARR;
              break;
            case 'abajo':
              direcionYBola=direcciones.AB;
              break;
          }




        });
      }
    }
}
//movimientos a los lados
void moveLeft(){
  setState(() {
    if(!(jugadorX <-1 ))
    {jugadorX -= 0.2;}
  });
}

void moveRight(){
  setState(() {
    if(!(jugadorX +0.2 >=1))
    {jugadorX += 0.2;}
  });
  }

  void reseteo(){
setState(() {
  jugadorX=-0.2;
  ballX=0;
  ballY=0;
  juegoAcabado=false;
  juegoEmpezado=false;
  miladrillo= [
  [primerladrilloX +0*(ladrilloAncho+espacioladrillo),primerladrilloY,false],
  [primerladrilloX +1*(ladrilloAncho+espacioladrillo),primerladrilloY,false],
  [primerladrilloX +2*(ladrilloAncho+espacioladrillo),primerladrilloY,false]
  ];
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
                pantallaFinal(juegoAcabado: juegoAcabado, function:reseteo ),
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
                  ladrilloX: miladrillo[0][0],
                  ladrilloY: miladrillo[0][1],
                  ladrilloAlto: ladrilloAlto,
                  ladrilloAncho: ladrilloAncho,
                  ladrilloRoto: miladrillo[0][2],
                ),
                Ladrillos(
                  ladrilloX: miladrillo[1][0],
                  ladrilloY: miladrillo[1][1],
                  ladrilloAlto: ladrilloAlto,
                  ladrilloAncho: ladrilloAncho,
                  ladrilloRoto: miladrillo[1][2],
                ),
                Ladrillos(
                  ladrilloX: miladrillo[2][0],
                  ladrilloY: miladrillo[2][1],
                  ladrilloAlto: ladrilloAlto,
                  ladrilloAncho: ladrilloAncho,
                  ladrilloRoto: miladrillo[2][2],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}



