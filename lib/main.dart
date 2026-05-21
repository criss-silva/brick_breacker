

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moviles/modelos/GameModel.dart';
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