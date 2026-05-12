//  modelo_ladrillo.dart
//  Estado puro de un ladrillo. No importa Flutter.

enum TipoLadrillo {
  normal1,       // 1 golpe
  normal2,       // 2 golpes
  normal3,       // 3 golpes
  pwRosa,        // 2 golpes → suelta raquetaGrande
  pwAzul,        // 2 golpes → suelta tiempoLento
  pwAmarillo,     // 2 golpes → suelta vidaExtra
  pwMorado,       // 1 golpe  → suelta bolaInvencible
  regenerador,   // 1 golpe  → se repara si no recibe daño en kRegenSeg s
  fantasma,     // 2 golpes → aparece/desaparece, x2 puntos al romperlo
  special,      // 10 golpes → solo se rompe con bolaInvencible
}

/// Segundos sin golpe para que el bloque regenerador se repare
const int kRegenSeg = 5;

class ModeloLadrillo {
  // Posición (Alignment, esquina superior-izquierda)
  final double x;
  final double y;

  // Tipo: determina color, golpes y comportamiento
  final TipoLadrillo tipo;

  // Golpes que le quedan para romperse
  int golpesRestantes;

  // true cuando golpesRestantes == 0
  bool get roto => golpesRestantes <= 0;

  // Timestamp (ms epoch) del último golpe recibido (para regenerador)
  int? ultimoGolpeMs;

  // Si el bloque fantasma está visible en este momento
  bool visible;

  ModeloLadrillo({ //constructor del ladrillo en sí
    required this.x,
    required this.y,
    required this.tipo,
    required this.golpesRestantes,
    this.ultimoGolpeMs,
    this.visible = true,
  });

  // Golpes iniciales según tipo
  static int golpesIniciales(TipoLadrillo t) {
    switch (t) {
      case TipoLadrillo.normal1:     return 1;
      case TipoLadrillo.normal2:     return 2;
      case TipoLadrillo.normal3:     return 3;
      case TipoLadrillo.pwRosa:      return 2;
      case TipoLadrillo.pwAzul:      return 2;
      case TipoLadrillo.pwAmarillo:  return 2;
      case TipoLadrillo.pwMorado:    return 1;
      case TipoLadrillo.regenerador: return 1;
      case TipoLadrillo.fantasma:    return 2;
      case TipoLadrillo.special:    return 10;
    }
  }

  // Puntos base al romper
  static int puntosPorTipo(TipoLadrillo t) {
    switch (t) {
      case TipoLadrillo.normal1:     return 10;
      case TipoLadrillo.normal2:     return 20;
      case TipoLadrillo.normal3:     return 30;
      case TipoLadrillo.pwRosa:      return 25;
      case TipoLadrillo.pwAzul:      return 25;
      case TipoLadrillo.pwAmarillo:  return 25;
      case TipoLadrillo.pwMorado:    return 40;
      case TipoLadrillo.regenerador: return 15;
      case TipoLadrillo.fantasma:    return 50;
      case TipoLadrillo.special:    return 100;
    }
  }

  //Reparar el ladrillo al estado inicial
  void regenerar() {
    golpesRestantes = golpesIniciales(tipo);
    ultimoGolpeMs   = null;
  }
}