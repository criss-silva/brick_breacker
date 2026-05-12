//  PaginaPrincipal.dart
//  Solo gestiona estado y coordina módulos.
//
//  Toda la lógica "pesada" (inicializar, perder vida, reiniciar,
//  power-ups, nueva oleada…) vive en game_logic.dart.
//  Este archivo se limita a:
//    · Declarar las variables de estado
//    · Arrancar/parar timers
//    · Llamar a las funciones de game_logic y aplicar resultados
//    · Construir el árbol de widgets
//
//  Un solo import del barrel moviles_imports.dart trae todo lo
//  necesario sin repetir líneas en cada archivo del proyecto.

import 'package:moviles/moviles_imports.dart';

// esta es la rejilla que se va a dedicar a redibujar todos los widgets
class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({Key? key}) : super(key: key);

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {

  // Modelos de estado
  late ModeloPelota         _pelota;
  late ModeloJugador        _jugador;
  late List<ModeloLadrillo> _ladrillos;

  // Estado general de la partida
  bool _juegoEmpezado = false;
  bool _juegoAcabado  = false;
  bool _juegoGanado   = false; // ya no se usa para Victoria; se conserva por compatibilidad con PantallaVictoria
  int  _vidas         = kVidasIniciales; // constante definida en game_logic.dart

  // Puntuación
  int  _puntuacion      = 0;
  bool _multiplicadorx2 = false; // se activa al romper el bloque fantasma

  // Power-ups visibles en pantalla
  final List<ModeloPowerUp> _powerUpsActivos = [];

  // Timers
  Timer? _timerPrincipal;
  Timer? _timerEfectoRaqueta;
  Timer? _timerEfectoLento;
  Timer? _timerBolaInvencible;
  Timer? _timerRegeneradores; // tick cada 1 s para los bloques regeneradores

  //  Flags de efectos activos
  bool _bolaInvencible = false;

  // INICIALIZACIÓN
  @override
  void initState() {
    super.initState();
    _aplicarInicializacion();
  }

  // Llama a game_logic y asigna los modelos devueltos al estado local
  void _aplicarInicializacion() {
    final estado = inicializarEstado();
    _pelota    = estado.pelota;
    _jugador   = estado.jugador;
    _ladrillos = estado.ladrillos;
  }

  // Se define como async porque en el futuro podría mostrar un diálogo
  // de nombre antes de empezar. Por ahora, si el nombre ya está en
  // GameState arranca directamente.
  Future<void> _pedirNombreYEmpezar() async {
    if (_juegoEmpezado) return; // evita doble arranque por doble tap
    if (GameState.JugadorActual.isNotEmpty) {
      _empezarJuego();
      return;
    }
    _empezarJuego(); // arranca aunque el nombre esté vacío (fallback)
  }

  // Pone en marcha los dos timers. Cada tick del principal ejecuta los 8 pasos
  // del game loop en orden.
  void _empezarJuego() {
    if (_juegoEmpezado) return;
    setState(() => _juegoEmpezado = true);

    // Timer de regeneradores: cada segundo comprueba si algún bloque
    // regenerador lleva suficiente tiempo sin recibir golpes
    _timerRegeneradores = Timer.periodic(const Duration(seconds: 1), (_) {
      tickRegeneradores(_ladrillos);
    });

    // Timer principal: 10 ms ≈ 100 fps de lógica de juego
    _timerPrincipal = Timer.periodic(const Duration(milliseconds: 10), (timer) {

      // 1. Actualizar dirección de la pelota (rebotes en bordes y raqueta)
      actualizarDireccion(_pelota, _jugador);

      // 2. Mover la pelota (más lenta si el efecto de tiempo lento está activo)
      final bool lento = _timerEfectoLento != null;
      setState(() => moverPelota(_pelota, tiempoLento: lento));

      // 3. Bajar los power-ups que están cayendo por pantalla
      setState(() => moverPowerUps(_powerUpsActivos));

      // 4. Actualizar la visibilidad del bloque fantasma según el tiempo
      final int ahora = DateTime.now().millisecondsSinceEpoch;
      setState(() => tickFantasma(_ladrillos, ahora));

      // 5. Comprobar colisiones entre pelota y ladrillos
      final List<ResultadoColision> colisiones = comprobarColisionLadrillos(
        _pelota,
        _ladrillos,
        bolaInvencible: _bolaInvencible,
      );

      // comprobamos todas las colisiones del frame
      if (colisiones.isNotEmpty) {
        setState(() {
          for (final col in colisiones) {

            // Sumar puntos (con multiplicador x2 si el fantasma ya fue roto)
            if (col.puntosGanados > 0) {
              int pts = col.puntosGanados;
              if (_multiplicadorx2) pts *= 2;
              if (col.multiplicarPuntuacion) {
                // El bloque fantasma activa el x2 Y multiplica sus propios puntos
                pts *= 2;
                _multiplicadorx2 = true;
              }
              _puntuacion += pts;
            }

            // Spawnear el power-up fijo asignado al ladrillo roto
            if (col.tipoPowerUpSoltado != null) {
              spawnPowerUpFijo(
                _powerUpsActivos,
                col.tipoPowerUpSoltado!,
                col.ladrilloX,
                col.ladrilloY,
                anchoLadrillo,
              );
            } else if (col.puntosGanados > 0) {
              // Ladrillo normal roto: posibilidad de soltar un power-up aleatorio
              intentarGenerarPowerUpAleatorio(
                _powerUpsActivos,
                col.ladrilloX,
                col.ladrilloY,
                anchoLadrillo,
              );
            }
          }
        });
      }

      // 6. Comprobar si se han roto todos los ladrillos → NUEVA OLEADA
      // En lugar de mostrar pantalla de victoria, regeneramos ladrillos
      // y seguimos jugando, sumando un bonus por la oleada completada.
      if (todosTroceados(_ladrillos)) {
        // Paramos el bucle actual para reiniciarlo limpio tras la oleada
        timer.cancel();
        _timerRegeneradores?.cancel();

        final ResultadoOleada resultado = nuevaOleada(
          vidas:           _vidas,
          pelota:          _pelota,
          jugador:         _jugador,
          powerUpsActivos: _powerUpsActivos,
        );

        setState(() {
          _ladrillos    = resultado.nuevosLadrillos; // cuadrícula nueva
          _puntuacion  += resultado.bonusOleada;     // bonus por oleada
          _juegoEmpezado = false; // el próximo tap/frame vuelve a arrancar
          _multiplicadorx2 = false; // el x2 del fantasma no persiste entre oleadas
        });

        // Arrancamos el nuevo bucle automáticamente sin esperar tap
        _empezarJuego();
        return;
      }

      // 7. Recoger power-ups que hayan tocado la raqueta
      final List<ModeloPowerUp> recogidos =
      comprobarRecogida(_powerUpsActivos, _jugador);
      if (recogidos.isNotEmpty) {
        setState(() {
          for (final pu in recogidos) {
            _aplicarEfectoPowerUp(pu.tipo);
          }
        });
      }

      // 8. Muerte: la pelota salió por el fondo de la pantalla
      if (pelotaFueraDePantalla(_pelota)) {
        timer.cancel();
        _timerRegeneradores?.cancel();
        _procesarPerdidaDeVida();
      }
    });
  }

  // EFECTOS DE POWER-UPS
  // Delega en game_logic y aplica el resultado al estado local.
  // Vive aquí porque necesita setState y acceso a los timers del widget.
  void _aplicarEfectoPowerUp(TipoPowerUp tipo) {
    final resultado = aplicarEfectoPowerUp(
      tipo:             tipo,
      jugador:          _jugador,
      vidas:            _vidas,
      vidasMax:         kVidasMaximas,
      bolaInvencible:   _bolaInvencible,
      onEstadoCambiado: setState,
      timerRaqueta:     _timerEfectoRaqueta,
      timerLento:       _timerEfectoLento,
      timerInvencible:  _timerBolaInvencible,
    );
    // Aplicamos todos los valores devueltos al estado del widget
    _timerEfectoRaqueta  = resultado.timerRaqueta;
    _timerEfectoLento    = resultado.timerLento;
    _timerBolaInvencible = resultado.timerInvencible;
    _bolaInvencible      = resultado.bolaInvencible;
    _vidas               = resultado.vidas;
  }

  // necesitamos poder parar todos los efectos temporales, por ejemplo perdemos una vida
  void _cancelarEfectos() {
    final resultado = cancelarEfectosTemporales(
      jugador:        _jugador,
      timerRaqueta:   _timerEfectoRaqueta,
      timerLento:     _timerEfectoLento,
      timerInvencible: _timerBolaInvencible,
    );
    _timerEfectoRaqueta  = resultado.timerRaqueta;
    _timerEfectoLento    = resultado.timerLento;
    _timerBolaInvencible = resultado.timerInvencible;
    _bolaInvencible      = resultado.bolaInvencible;
  }

  //  PERDER VIDA
  // vamos a tener 3 de inicio y 5 como máximo
  // Cancela efectos, delega en game_logic y aplica el resultado.
  void _procesarPerdidaDeVida() {
    _cancelarEfectos();
    final resultado = perderVida(
      vidas:           _vidas,
      pelota:          _pelota,
      jugador:         _jugador,
      powerUpsActivos: _powerUpsActivos,
    );
    setState(() {
      _vidas         = resultado.vidas;
      _juegoAcabado  = resultado.juegoAcabado;
      _juegoEmpezado = resultado.juegoEmpezado;
    });
  }

  // REINICIO COMPLETO
  // Para todos los timers, cancela efectos y restaura el estado inicial.
  void _reiniciar() {
    _timerPrincipal?.cancel();
    _timerRegeneradores?.cancel();
    _cancelarEfectos();

    final r = reiniciarEstado();
    setState(() {
      _pelota          = r.pelota;
      _jugador         = r.jugador;
      _ladrillos       = r.ladrillos;
      _vidas           = r.vidas;
      _puntuacion      = r.puntuacion;
      _juegoEmpezado   = r.juegoEmpezado;
      _juegoAcabado    = r.juegoAcabado;
      _juegoGanado     = r.juegoGanado;
      _multiplicadorx2 = r.multiplicadorx2;
      _powerUpsActivos.clear();
    });
  }

  // Limpieza obligatoria al desmontar el widget para evitar leaks.
  @override
  void dispose() {
    _timerPrincipal?.cancel();
    _timerRegeneradores?.cancel();
    _cancelarEfectos();
    super.dispose();
  }

  // Construye el árbol de widgets. El Stack apila todas las capas del
  // juego en orden: fondo, HUD, pelota, raqueta, ladrillos y power-ups.
  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      // Captura teclas de flechas para mover la raqueta en escritorio/web
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          setState(() => moverIzquierda(_jugador));
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          setState(() => moverDerecha(_jugador));
        }
      },
      child: GestureDetector(
        onTap: _pedirNombreYEmpezar, // tap en cualquier parte arranca el juego
        onHorizontalDragUpdate: (details) {
          // Arrastra el dedo/ratón horizontalmente para mover la raqueta
          setState(() => moverConArrastre(
            _jugador,
            details.delta.dx,
            MediaQuery.of(context).size.width,
          ));
        },
        child: Scaffold(
          backgroundColor: Colors.deepPurpleAccent[100],
          body: Center(
            child: Stack(
              children: [

                // 1. Pantalla de inicio (se oculta cuando el juego empieza)
                Cubierta(juegoEmpezado: _juegoEmpezado),

                // 2. HUD de vidas y puntos (en juego) / overlay Game Over
                PantallaFinal(
                  juegoAcabado: _juegoAcabado,
                  function:     _reiniciar,
                  vidas:        _vidas,
                  puntuacion:   _puntuacion,
                ),

                // 3. Overlay de victoria (ya no se activa con oleadas,
                //    se conserva por si se quiere usar en el futuro)
                PantallaVictoria(
                  juegoGanado: _juegoGanado,
                  onReiniciar: _reiniciar,
                  puntuacion:  _puntuacion,
                ),

                // 4. Pelota (cambia de color cuando está invencible)
                VistaPelota(
                  posX:       _pelota.x,
                  posY:       _pelota.y,
                  invencible: _bolaInvencible,
                ),

                // 5. Raqueta del jugador
                VistaJugador(
                  posX:         _jugador.x,
                  jugadorWidth: _jugador.ancho,
                ),

                // 6. Todos los ladrillos de la oleada actual
                ..._ladrillos.map((l) => VistaLadrillo(
                  ladrillo: l,
                  ancho:    anchoLadrillo,
                  alto:     altoLadrillo,
                )),

                // 7. Power-ups que están cayendo hacia la raqueta
                ..._powerUpsActivos.map((pu) => PowerUpWidget(
                  posX: pu.x,
                  posY: pu.y,
                  tipo: pu.tipo,
                )),

              ],
            ),
          ),
        ),
      ),
    );
  }
}