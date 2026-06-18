import 'package:flutter/material.dart';

class LabelResultado extends StatelessWidget {

  final String texto;

  const LabelResultado({
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}