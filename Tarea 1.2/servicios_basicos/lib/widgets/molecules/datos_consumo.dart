import 'package:flutter/material.dart';
import '../atoms/input_text.dart';
import '../atoms/custom_label.dart';

class DatosConsumo extends StatelessWidget {
  final TextEditingController consumoController;
  final String servicioSeleccionado;

  const DatosConsumo({
    super.key,
    required this.consumoController,
    required this.servicioSeleccionado,
  });

  String _obtenerUnidad() {
    switch (servicioSeleccionado) {
      case 'Agua Potable':
        return 'm³';
      case 'Energía Eléctrica':
        return 'kWh';
      case 'Internet y Telefonía':
        return '(Monto fijo)';
      case 'TV por Cable':
        return '(Monto fijo)';
      default:
        return 'unidades';
    }
  }

  String _obtenerPlaceholder() {
    switch (servicioSeleccionado) {
      case 'Agua Potable':
        return 'Consumo en m³';
      case 'Energía Eléctrica':
        return 'Consumo en kWh';
      case 'Internet y Telefonía':
        return 'Monto a pagar';
      case 'TV por Cable':
        return 'Monto a pagar';
      default:
        return 'Ingrese valor';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabel(
          text: 'Datos de Consumo',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
        ),
        SizedBox(height: 12),
        InputText(
          label: 'Consumo/Valor (${_obtenerUnidad()})',
          controller: consumoController,
          hint: _obtenerPlaceholder(),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
