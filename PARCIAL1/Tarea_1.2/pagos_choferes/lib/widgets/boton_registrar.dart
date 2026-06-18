import 'package:flutter/material.dart';

class BotonRegistrar extends StatelessWidget {

  final VoidCallback onPressed;

  const BotonRegistrar({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text('Registrar'),
    );
  }
}