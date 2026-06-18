import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  final String label;
  final bool value;
  final Function(bool?) onChanged;

  const CustomCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.value,
          onChanged: widget.onChanged,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
