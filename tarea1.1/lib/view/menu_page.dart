import 'package:flutter/material.dart';
import 'cajero_view.dart';
import 'vuelto_view.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menú Principal"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CajeroPage()),
                );
              },
              child: Text("Ejercicio 1 - Cajero"),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VueltoPage()),
                );
              },
              child: Text("Ejercicio 2 - Vuelto"),
            ),

          ],
        ),
      ),
    );
  }
}