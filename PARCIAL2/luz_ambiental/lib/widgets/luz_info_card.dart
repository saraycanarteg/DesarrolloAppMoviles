import 'package:flutter/material.dart';
import '../models/luz.dart';
import '../controllers/luz_controller.dart';

class LuzInfoCard extends StatelessWidget {
  final Luz luz;
  final LuzController controller;

  const LuzInfoCard({
    super.key,
    required this.luz,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorEstado = controller.obtenerColorEstado(luz.estado);
    final IconData icono = controller.obtenerIconoEstado(luz.estado);
    final double progreso = controller.obtenerProgreso(luz.lux);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado con ícono
            Row(
              children: [
                Icon(icono, color: colorEstado, size: 28),
                const SizedBox(width: 10),
                Text(
                  "Estado: ${luz.estado}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorEstado,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Barra de progreso de lux
            Text(
              "Nivel de iluminación",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progreso,
                minHeight: 14,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(colorEstado),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("0 lux", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                Text("1000+ lux", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
            const SizedBox(height: 16),

            // Recomendación
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorEstado.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorEstado.withOpacity(0.3)),
              ),
              child: Text(
                luz.recomendacion,
                style: TextStyle(fontSize: 14, color: colorEstado),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
