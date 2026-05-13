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
  final cantidadesController = TextEditingController();

  void _calcular() {
    final resultados = controller.calcularResultados(cantidadesController.text);

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
        title: Text("Clasificación de Cantidades"),
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
                child: Row(
                  children: [
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Ingrese N cantidades separadas por comas para clasificarlas como ceros, negativos o positivos.",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            CustomInput(
              controller: cantidadesController,
              label: "Cantidades (ej: 5, -3, 0, 8, -1)",
              icon: Icons.numbers,
              maxLines: 3,
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 32),
            CustomButton(text: "Clasificar", onPressed: _calcular),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    cantidadesController.dispose();
    super.dispose();
  }
}
