import 'package:flutter/material.dart';
import '../providers/luz_provider.dart';

class LuzController {
  final LuzProvider provider;

  LuzController(this.provider);

  /// Verifica si el dispositivo tiene sensor de luz y comienza el monitoreo
  Future<void> iniciarMonitoreo(BuildContext context) async {
    final bool disponible = await provider.sensorDisponible();

    if (!disponible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Este dispositivo no tiene sensor de luz ambiental."),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await provider.iniciarMonitoreo();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Monitoreo de luz iniciado correctamente."),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Detiene el monitoreo y muestra mensaje al usuario
  void detenerMonitoreo(BuildContext context) {
    provider.detenerMonitoreo();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Monitoreo de luz detenido."),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Retorna el color de acuerdo al estado de luz
  Color obtenerColorEstado(String estado) {
    switch (estado) {
      case "Oscuro":
        return Colors.indigo;
      case "Normal":
        return Colors.green;
      case "Muy iluminado":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Retorna el porcentaje normalizado de lux para el ProgressIndicator (0.0 - 1.0)
  double obtenerProgreso(int lux) {
    const int maxLux = 1000;
    return (lux / maxLux).clamp(0.0, 1.0);
  }

  /// Retorna el ícono correspondiente al estado de luz
  IconData obtenerIconoEstado(String estado) {
    switch (estado) {
      case "Oscuro":
        return Icons.nights_stay;
      case "Normal":
        return Icons.wb_sunny_outlined;
      case "Muy iluminado":
        return Icons.wb_sunny;
      default:
        return Icons.light_mode;
    }
  }
}
