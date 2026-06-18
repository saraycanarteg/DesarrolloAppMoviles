import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
