import '../model/profesor_model.dart';

class ProfesorController {
  final _model = ProfesorModel();

  Map<String, dynamic> obtenerCalculos() {

    List<double> salarios = _model.calcularSalariosPorAnios(6);

    List<String> salariosFormateados = salarios.map((s) => s.toStringAsFixed(2)).toList();

    return {
      "salarios": salariosFormateados,
      "salarioAnio6": salariosFormateados[5],
    };
  }
}
