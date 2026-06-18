import 'package:flutter/material.dart';

class BotonCalcular extends StatelessWidget {

  final VoidCallback onPressed;

  const BotonCalcular({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {

    return ElevatedButton.icon(

      onPressed: onPressed,

      icon: const Icon(Icons.calculate),

      label: const Text('Calcular'),

      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}