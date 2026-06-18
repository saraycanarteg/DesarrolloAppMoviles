import 'package:flutter/material.dart';
import '../controller/cajero_controller.dart';

//1. átomos *****************************************
class Label extends StatelessWidget{
  final String text;
  Label(this.text, {super.key});

  @override
  Widget build(BuildContext context)  => 
      Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),);
}

class InputField extends StatelessWidget{
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
  );
}

class PrimaryButton extends StatelessWidget{
  final String text;
  final VoidCallback onPressed;
  PrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context)  =>
      ElevatedButton(onPressed: onPressed, child: Text(text));
}

//2. organimos *****************************************************************
class CajeroCard extends StatefulWidget{
  CajeroCard({super.key});

  @override
  State<CajeroCard> createState() => CajeroCardState();
}

class CajeroCardState extends State<CajeroCard>{
  final _input = TextEditingController();
  final _controller = CajeroController();
  String _resultado = '';

  void _calcular(){
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
            Label('Ingrese los precios separados por coma'),
            SizedBox(height: 10,),
            InputField(controller: _input, hint: 'Ejemplo: 10,15,20'),
            SizedBox(height: 10,),
            PrimaryButton(text: 'Calcular', onPressed: _calcular),
            SizedBox(height: 10,),
            Label(_resultado),
          ],
        )),
    );
  }
}

//3. pagina ********************************************************************
class CajeroPage extends StatelessWidget{
  CajeroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cajero Supermercado'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
          padding: EdgeInsets.all(10),
        child: CajeroCard(),
      ),
    );
  }
}