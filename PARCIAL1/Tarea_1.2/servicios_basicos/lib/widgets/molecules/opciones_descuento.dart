import 'package:flutter/material.dart';
import '../atoms/custom_label.dart';
import '../atoms/custom_checkbox.dart';
import '../atoms/input_text.dart';

class OpcionesDescuento extends StatefulWidget {
  final bool tieneDescuento;
  final double porcentajeDescuento;
  final Function(bool?) onDescuentoChanged;
  final Function(String) onPorcentajeChanged;
  final TextEditingController porcentajeController;

  const OpcionesDescuento({
    super.key,
    required this.tieneDescuento,
    required this.porcentajeDescuento,
    required this.onDescuentoChanged,
    required this.onPorcentajeChanged,
    required this.porcentajeController,
  });

  @override
  State<OpcionesDescuento> createState() => _OpcionesDescuentoState();
}

class _OpcionesDescuentoState extends State<OpcionesDescuento> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabel(
          text: 'Opciones de Descuento',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
        ),
        SizedBox(height: 12),
        CustomCheckbox(
          label: 'Aplicar descuento',
          value: widget.tieneDescuento,
          onChanged: widget.onDescuentoChanged,
        ),
        if (widget.tieneDescuento) ...[
          SizedBox(height: 8),
          InputText(
            label: 'Porcentaje de Descuento (%)',
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
