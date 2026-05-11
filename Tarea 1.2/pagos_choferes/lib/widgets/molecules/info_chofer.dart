import 'package:flutter/material.dart';
import '../atoms/input_text.dart';
import '../atoms/custom_label.dart';

class InfoChofer extends StatelessWidget {
  final TextEditingController nombreController;
  final TextEditingController sueldoPorHoraController;

  const InfoChofer({
    super.key,
    required this.nombreController,
    required this.sueldoPorHoraController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabel(
          text: 'Información del Chofer',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
        ),
        SizedBox(height: 16),
        InputText(
          label: 'Nombre del Chofer',
          controller: nombreController,
          hint: 'Ingrese nombre completo',
        ),
        InputText(
          label: 'Sueldo por Hora',
          controller: sueldoPorHoraController,
          hint: 'Ingrese sueldo por hora (\$)',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
