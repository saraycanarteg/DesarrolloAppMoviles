import 'package:flutter/material.dart';
import '../../widgets/atoms/custom_button.dart';

class Problema4ResultadoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final resultados = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final articulos = resultados['articulos'] as List<dynamic>? ?? [];
    final costoTotal = resultados['costoTotal'] ?? '0.00';
    final descuentoTotal = resultados['descuentoTotal'] ?? '0.00';
    final totalAPagar = resultados['totalAPagar'] ?? '0.00';

    return Scaffold(
      appBar: AppBar(
        title: Text("Resumen de Descuentos"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta de resumen general
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.blueAccent[100],
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      "Cálculo de Descuentos",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent[800],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Total de artículos: ${articulos.length}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueAccent[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Detalle de artículos
            Text(
              "Detalle por Artículo",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            ...articulos.map((articulo) {
              final numero = articulo['numero'];
              final precio = articulo['precio'].toStringAsFixed(2);
              final porcentajeDescuento = articulo['porcentajeDescuento'];
              final descuento = articulo['descuento'].toStringAsFixed(2);
              final precioFinal = articulo['precioFinal'].toStringAsFixed(2);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Artículo #$numero",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "$porcentajeDescuento% DESC",
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Precio Original:"),
                            Text(
                              "\$$precio",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Descuento:"),
                            Text(
                              "-\$$descuento",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[600],
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Precio Final:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "\$$precioFinal",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),

            SizedBox(height: 24),

            // Tarjeta de totales
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildTotalRow(
                      "Costo Total:",
                      "\$$costoTotal",
                      Colors.grey[700]!,
                    ),
                    SizedBox(height: 12),
                    _buildTotalRow(
                      "Descuento Total:",
                      "-\$$descuentoTotal",
                      Colors.red[600]!,
                    ),
                    Divider(height: 20),
                    _buildTotalRow(
                      "TOTAL A PAGAR:",
                      "\$$totalAPagar",
                      Colors.green[700]!,
                      isBold: true,
                      fontSize: 18,
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

  Widget _buildTotalRow(
    String label,
    String value,
    Color color, {
    bool isBold = false,
    double fontSize = 16,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            color: color,
          ),
        ),
      ],
    );
  }
}
