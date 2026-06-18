import 'package:flutter/material.dart';
import '../../controller/hamburguesa_controller.dart';
import '../../widgets/atoms/custom_button.dart';
import '../../widgets/atoms/custom_input.dart';

class Problema3HomeView extends StatefulWidget {
  @override
  State<Problema3HomeView> createState() => _Problema3HomeViewState();
}

class _Problema3HomeViewState extends State<Problema3HomeView> {
  final controller = HamburguesaController();
  final sencillasController = TextEditingController();
  final doblesController = TextEditingController();
  final triplesController = TextEditingController();
  bool usaTarjeta = false;

  void _calcular() {
    final resultados = controller.calcularResultados(
      sencillasController.text,
      doblesController.text,
      triplesController.text,
      usaTarjeta,
    );

    if (resultados.containsKey("error")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultados["error"]!)),
      );
    } else {
      Navigator.pushNamed(context, '/resultado_problema3', arguments: resultados);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("El Náufrago Satisfecho"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              elevation: 0,
              color: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Menú",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "🍔 Hamburguesa Sencilla: \$20",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "🍔 Hamburguesa Doble: \$25",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "🍔 Hamburguesa Triple: \$28",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "💳 Cargo con tarjeta de crédito: 5%",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            CustomInput(
              controller: sencillasController,
              label: "Hamburguesas Sencillas (S)",
              icon: Icons.fastfood,
            ),
            SizedBox(height: 16),
            CustomInput(
              controller: doblesController,
              label: "Hamburguesas Dobles (D)",
              icon: Icons.fastfood,
            ),
            SizedBox(height: 16),
            CustomInput(
              controller: triplesController,
              label: "Hamburguesas Triples (T)",
              icon: Icons.fastfood,
            ),
            SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "¿Pagar con tarjeta de crédito?",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Switch(
                      value: usaTarjeta,
                      onChanged: (value) {
                        setState(() {
                          usaTarjeta = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            CustomButton(text: "Calcular Total", onPressed: _calcular),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    sencillasController.dispose();
    doblesController.dispose();
    triplesController.dispose();
    super.dispose();
  }
}
