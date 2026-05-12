import 'package:flutter/material.dart';
import '../../widgets/atoms/custom_button.dart';
import '../../widgets/molecules/labeled_data.dart';
import '../../widgets/organisms/result_card.dart';

class ResultadoPageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final datos = ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    return Scaffold(
      appBar: AppBar(title: Text("Resumen de Resultados")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            ResultCard(
              title: "DETALLE DE FACTURA",
              icon: Icons.receipt_long,
              children: [
                LabeledData(label: "Subtotal Ventas:", value: "\$${datos['subtotal']}"),
                LabeledData(label: "Descuento Aplicado (20%):", value: "-\$${datos['descuento']}", valueColor: Colors.red[700]),
                LabeledData(label: "IVA (15%):", value: "+\$${datos['iva']}"),
                Divider(height: 24),
                LabeledData(
                  label: "TOTAL A PAGAR:", 
                  value: "\$${datos['total']}", 
                  isBold: true, 
                  valueColor: Colors.blueAccent
                ),
              ],
            ),
            SizedBox(height: 20),
            ResultCard(
              title: "PAGO AL VENDEDOR",
              icon: Icons.payments,
              children: [
                LabeledData(
                  label: "Sueldo Final + Comisión:", 
                  value: "\$${datos['sueldo']}", 
                  isBold: true, 
                  valueColor: Colors.green[700]
                ),
              ],
            ),
            SizedBox(height: 40),
            CustomButton(
              text: "Volver al inicio",
              onPressed: () => Navigator.pop(context),
              color: Colors.grey[800],
            ),
          ],
        ),
      ),
    );
  }
}
