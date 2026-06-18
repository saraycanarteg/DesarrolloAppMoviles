import 'package:flutter/material.dart';
import '../controller/bisiesto_controller.dart';

//1. átomos *****************************************
class Label extends StatelessWidget {
  final String text;
  Label(this.text, {super.key});

  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
}

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  InputField({super.key, required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: hint,
      border: OutlineInputBorder(),
    ),
    keyboardType: TextInputType.number,
  );
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  PrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) =>
      ElevatedButton(onPressed: onPressed, child: Text(text));
}

//2. organismos *************************************************************
class BisiestoCard extends StatefulWidget {
  BisiestoCard({super.key});

  @override
  State<BisiestoCard> createState() => BisiestoCardState();
}

class BisiestoCardState extends State<BisiestoCard> {
  final _input = TextEditingController();
  final _controller = BisiestoController();
  String _resultado = '';

  void _calcular() {
    setState(() {
      _resultado = _controller.procesar(_input.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Label('Ingrese un año'),
            SizedBox(height: 10),
            InputField(controller: _input, hint: 'Ejemplo: 2000'),
            SizedBox(height: 10),
            PrimaryButton(text: 'Verificar', onPressed: _calcular),
            SizedBox(height: 10),
            Label(_resultado),
          ],
        ),
      ),
    );
  }
}

//3. página ******************************************************************
class BisiestoPage extends StatelessWidget {
  BisiestoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Año Bisiesto'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: BisiestoCard(),
      ),
    );
  }
}
