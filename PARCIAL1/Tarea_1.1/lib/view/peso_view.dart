import 'package:flutter/material.dart';
import '../controller/peso_controller.dart';

//********************** atomos **********************
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

//************************ molecula *********************************************
class PesajesForm extends StatelessWidget {
  final TextEditingController pesajes1C;
  final TextEditingController pesajes2C;

  PesajesForm({
    super.key,
    required this.pesajes1C,
    required this.pesajes2C,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputField(
          controller: pesajes1C,
          hint: 'Pesajes Balanza 1 (10 valores separados por coma)',
        ),
        SizedBox(height: 10),
        InputField(
          controller: pesajes2C,
          hint: 'Pesajes Balanza 2 (10 valores separados por coma)',
        ),
      ],
    );
  }
}

//***************************** organismo *********************************************
class PesoCard extends StatefulWidget {
  PesoCard({super.key});

  @override
  State<PesoCard> createState() => _PesoCardState();
}

class _PesoCardState extends State<PesoCard> {
  final _ctrlpesajes1 = TextEditingController();
  final _ctrlpesajes2 = TextEditingController();
  String _resultado = '';

  final _controller = PesoController();

  void _calcular() {
    setState(() {
      _resultado = _controller.procesar(
        _ctrlpesajes1.text,
        _ctrlpesajes2.text,
      );
    });
  }

  void _limpiar() {
    setState(() {
      _ctrlpesajes1.clear();
      _ctrlpesajes2.clear();
      _resultado = '';
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
            Label('Ingrese Datos de Pesaje'),
            SizedBox(height: 15),
            PesajesForm(
              pesajes1C: _ctrlpesajes1,
              pesajes2C: _ctrlpesajes2,
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PrimaryButton(text: 'Calcular', onPressed: _calcular),
                PrimaryButton(text: 'Limpiar', onPressed: _limpiar),
              ],
            ),
            SizedBox(height: 15),
            if (_resultado.isNotEmpty)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Label(_resultado),
              ),
          ],
        ),
      ),
    );
  }
}

//4. Pagina
class PesoPage extends StatelessWidget {
  PesoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Club Contra la Obesidad'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: PesoCard(),
      ),
    );
  }
}
