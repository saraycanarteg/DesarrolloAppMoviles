class ChoferModels {
  final String nombre;
  final List<double> horasPorDia;
  final double sueldoPorHora;
  final bool activo;
  final bool recibeBono;
  final String tipoJornada;

  ChoferModels({ required this.nombre, required this.horasPorDia,
    required this.sueldoPorHora, required this.activo, required this.recibeBono,
    required this.tipoJornada}) : assert(horasPorDia.length == 6);

  //metodos
  //1. regla de negocio 1:
  double calcularTotalHoras(){
    double totalHoras = 0;
    for (double horas in horasPorDia){
      totalHoras += horas;
    }
    return totalHoras;
  }

  //2. regla 2:
  double calcularSueldoSemanal(){
    double sueldoSemanal = calcularTotalHoras() * sueldoPorHora;
    return sueldoSemanal;
  }

}

