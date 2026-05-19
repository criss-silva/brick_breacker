//  pantalla_ranking.dart

import 'package:flutter/material.dart';
import 'package:moviles/logica/barrel_logica.dart';

class PantallaRanking extends StatefulWidget {
  const PantallaRanking({Key? key}) : super(key: key);

  @override
  State<PantallaRanking> createState() => _PantallaRankingState();
}

class _PantallaRankingState extends State<PantallaRanking> {

  late Future<List<EntradaRanking>> _rankingFuture;

  @override
  void initState() {
    super.initState();

    _rankingFuture = RankingManager().ConsultarRanking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RANKING'),
        backgroundColor: Colors.deepPurple,

      ),
      backgroundColor: Colors.deepPurpleAccent[100],

      body: FutureBuilder<List<EntradaRanking>>(
        future: _rankingFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(
              child: Text(
                'Sin partidas jugadas',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }


          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];


              final fecha =
                  '${entry.fecha.day}/${entry.fecha.month}/${entry.fecha.year} '
                  '${entry.fecha.hour.toString().padLeft(2, '0')}:'
                  '${entry.fecha.minute.toString().padLeft(2, '0')}';

              return Card(
                color: Colors.deepPurple[100],
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      '${index + 1}', // posición en el ranking
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