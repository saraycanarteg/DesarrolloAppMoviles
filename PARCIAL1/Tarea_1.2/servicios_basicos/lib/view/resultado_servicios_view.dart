import 'package:flutter/material.dart';

class ResultadoServiciosView extends StatelessWidget {
  const ResultadoServiciosView({super.key});

  @override
  Widget build(BuildContext context) {
    final resultado = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Comprobante de Pago'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blue.shade50,
                  ),
                  child: Text(
                    resultado ?? 'Sin información disponible',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Volver',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Comprobante guardado')),
                );
              },
              icon: Icon(Icons.save),
              label: Text('Guardar Comprobante'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
