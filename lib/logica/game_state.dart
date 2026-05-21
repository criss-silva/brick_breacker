import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


//clase que usamos para ver el ranking, que tiene el nombre dle jugaodr, su puntuacion y la fecha
class GameState {
  static String JugadorActual = '';
  static int puntuacion = 0;

  static void reset() {
    JugadorActual = '';
    puntuacion = 0;
  } //para resetear el jugador y la puntuacion
}

class EntradaRanking {
  final String nombre;
  final DateTime fecha;
  final int puntuacion;
  EntradaRanking({required this.nombre, required this.fecha, required this.puntuacion});

  Map<String, dynamic> toJson() => {
    'name': nombre,
    'date': fecha.toIso8601String(),
    'score': puntuacion,
  }; //funcion para guardar el objeto de la clase a un mapa json, pasandolo a string para que json pueda leerlo

  factory EntradaRanking.fromJson(Map<String, dynamic> json) { //de json a objeto
    return EntradaRanking(
      nombre: json['name'] as String,
      fecha: DateTime.parse(json['date'] as String),
      puntuacion: json['score'] as int,
    );
  }
}

class RankingManager { //clase que usa el patron singleton. Solo hay una instancia
  //consigue que los datos persistan con la libreria shared_preference
  //esto crea la unica instancia permitida y la guarda en un variable estática
  static final RankingManager _instance = RankingManager._internal();
 //con el constructor factory lo que hacemos es que si se intenta crear un objeto devuelve la misma instancia
  factory RankingManager() => _instance;
  RankingManager._internal();//estamos creando un constructor con nombre que al empezar en _ se vuelve privado

  //creamos un solo ranking -> static const crea una sola instancia en memoria
  static const String _rankingKey = 'ranking'; //al crearse con _ al inicio se vuelve privado
  List<EntradaRanking> _cache = []; //buffer del ranking, es una lista en memoria RAM, evitamos ir a la memoria en disco cada vez que queremos ver el ranking
  //con esta variable revisamos si ya hemos hecho la primera lectura
  bool _loaded = false;

  //usamos funcion future con async porque leer en disco puede tardar un poco
  Future<List<EntradaRanking>> ConsultarRanking() async {
    await _CargarRanking(); //espera hasta que carguen todos los datos
    return List.from(_cache); //devuelve una copia de la lista
    //no devuelve la lista entera, imagina que el usuario pudiese tener acceso a la lista como tal
  }

  Future<void> AnadirResultado({required String name, required int score}) async {
    await _CargarRanking(); //siempre verifica que tengamos el ranking cargado
    
    final entrada = EntradaRanking(nombre: name, fecha: DateTime.now(), puntuacion: score); //crea una nueva entrada
    _cache.insert(0, entrada); //esto lo que hace es añadir al inicio
    
    // Ordenar por puntuación (mayor a menor)
    _cache.sort((a, b) => b.puntuacion.compareTo(a.puntuacion));
    
    // Solo top 10
    if (_cache.length > 10) {
      _cache = _cache.take(10).toList();
    }
    
    await _GuardarRanking(); //esperas para guardar el ranking
  }

  Future<void> _CargarRanking() async {
    if (_loaded) return; //si ya lo hemos cargado, no seguimos leyendo en disco
    try {
      final prefs = await SharedPreferences.getInstance(); //esto abre conexcion con la pequeña base de datos del telefono en sí, puede tardar tiempo
      final jsonString = prefs.getString(_rankingKey);//busca el texto que tenemos guardado como ranking
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);//lo convertimos si hay algo en el json
        _cache = jsonList.map((e) => EntradaRanking.fromJson(e)).toList(); //ahora cada mapa pasa a ser un objeto de entrada ranking, y lo agruparemos en la lista _cache
      } else {
        _cache = []; //si no hay ranking se crea
      }
    } catch (e) {
      _cache = [];
    }
    _loaded = true; //ya hemos leido en disco
  }

  Future<void> _GuardarRanking() async {
    try {
      final prefs = await SharedPreferences.getInstance(); //conecta con los datos en el movil
      final jsonList = _cache.map((e) => e.toJson()).toList(); //pasamos a unn formato que json entienda, de objetos complejos a mapas
      await prefs.setString(_rankingKey, json.encode(jsonList)); //pasa los maoas a un solo string
    } catch (e) {
      print("Ocurrió un error al guardar: $e");
      //lanzamos el texto del error
      throw Exception("No hay espacio suficiente");
    } //esto se usa para "silenciar el error" imagina que en el teléfono del usuario hay un error y está el disco lleno, preferimos que el juego siga corriendo
  }
}