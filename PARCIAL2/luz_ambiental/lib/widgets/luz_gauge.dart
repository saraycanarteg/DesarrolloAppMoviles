import 'dart:math';
import 'package:flutter/material.dart';

class LuzGauge extends StatelessWidget {
  final int lux;
  final Color color;
  final double maxLux;

  const LuzGauge({
    super.key,
    required this.lux,
    required this.color,
    this.maxLux = 1000,
  });

  @override
  Widget build(BuildContext context) {
    final double progreso = (lux / maxLux).clamp(0.0, 1.0);

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: _GaugePainter(progreso: progreso, color: color),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$lux",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Text(
                "lux",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progreso;
  final Color color;

  _GaugePainter({required this.progreso, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Arco de fondo
    final paintFondo = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      pi * 1.5,
      false,
      paintFondo,
    );

    // Arco de progreso
    final paintProgreso = Paint()
      ..color = color
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      pi * 1.5 * progreso,
      false,
      paintProgreso,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.progreso != progreso || oldDelegate.color != color;
  }
}
