import 'package:flutter/material.dart';
import '../../controller/profesor_controller.dart';
import '../../widgets/atoms/custom_button.dart';

class ProfesorView extends StatelessWidget {
  final controller = ProfesorController();

  void _calcular(BuildContext context) {
    final resultados = controller.obtenerCalculos();
    Navigator.pushNamed(context, '/resultado_profesor', arguments: resultados);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cálculo Salarial")),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.school, size: 80, color: Colors.blueAccent),
            ),
            SizedBox(height: 30),
            Text(
              "Incremento Anual del 10%",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Calcula la proyección salarial de un profesor que inicia con \$1,500 y recibe aumentos anuales durante 6 años.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.grey[600], height: 1.5),
            ),
            SizedBox(height: 40),
            CustomButton(
              text: "Ver Proyección",
              onPressed: () => _calcular(context)
            ),
          ],
        ),
      ),
    );
  }
}
