import 'package:flutter/material.dart';
import '../atoms/custom_label.dart';
import '../atoms/custom_radio.dart';

class SelectorTipoChofer extends StatefulWidget {
  final String tipoSeleccionado;
  final Function(String?) onTipoChanged;

  const SelectorTipoChofer({
    super.key,
    required this.tipoSeleccionado,
    required this.onTipoChanged,
  });

  @override
  State<SelectorTipoChofer> createState() => _SelectorTipoChoferState();
}

class _SelectorTipoChoferState extends State<SelectorTipoChofer> {
  final List<String> tipos = ['Diurno', 'Nocturno', 'Mixto'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabel(
          text: 'Tipo de Jornada',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
        ),
        SizedBox(height: 12),
        ...tipos.map(
          (tipo) => CustomRadio(
            label: tipo,
            value: tipo,
            groupValue: widget.tipoSeleccionado,
            onChanged: widget.onTipoChanged,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
