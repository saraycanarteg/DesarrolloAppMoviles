import 'package:flutter/material.dart';
import '../atoms/custom_label.dart';
import '../atoms/custom_checkbox.dart';
import '../atoms/input_text.dart';

class OpcionesRecargo extends StatefulWidget {
  final bool tieneRecargo;
  final double porcentajeRecargo;
  final Function(bool?) onRecargoChanged;
  final Function(String) onPorcentajeChanged;
  final TextEditingController porcentajeController;

  const OpcionesRecargo({
    super.key,
    required this.tieneRecargo,
    required this.porcentajeRecargo,
    required this.onRecargoChanged,
    required this.onPorcentajeChanged,
    required this.porcentajeController,
  });

  @override
  State<OpcionesRecargo> createState() => _OpcionesRecargoState();
}

class _OpcionesRecargoState extends State<OpcionesRecargo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabel(
          text: 'Opciones de Recargo',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
        ),
        SizedBox(height: 12),
        CustomCheckbox(
          label: 'Aplicar recargo',
          value: widget.tieneRecargo,
          onChanged: widget.onRecargoChanged,
        ),
        if (widget.tieneRecargo) ...[
          SizedBox(height: 8),
          InputText(
            label: 'Porcentaje de Recargo (%)',
            controller: widget.porcentajeController,
            hint: '0 - 100',
            keyboardType: TextInputType.number,
          ),
        ] else
          SizedBox(height: 16),
      ],
    );
  }
}
