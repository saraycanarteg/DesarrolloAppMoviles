import 'package:flutter/material.dart';
import '../../controller/vendedor_controller.dart';
import '../../widgets/atoms/custom_button.dart';
import '../../widgets/atoms/custom_input.dart';

class HomePaginaView extends StatefulWidget {
  @override
  State<HomePaginaView> createState() => _HomePaginaViewState();
}

class _HomePaginaViewState extends State<HomePaginaView> {
  final controller = VendedorController();
  final venta1Controller = TextEditingController();
  final venta2Controller = TextEditingController();
  final venta3Controller = TextEditingController();

  void _calcular() {
    final resultados = controller.calcularResultados(
      venta1Controller.text,
      venta2Controller.text,
      venta3Controller.text,
    );

    if (resultados.containsKey("error")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultados["error"]!)),
      );
    } else {
      Navigator.pushNamed(context, '/resultado', arguments: resultados);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ventas y Comisiones"), backgroundColor: Colors.blueAccent,foregroundColor: Colors.white,),
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
                        "Ingrese el valor de las tres ventas para calcular el sueldo del vendedor y generar la factura.",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            CustomInput(controller: venta1Controller, label: "Monto Venta 1", icon: Icons.attach_money),
            SizedBox(height: 16),
            CustomInput(controller: venta2Controller, label: "Monto Venta 2", icon: Icons.attach_money),
            SizedBox(height: 16),
            CustomInput(controller: venta3Controller, label: "Monto Venta 3", icon: Icons.attach_money),
            SizedBox(height: 32),
            CustomButton(text: "Calcular", onPressed: _calcular),
          ],
        ),
      ),
    );
  }
}
