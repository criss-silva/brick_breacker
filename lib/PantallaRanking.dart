//  pantalla_ranking.dart
//
//  Muestra la tabla de puntuaciones históricas ordenadas de mayor
//  a menor. Los datos se cargan de forma asíncrona a través de
//  RankingManager y se renderizan con un FutureBuilder para
//  gestionar los estados de carga, error y datos vacíos.
//
//  Accesible desde PantallaFinal y PantallaVictoria mediante el
//  botón "VER RANKING". El usuario puede volver atrás con la
//  flecha del AppBar.

import 'package:flutter/material.dart';
import 'package:moviles/game_state.dart';

class PantallaRanking extends StatefulWidget {
  const PantallaRanking({Key? key}) : super(key: key);

  @override
  State<PantallaRanking> createState() => _PantallaRankingState();
}

class _PantallaRankingState extends State<PantallaRanking> {
  // Guardamos el Future en una variable para que initState lo lance
  // una sola vez. Si lo creáramos directamente en build(), se
  // relanzaría en cada reconstrucción del widget.
  late Future<List<EntradaRanking>> _rankingFuture;

  @override
  void initState() {
    super.initState();
    // Lanzamos la consulta al inicio; el FutureBuilder la escuchará
    _rankingFuture = RankingManager().ConsultarRanking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RANKING'),
        backgroundColor: Colors.deepPurple,
        // La flecha de retroceso se añade automáticamente porque esta pantalla
        // fue abierta con Navigator.push (hay ruta anterior en la pila).
      ),
      backgroundColor: Colors.deepPurpleAccent[100],

      // FutureBuilder gestiona los tres estados del Future:
      //   waiting  → mostramos un spinner de carga
      //   done     → mostramos la lista (o un mensaje si está vacía)
      //   error    → (no manejado explícitamente; snapshot.data será null)
      body: FutureBuilder<List<EntradaRanking>>(
        future: _rankingFuture,
        builder: (context, snapshot) {

          // Mientras la consulta no ha terminado, mostramos un indicador de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si no hay datos (primera vez jugada o error de red), lista vacía
          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(
              child: Text(
                'Sin partidas jugadas',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          // Lista de entradas del ranking
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];


              final fecha =
                  '${entry.fecha.day}/${entry.fecha.month}/${entry.fecha.year} '
                  '${entry.fecha.hour.toString().padLeft(2, '0')}:'
                  '${entry.fecha.minute.toString().padLeft(2, '0')}';

              // Cada entrada es una Card con:
              //   Avatar circular con el número de posición (1, 2, 3…)
              //   Nombre del jugador en negrita
              //   Fecha de la partida como subtítulo
              //   Puntuación destacada a la derecha en amarillo
              return Card(
                color: Colors.deepPurple[100],
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      '${index + 1}', // posición en el ranking (base 1)
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    entry.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    fecha,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    '${entry.puntuacion}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}