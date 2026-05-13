import 'package:flutter/material.dart';
import '../../widgets/atoms/custom_button.dart';

class Problema3ResultadoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final resultados = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final sencillas = resultados['sencillas'] ?? '0';
    final dobles = resultados['dobles'] ?? '0';
    final triples = resultados['triples'] ?? '0';
    final subtotal = resultados['subtotal'] ?? '0.00';
    final cargo = resultados['cargo'] ?? '0.00';
    final total = resultados['total'] ?? '0.00';
    final usaTarjeta = resultados['usaTarjeta'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text("Resultados del Pedido"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta de resumen del pedido
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      "Resumen del Pedido",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("🍔 Sencillas:", style: TextStyle(fontSize: 16)),
                        Text(sencillas, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("🍔🍔 Dobles:", style: TextStyle(fontSize: 16)),
                        Text(dobles, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("🍔🍔🍔 Triples:", style: TextStyle(fontSize: 16)),
                        Text(triples, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Tarjeta de cálculos
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      "Detalles de Pago",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[900],
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Subtotal:", style: TextStyle(fontSize: 16)),
                        Text(
                          "\$$subtotal",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    if (usaTarjeta)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Cargo Tarjeta (5%):",
                                style: TextStyle(fontSize: 16, color: Colors.red[700]),
                              ),
                              Text(
                                "+ \$$cargo",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Divider(),
                          SizedBox(height: 12),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "TOTAL A PAGAR:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        Text(
                          "\$$total",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
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
