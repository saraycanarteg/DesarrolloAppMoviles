class PesoModel {
  final double promedioPeso1;
  final double promedioPeso2;
  final double diferencia;
  final String estado;

  PesoModel({
    required this.promedioPeso1,
    required this.promedioPeso2,
    required this.diferencia,
    required this.estado,
  });

  static PesoModel calcularPeso(
      List<double> pesajes1, List<double> pesajes2) {
    // Calcular promedio de los 10 pesajes de cada balanza
    final promedio1 = pesajes1.fold(0.0, (a, b) => a + b) / pesajes1.length;
    final promedio2 = pesajes2.fold(0.0, (a, b) => a + b) / pesajes2.length;

    // Calcular diferencia
    final diferencia = promedio2 - promedio1;

    // Determinar estado
    final estado = diferencia > 0 ? 'SUBIO' : 'BAJO';

    return PesoModel(
      promedioPeso1: promedio1,
      promedioPeso2: promedio2,
      diferencia: diferencia.abs(),
      estado: estado,
    );
  }
}

