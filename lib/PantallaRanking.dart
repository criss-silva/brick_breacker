import 'package:flutter/material.dart';
import 'package:moviles/game_state.dart';

class PantallaRanking extends StatefulWidget {
  const PantallaRanking({Key? key}) : super(key: key);

  @override
  State<PantallaRanking> createState() => _PantallaRankingState();
}

class _PantallaRankingState extends State<PantallaRanking> {
  late Future<List<RankingEntry>> _rankingFuture;

  @override
  void initState() {
    super.initState();
    _rankingFuture = RankingManager().getRanking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RANKING'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurpleAccent[100],
      body: FutureBuilder<List<RankingEntry>>(
        future: _rankingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(
              child: Text('Sin partidas jugadas',
                  style: TextStyle(color: Colors.white70, fontSize: 18)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final fecha =
                  '${entry.date.day}/${entry.date.month}/${entry.date.year} '
                  '${entry.date.hour.toString().padLeft(2, '0')}:'
                  '${entry.date.minute.toString().padLeft(2, '0')}';
              return Card(
                color: Colors.deepPurple[100],
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text('${index + 1}',
                        style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(entry.name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle:
                      Text(fecha, style: const TextStyle(color: Colors.white70)),
                  trailing: Text('${entry.score}',
                      style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}