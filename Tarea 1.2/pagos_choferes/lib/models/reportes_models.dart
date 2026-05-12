import 'package:tarea2/models/chofer_models.dart';

class ReportesModels {
  final List<ChoferModels> choferes;

  ReportesModels({required this.choferes});

  // metodos
  // 1. regla de negocio 3
  double calcularTotalGeneral(){
    double totalGeneral = 0;
    for (var chofer in choferes){
      totalGeneral += chofer.calcularSueldoSemanal();
    }
    return totalGeneral;
  }

  // 2. regla de negocio 4
  ChoferModels obtenerMayorLunes(){
    ChoferModels mayor = choferes[0];

    for (var chofer in choferes) {
      if (chofer.horasPorDia[0] > mayor.horasPorDia[0]) {
        mayor = chofer;
      }
    }

    return mayor;
  }
}