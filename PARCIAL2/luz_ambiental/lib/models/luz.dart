class Luz {
  final int lux;
  final String estado;
  final String recomendacion;
  final DateTime timestamp;

  Luz({
    required this.lux,
    required this.estado,
    required this.recomendacion,
    required this.timestamp,
  });

  /// Clasifica el nivel de luz y retorna el estado correspondiente
  static String clasificarEstado(int lux) {
    if (lux < 50) {
      return "Oscuro";
    } else if (lux < 500) {
      return "Normal";
    } else {
      return "Muy iluminado";
    }
  }

  /// Retorna una recomendación según el nivel de luz
  static String obtenerRecomendacion(int lux) {
    if (lux < 50) {
      return "⚠️ Poca luz. Enciende una lámpara para proteger tu vista.";
    } else if (lux < 500) {
      return "✓ Ambiente adecuado para trabajar o leer.";
    } else {
      return "☀️ Mucha luz. Considera usar cortinas o gafas de sol.";
    }
  }

  /// Factory para crear una instancia a partir de un valor de lux
  factory Luz.fromLux(int lux) {
    return Luz(
      lux: lux,
      estado: clasificarEstado(lux),
      recomendacion: obtenerRecomendacion(lux),
      timestamp: DateTime.now(),
    );
  }
}
