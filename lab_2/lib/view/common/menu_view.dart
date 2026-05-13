import 'package:flutter/material.dart';
import '../../widgets/atoms/custom_button.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laboratorio 2 - Menú"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueAccent.withOpacity(0.0),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Selecciona un Ejercicio",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),

              const SizedBox(height: 40),

              _menuItem(
                context,
                "Problema 1",
                "Cálculo de Sueldo y Factura",
                '/problema1',
              ),

              const SizedBox(height: 20),

              _menuItem(
                context,
                "Problema 2",
                "Incremento Salarial Profesor",
                '/problema2',
              ),

              const SizedBox(height: 20),

              _menuItem(
                context,
                "Problema 3",
                "Pedido de Hamburguesas",
                '/problema3',
              ),

              const SizedBox(height: 20),

              _menuItem(
                context,
                "Problema 4",
                "Clasificación de Cantidades",
                '/problema4',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
      BuildContext context,
      String title,
      String subtitle,
      String route,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}