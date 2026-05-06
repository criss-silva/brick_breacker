import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GameState {
  static String currentPlayerName = '';
  static int score = 0;

  static void reset() {
    currentPlayerName = '';
    score = 0;
  }
}

class RankingEntry {
  final String name;
  final DateTime date;
  final int score;

  RankingEntry({required this.name, required this.date, required this.score});

  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date.toIso8601String(),
    'score': score,
  };

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      score: json['score'] as int,
    );
  }
}

class RankingManager {
  static final RankingManager _instance = RankingManager._internal();
  factory RankingManager() => _instance;
  RankingManager._internal();

  static const String _rankingKey = 'ranking';
  List<RankingEntry> _cache = [];
  bool _loaded = false;

  Future<List<RankingEntry>> getRanking() async {
    await _loadRanking();
    return List.from(_cache);
  }

  Future<void> addResult({required String name, required int score}) async {
    await _loadRanking();
    
    final entrada = RankingEntry(name: name, date: DateTime.now(), score: score);
    _cache.insert(0, entrada);
    
    // Ordenar por puntuación (mayor a menor)
    _cache.sort((a, b) => b.score.compareTo(a.score));
    
    // Solo top 10
    if (_cache.length > 10) {
      _cache = _cache.take(10).toList();
    }
    
    await _saveRanking();
  }

  Future<void> _loadRanking() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_rankingKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _cache = jsonList.map((e) => RankingEntry.fromJson(e)).toList();
      } else {
        _cache = [];
      }
    } catch (e) {
      _cache = [];
    }
    _loaded = true;
  }

  Future<void> _saveRanking() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _cache.map((e) => e.toJson()).toList();
      await prefs.setString(_rankingKey, json.encode(jsonList));
    } catch (e) {}
  }
}