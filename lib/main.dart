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
import 'package:moviles/modelos/GameModel.dart';    // <-- el modelo que queremos proveer
import 'package:moviles/vistas/PantallaNombre.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => GameModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const PantallaNombre(),
      ),
    );
  }
}