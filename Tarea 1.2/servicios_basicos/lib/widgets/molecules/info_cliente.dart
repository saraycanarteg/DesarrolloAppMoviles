import 'package:flutter/material.dart';
import '../atoms/input_text.dart';
import '../atoms/custom_label.dart';

class InfoCliente extends StatelessWidget {
  final TextEditingController nombreController;
  final TextEditingController cedulaController;
  final TextEditingController direccionController;

  const InfoCliente({
    super.key,
    required this.nombreController,
    required this.cedulaController,
    required this.direccionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabel(
          text: 'Información del Cliente',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
        ),
        SizedBox(height: 16),
        InputText(
          label: 'Nombre Completo',
          controller: nombreController,
          hint: 'Ingrese nombre completo',
        ),
        InputText(
          label: 'Cédula',
          controller: cedulaController,
          hint: 'Ingrese cédula',
          keyboardType: TextInputType.number,
        ),
        InputText(
          label: 'Dirección',
          controller: direccionController,
          hint: 'Ingrese dirección',
          maxLines: 2,
        ),
      ],
    );
  }
}
