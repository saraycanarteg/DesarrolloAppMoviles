import 'package:flutter/material.dart';
import '../atoms/custom_label.dart';
import '../atoms/custom_radio.dart';

class SelectorServicio extends StatefulWidget {
  final String servicioSeleccionado;
  final Function(String?) onServicioChanged;

  const SelectorServicio({
    super.key,
    required this.servicioSeleccionado,
    required this.onServicioChanged,
  });

  @override
  State<SelectorServicio> createState() => _SelectorServicioState();
}

class _SelectorServicioState extends State<SelectorServicio> {
  final List<String> servicios = [
    'Agua Potable',
    'Energía Eléctrica',
    'Internet y Telefonía',
    'TV por Cable',
    'Otros Pagos',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabel(
          text: 'Tipo de Servicio',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
        ),
        SizedBox(height: 12),
        ...servicios.map(
          (servicio) => CustomRadio(
            label: servicio,
            value: servicio,
            groupValue: widget.servicioSeleccionado,
            onChanged: widget.onServicioChanged,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
