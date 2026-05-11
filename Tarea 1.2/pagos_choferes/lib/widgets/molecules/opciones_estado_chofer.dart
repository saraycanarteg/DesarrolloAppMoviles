import 'package:flutter/material.dart';
import '../atoms/custom_label.dart';
import '../atoms/custom_checkbox.dart';

class OpcionesEstadoChofer extends StatefulWidget {
  final bool estaActivo;
  final bool recibeBono;
  final Function(bool?) onActivoChanged;
  final Function(bool?) onBonoChanged;

  const OpcionesEstadoChofer({
    super.key,
    required this.estaActivo,
    required this.recibeBono,
    required this.onActivoChanged,
    required this.onBonoChanged,
  });

  @override
  State<OpcionesEstadoChofer> createState() => _OpcionesEstadoChoferState();
}

class _OpcionesEstadoChoferState extends State<OpcionesEstadoChofer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabel(
          text: 'Estado del Chofer',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
        ),
        SizedBox(height: 12),
        CustomCheckbox(
          label: 'Chofer Activo',
          value: widget.estaActivo,
          onChanged: widget.onActivoChanged,
        ),
        SizedBox(height: 8),
        CustomCheckbox(
          label: 'Recibe Bono (10%)',
          value: widget.recibeBono,
          onChanged: widget.onBonoChanged,
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
