import 'package:flutter/material.dart';

class BotonLimpiar extends StatelessWidget {

  final VoidCallback onPressed;

  const BotonLimpiar({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text('Limpiar'),
    );
  }
}