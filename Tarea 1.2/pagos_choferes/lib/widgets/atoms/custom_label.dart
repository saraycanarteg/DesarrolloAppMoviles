import 'package:flutter/material.dart';

class CustomLabel extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const CustomLabel({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: style ??
          Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
    );
  }
}
