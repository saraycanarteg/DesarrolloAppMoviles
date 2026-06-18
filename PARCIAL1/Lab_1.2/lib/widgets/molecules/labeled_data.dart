import 'package:flutter/material.dart';

class LabeledData extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const LabeledData({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
