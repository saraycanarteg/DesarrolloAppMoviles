class ChoferModel {
  final String nombre;
  final List<double> horasPorDia; // Lunes a Sábado (6 días)
  final double sueldoPorHora;
  final bool estaActivo;
  final bool recibeBono;
  final String tipoChofer; // Diurno, Nocturno, Mixto

  ChoferModel({
    required this.nombre,
    required this.horasPorDia,
    required this.sueldoPorHora,
    required this.estaActivo,
    required this.recibeBono,
    required this.tipoChofer,
  });

  double get totalHoras => horasPorDia.fold(0.0, (sum, horas) => sum + horas);

  double get sueldoBase => totalHoras * sueldoPorHora;

  double get bono => recibeBono ? sueldoBase * 0.10 : 0.0; // 10% de bono

  double get sueldoTotal => sueldoBase + bono;

  double get horasLunes => horasPorDia.isNotEmpty ? horasPorDia[0] : 0.0;

  Map<String, dynamic> obtenerDetalles() {
    return {
      'nombre': nombre,
      'horasPorDia': horasPorDia,
      'sueldoPorHora': sueldoPorHora,
      'estaActivo': estaActivo,
      'recibeBono': recibeBono,
      'tipoChofer': tipoChofer,
      'totalHoras': totalHoras,
      'sueldoBase': sueldoBase,
      'bono': bono,
      'sueldoTotal': sueldoTotal,
      'horasLunes': horasLunes,
    };
  }
}

class NominaModel {
  final List<ChoferModel> choferes;

  NominaModel({required this.choferes});

  List<ChoferModel> get choferesActivos =>
      choferes.where((c) => c.estaActivo).toList();

  double get totalNomina => choferesActivos.fold(
      0.0, (sum, chofer) => sum + chofer.sueldoTotal);

  ChoferModel? get choferMasHorasLunes {
    if (choferesActivos.isEmpty) return null;
    return choferesActivos.reduce((a, b) =>
        a.horasLunes > b.horasLunes ? a : b);
  }

  int get totalChoferesActivos => choferesActivos.length;

  Map<String, dynamic> obtenerDetalles() {
    return {
      'choferes': choferesActivos.map((c) => c.obtenerDetalles()).toList(),
      'totalNomina': totalNomina,
      'totalChoferesActivos': totalChoferesActivos,
      'choferMasHorasLunes': choferMasHorasLunes?.nombre ?? 'N/A',
      'horasLunesMax': choferMasHorasLunes?.horasLunes ?? 0.0,
    };
  }
}
