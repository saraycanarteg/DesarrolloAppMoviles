import '../models/chofer_models.dart';

class ChoferController {

  // VALIDACIONES
  String validar(
      String nombre,
      List<String> horasTexto,
      String sueldoTexto,
      ) {

    // nombre
    if (nombre.trim().isEmpty) {
      return 'Ingrese el nombre';
    }

    // sueldo
    if (sueldoTexto.isEmpty) {
      return 'Ingrese sueldo por hora';
    }

    final sueldo = double.tryParse(sueldoTexto);

    if (sueldo == null) {
      return 'El sueldo debe ser numérico';
    }

    if (sueldo <= 0) {
      return 'El sueldo debe ser mayor a 0';
    }

    // horas
    for (int i = 0; i < horasTexto.length; i++) {

      if (horasTexto[i].isEmpty) {
        return 'Ingrese horas del día ${i + 1}';
      }

      final hora = double.tryParse(horasTexto[i]);

      if (hora == null) {
        return 'Horas inválidas';
      }

      if (hora < 0 || hora > 24) {
        return 'Horas inválidas en día ${i + 1}';
      }
    }

    return 'OK';
  }

  // CREAR OBJETO
  ChoferModels crearChofer(
      String nombre,
      List<String> horasTexto,
      String sueldoTexto,
      bool activo,
      bool bono,
      String jornada,
      ) {

    List<double> horas = horasTexto
        .map((e) => double.parse(e))
        .toList();

    return ChoferModels(
      nombre: nombre,
      horasPorDia: horas,
      sueldoPorHora: double.parse(sueldoTexto),
      activo: activo,
      recibeBono: bono,
      tipoJornada: jornada,
    );
  }
}