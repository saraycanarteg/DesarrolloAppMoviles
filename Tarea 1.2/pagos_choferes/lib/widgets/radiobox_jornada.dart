import 'package:flutter/material.dart';

class RadioboxJornada extends StatelessWidget {

  final String value;
  final String groupValue;
  final Function(String?) onChanged;
  final String texto;

  const RadioboxJornada({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      title: Text(texto),
      onChanged: onChanged,
    );
  }
}