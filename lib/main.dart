// ============================================================
//  main.dart
//
//  Aquí añadimos ChangeNotifierProvider, que es el "contenedor"
//  que hace que GameModel esté disponible para todos los widgets
//  del árbol que estén por debajo de él.
//
//  ¿Cómo funciona?
//  ChangeNotifierProvider crea UNA instancia de GameModel y la
//  inyecta en el árbol de widgets. Cualquier widget descendiente
//  puede acceder a ella con context.watch o context.read.
//
//  Cuando GameModel llama a notifyListeners(), Provider avisa
//  a todos los widgets suscritos (los que usan context.watch)
//  para que se reconstruyan con los nuevos valores.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';    // <-- importamos provider
import 'package:moviles/GameModel.dart';    // <-- el modelo que queremos proveer
import 'package:moviles/PantallaNombre.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider envuelve toda la app.
    // - create: crea la instancia de GameModel (solo una, como un singleton).
    // - dispose: cuando la app se cierra, Provider llama a GameModel.dispose()
    //   automáticamente, cancelando todos los timers.
    return ChangeNotifierProvider(
      create: (_) => GameModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const PantallaNombre(), // pantalla inicial: pedir nombre
      ),
    );
  }
}