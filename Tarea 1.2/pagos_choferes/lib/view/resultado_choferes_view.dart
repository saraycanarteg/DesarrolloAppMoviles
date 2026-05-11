import 'package:flutter/material.dart';

class ResultadoChoferesView extends StatelessWidget {
  const ResultadoChoferesView({super.key});

  @override
  Widget build(BuildContext context) {
    final resultado = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte de Nómina'),
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
                    border: Border.all(color: Colors.deepOrange, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.orange.shade50,
                  ),
                  child: Text(
                    resultado ?? 'Sin información disponible',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 13,
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
                backgroundColor: Colors.deepOrange,
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
                  SnackBar(content: Text('Nómina guardada')),
                );
              },
              icon: Icon(Icons.save),
              label: Text('Guardar Nómina'),
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
