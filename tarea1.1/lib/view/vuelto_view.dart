import 'package:flutter/material.dart';
import 'package:deber_p1/controller/vuelto_controller.dart';

//********************** atomos **********************
class Label extends StatelessWidget{
  final String text;
  Label(this.text, {super.key});

  @override
  Widget build(BuildContext context)  =>
      Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),);
}

class MoneyField extends StatelessWidget{
  final TextEditingController controller;
  final String hint;

  MoneyField({super.key, required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
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

//************************ molecula *********************************************
class MoneyInput extends StatelessWidget{
  final TextEditingController precioC, valorC;

  MoneyInput({super.key, required this.precioC, required this.valorC});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: MoneyField(controller: precioC, hint: 'Precio del Producto',)),
        SizedBox(width: 10,),
        Expanded(child: MoneyField(controller: valorC, hint: 'Valor Entregado por Cliente',)),
        SizedBox(width: 10,),
       ],
    );
  }
}


//***************************** organismo *********************************************
class VueltoCard extends StatefulWidget{
  VueltoCard({super.key});

  @override
  State<VueltoCard> createState() => _VueltoCardState();
}

class _VueltoCardState extends State<VueltoCard>{
  final _ctrlvalor = TextEditingController();
  final _ctrlprecio = TextEditingController();
  String _resultado = '';

  //instanciar controller
  final _controller = VueltoController();

  //metodo
  void _calcular(){
    setState(() {
      _resultado = _controller.procesar(_ctrlprecio.text, _ctrlvalor.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Label('Ingrese Valores de Precio y Entregados'),
            SizedBox(height: 10,),
            MoneyInput(precioC: _ctrlprecio, valorC: _ctrlvalor),
            SizedBox(height: 10,),
            PrimaryButton(text: 'Calcular Vuelto', onPressed: _calcular),
            SizedBox(height: 10,),
            Label(_resultado),
          ],
        ),

      ),
    );
  }
}

//4. Pagina
class VueltoPage extends StatelessWidget {
  VueltoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cálculo de Cambio'),
        backgroundColor: Colors.lightBlueAccent,),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: VueltoCard(),
      ),
    );
  }
}