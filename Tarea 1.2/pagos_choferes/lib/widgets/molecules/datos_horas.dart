import 'package:flutter/material.dart';
import '../atoms/custom_label.dart';
import '../atoms/input_text.dart';

class DatosHoras extends StatelessWidget {
  final List<TextEditingController> horasControllers;

  const DatosHoras({
    super.key,
    required this.horasControllers,
  });

  final List<String> dias = const [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabel(
          text: 'Horas Trabajadas (Lunes a Sábado)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
        ),
        SizedBox(height: 12),
        ...List.generate(
          dias.length,
          (index) => InputText(
            label: dias[index],
            controller: horasControllers[index],
            hint: 'Horas',
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}
