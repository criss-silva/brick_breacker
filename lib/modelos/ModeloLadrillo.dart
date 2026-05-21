
enum TipoLadrillo {
  normal1,       // 1 golpe
  normal2,       // 2 golpes
  normal3,       // 3 golpes
  pwRosa,        // 2 golpes suelta raquetaGrande
  pwAzul,        // 2 golpes suelta tiempoLento
  pwAmarillo,     // 2 golpes suelta vidaExtra
  pwMorado,       // 1 golpe  suelta bolaInvencible
  regenerador,   // 1 golpe se repara si no recibe daño en kRegenSeg s
  fantasma,     // 2 golpes aparece/desaparece, x2 puntos al romperlo
  special,      // 10 golpes solo se rompe con bolaInvencible
}

/// Segundos sin golpe para que el bloque regenerador se repare
const int kRegenSeg = 5;

class ModeloLadrillo {
  final double x;
  final double y;

  final TipoLadrillo tipo;

  int golpesRestantes;

  bool get roto => golpesRestantes <= 0;

  int? ultimoGolpeMs;

  bool visible;

  ModeloLadrillo({
    required this.x,
    required this.y,
    required this.tipo,
    required this.golpesRestantes,
    this.ultimoGolpeMs,
    this.visible = true,
  });


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

  void regenerar() {
    golpesRestantes = golpesIniciales(tipo);
    ultimoGolpeMs   = null;
  }
}