import 'package:flutter/material.dart';
import '../../widgets/atoms/custom_button.dart';

class Problema4ResultadoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final resultados = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final ceros = resultados['ceros'] ?? '0';
    final negativos = resultados['negativos'] ?? '0';
    final positivos = resultados['positivos'] ?? '0';
    final total = resultados['total'] ?? '0';

    return Scaffold(
      appBar: AppBar(
        title: Text("Resultados"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta de resumen
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      "Análisis de Cantidades",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Total de cantidades: $total",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Tarjeta de Ceros
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(Icons.circle_outlined, size: 40, color: Colors.blue),
                    SizedBox(height: 12),
                    Text(
                      "Cantidades Cero",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      ceros,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Tarjeta de Negativos
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(Icons.trending_down, size: 40, color: Colors.red),
                    SizedBox(height: 12),
                    Text(
                      "Cantidades Negativas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      negativos,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Tarjeta de Positivos
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(Icons.trending_up, size: 40, color: Colors.green),
                    SizedBox(height: 12),
                    Text(
                      "Cantidades Positivas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      positivos,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),

            CustomButton(
              text: "Volver al Menú",
              onPressed: () => Navigator.pushNamed(context, '/menu'),
            ),
          ],
        ),
      ),
    );
  }
}
