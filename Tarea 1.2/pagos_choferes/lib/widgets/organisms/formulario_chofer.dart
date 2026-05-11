import 'package:flutter/material.dart';
import '../molecules/info_chofer.dart';
import '../molecules/datos_horas.dart';
import '../molecules/selector_tipo_chofer.dart';
import '../molecules/opciones_estado_chofer.dart';
import '../atoms/custom_button.dart';

class FormularioChofer extends StatefulWidget {
  final Function(
    String, // nombre
    String, // horasLunes
    String, // horasMartes
    String, // horasMiercoles
    String, // horasJueves
    String, // horasViernes
    String, // horasSabado
    String, // sueldoPorHora
    bool, // estaActivo
    bool, // recibeBono
    String, // tipoChofer
  ) onRegistrar;
  final VoidCallback onLimpiar;
  final VoidCallback onCalcular;
  final int choferesRegistrados;

  const FormularioChofer({
    super.key,
    required this.onRegistrar,
    required this.onLimpiar,
    required this.onCalcular,
    required this.choferesRegistrados,
  });

  @override
  State<FormularioChofer> createState() => _FormularioChoferState();
}

class _FormularioChoferState extends State<FormularioChofer> {
  final nombreController = TextEditingController();
  final sueldoPorHoraController = TextEditingController();
  final horasControllers = List.generate(6, (_) => TextEditingController());

  String tipoSeleccionado = 'Diurno';
  bool estaActivo = true;
  bool recibeBono = false;

  @override
  void dispose() {
    nombreController.dispose();
    sueldoPorHoraController.dispose();
    for (var controller in horasControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _registrar() {
    widget.onRegistrar(
      nombreController.text,
      horasControllers[0].text,
      horasControllers[1].text,
      horasControllers[2].text,
      horasControllers[3].text,
      horasControllers[4].text,
      horasControllers[5].text,
      sueldoPorHoraController.text,
      estaActivo,
      recibeBono,
      tipoSeleccionado,
    );

    // Limpiar solo el formulario actual
    nombreController.clear();
    sueldoPorHoraController.clear();
    for (var controller in horasControllers) {
      controller.clear();
    }
    tipoSeleccionado = 'Diurno';
    estaActivo = true;
    recibeBono = false;
    setState(() {});
  }

  void _limpiarTodo() {
    nombreController.clear();
    sueldoPorHoraController.clear();
    for (var controller in horasControllers) {
      controller.clear();
    }
    setState(() {
      tipoSeleccionado = 'Diurno';
      estaActivo = true;
      recibeBono = false;
    });
    widget.onLimpiar();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Choferes Registrados: ${widget.choferesRegistrados}/5',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            SizedBox(height: 20),
            InfoChofer(
              nombreController: nombreController,
              sueldoPorHoraController: sueldoPorHoraController,
            ),
            SizedBox(height: 20),
            DatosHoras(
              horasControllers: horasControllers,
            ),
            SizedBox(height: 20),
            SelectorTipoChofer(
              tipoSeleccionado: tipoSeleccionado,
              onTipoChanged: (valor) {
                setState(() {
                  tipoSeleccionado = valor ?? tipoSeleccionado;
                });
              },
            ),
            SizedBox(height: 20),
            OpcionesEstadoChofer(
              estaActivo: estaActivo,
              recibeBono: recibeBono,
              onActivoChanged: (valor) {
                setState(() {
                  estaActivo = valor ?? false;
                });
              },
              onBonoChanged: (valor) {
                setState(() {
                  recibeBono = valor ?? false;
                });
              },
            ),
            SizedBox(height: 24),
            CustomButton(
              label: 'Registrar Chofer',
              onPressed: _registrar,
              backgroundColor: Colors.green,
            ),
            SizedBox(height: 12),
            if (widget.choferesRegistrados > 0)
              CustomButton(
                label: 'Calcular Nómina',
                onPressed: widget.onCalcular,
                backgroundColor: Colors.deepOrange,
              ),
            if (widget.choferesRegistrados > 0) SizedBox(height: 12),
            CustomButton(
              label: 'Limpiar Todo',
              onPressed: _limpiarTodo,
              backgroundColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
