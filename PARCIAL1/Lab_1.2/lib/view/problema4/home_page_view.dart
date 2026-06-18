import 'package:flutter/material.dart';
import '../../controller/cantidad_controller.dart';
import '../../widgets/atoms/custom_button.dart';
import '../../widgets/atoms/custom_input.dart';

class Problema4HomeView extends StatefulWidget {
  @override
  State<Problema4HomeView> createState() => _Problema4HomeViewState();
}

class _Problema4HomeViewState extends State<Problema4HomeView> {
  final controller = CantidadController();
  final preciosController = TextEditingController();

  void _calcular() {
    final resultados = controller.calcularResultados(preciosController.text);

    if (resultados.containsKey("error")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultados["error"]!)),
      );
    } else {
      Navigator.pushNamed(context, '/resultado_problema4', arguments: resultados);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cálculo de Descuentos en Artículos"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Tarjeta principal con gradiente
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue[700]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_offer,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Tabla de Descuentos",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildDiscountRule(
                    icon: Icons.trending_up,
                    price: "≥ \$200",
                    discount: "15%",
                    color: Colors.amber[300]!,
                  ),
                  SizedBox(height: 12),
                  _buildDiscountRule(
                    icon: Icons.trending_up,
                    price: ">\$100 y <\$200",
                    discount: "12%",
                    color: Colors.orange[300]!,
                  ),
                  SizedBox(height: 12),
                  _buildDiscountRule(
                    icon: Icons.trending_down,
                    price: "≤ \$100",
                    discount: "10%",
                    color: Colors.red[300]!,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Sección de entrada
            Text(
              "Ingresa los precios",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Separa múltiples precios con comas",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),

            // Campo de entrada mejorado
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blueAccent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: CustomInput(
                controller: preciosController,
                label: "Ej: 150, 250, 80, 120, 95",
                icon: Icons.attach_money,
                maxLines: 3,
                keyboardType: TextInputType.text,
              ),
            ),
            SizedBox(height: 40),

            // Botón mejorado
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue[700]!],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.4),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: _calcular,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calculate, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          "Calcular Descuentos",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountRule({
    required IconData icon,
    required String price,
    required String discount,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              price,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color, width: 1),
            ),
            child: Text(
              discount,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    preciosController.dispose();
    super.dispose();
  }
}
