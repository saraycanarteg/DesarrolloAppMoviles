import '../model/chofer_model.dart';

class ChoferController {
  final List<ChoferModel> choferes = [];

  String registrarChofer({
    required String nombre,
    required String horasLunes,
    required String horasMartes,
    required String horasMiercoles,
    required String horasJueves,
    required String horasViernes,
    required String horasSabado,
    required String sueldoPorHoraStr,
    required bool estaActivo,
    required bool recibeBono,
    required String tipoChofer,
  }) {
    // Validar nombre
    if (nombre.isEmpty) {
      return 'Debe ingresar el nombre del chofer';
    }

    // Validar que no haya duplicado
    if (choferes.any((c) => c.nombre.toLowerCase() == nombre.toLowerCase())) {
      return 'El chofer $nombre ya ha sido registrado';
    }

    // Validar sueldo
    if (sueldoPorHoraStr.isEmpty) {
      return 'Debe ingresar el sueldo por hora';
    }

    try {
      final sueldoPorHora = double.parse(sueldoPorHoraStr);

      if (sueldoPorHora <= 0) {
        return 'El sueldo debe ser mayor a 0';
      }

      // Validar y convertir horas
      final horas = [
        horasLunes,
        horasMartes,
        horasMiercoles,
        horasJueves,
        horasViernes,
        horasSabado
      ];

      List<double> horasPorDia = [];

      for (var i = 0; i < horas.length; i++) {
        if (horas[i].isEmpty) {
          return 'Debe ingresar horas para todos los días';
        }

        try {
          final hora = double.parse(horas[i]);

          if (hora < 0) {
            return 'Las horas no pueden ser negativas';
          }

          if (hora > 24) {
            return 'Las horas no pueden exceder 24 por día';
          }

          horasPorDia.add(hora);
        } catch (e) {
          return 'Todas las horas deben ser números válidos';
        }
      }

      // Crear chofer
      final chofer = ChoferModel(
        nombre: nombre,
        horasPorDia: horasPorDia,
        sueldoPorHora: sueldoPorHora,
        estaActivo: estaActivo,
        recibeBono: recibeBono,
        tipoChofer: tipoChofer,
      );

      choferes.add(chofer);
      return 'Chofer registrado exitosamente';
    } catch (e) {
      return 'Error: Ingrese valores numéricos válidos';
    }
  }

  String procesarNomina() {
    if (choferes.isEmpty) {
      return 'Debe registrar al menos un chofer';
    }

    final nomina = NominaModel(choferes: choferes);
    return _formatearReporte(nomina);
  }

  String _formatearReporte(NominaModel nomina) {
    final detalles = nomina.obtenerDetalles();
    final choferesData = detalles['choferes'] as List<Map<String, dynamic>>;
    final totalNomina = detalles['totalNomina'] as double;
    final totalChoferesActivos = detalles['totalChoferesActivos'] as int;
    final choferMasHorasLunes = detalles['choferMasHorasLunes'] as String;
    final horasLunesMax = detalles['horasLunesMax'] as double;

    String resultado = '''
====================================
     NÓMINA SEMANAL
     COMPAÑÍA DE TRANSPORTE
====================================

REPORTE DE CHOFERES:
====================================
''';

    int numero = 1;
    for (var chofer in choferesData) {
      resultado += '''
$numero. ${chofer['nombre']}
   Tipo: ${chofer['tipoChofer']}
   Activo: ${chofer['estaActivo'] ? 'Sí' : 'No'}
   ────────────────────────
   Horas/Día: ${chofer['horasPorDia'].join(', ')} horas
   Total Horas: ${(chofer['totalHoras'] as double).toStringAsFixed(2)}
   Sueldo/Hora: \$${(chofer['sueldoPorHora'] as double).toStringAsFixed(2)}
   Sueldo Base: \$${(chofer['sueldoBase'] as double).toStringAsFixed(2)}
''';

      if (chofer['recibeBono']) {
        resultado += '   Bono (10%): +\$${(chofer['bono'] as double).toStringAsFixed(2)}\n';
      }

      resultado += '   SUELDO TOTAL: \$${(chofer['sueldoTotal'] as double).toStringAsFixed(2)}\n\n';
      numero++;
    }

    resultado += '''
====================================
RESUMEN GENERAL:
====================================
Total Choferes Activos: $totalChoferesActivos

Chofer con más horas el LUNES:
$choferMasHorasLunes (${horasLunesMax.toStringAsFixed(2)} horas)

====================================
TOTAL A PAGAR (Nómina): \$${totalNomina.toStringAsFixed(2)}
====================================
Fecha: ${DateTime.now().toString().split('.')[0]}
''';

    return resultado;
  }

  void limpiar() {
    choferes.clear();
  }

  int get totalChoferesRegistrados => choferes.length;
}
