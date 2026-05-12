class ProfesorModel {
  final double salarioInicial = 1500.0;
  final double incrementoAnual = 0.10;

  List<double> calcularSalariosPorAnios(int anios) {
    List<double> salarios = [];
    double salarioActual = salarioInicial;

    salarios.add(salarioActual);

    for (int i = 1; i < anios; i++) {
      salarioActual += salarioActual * incrementoAnual;
      salarios.add(salarioActual);
    }
    return salarios;
  }
}
