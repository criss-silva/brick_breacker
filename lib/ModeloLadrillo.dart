// ============================================================
//  modelo_ladrillo.dart
//  Representa el estado puro de un ladrillo: posición y si está roto.
//  No sabe nada de Flutter ni de widgets.
// ============================================================

class ModeloLadrillo {
  // Esquina superior-izquierda en unidades Alignment
  final double x;
  final double y;

  // true cuando la pelota lo ha golpeado
  bool roto;

  ModeloLadrillo({
    required this.x,
    required this.y,
    this.roto = false,
  });
}