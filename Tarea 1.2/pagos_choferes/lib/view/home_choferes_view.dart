import 'package:flutter/material.dart';
import '../controller/chofer_controller.dart';
import '../widgets/organisms/formulario_chofer.dart';

class HomeChoferesView extends StatefulWidget {
  const HomeChoferesView({super.key});

  @override
  State<HomeChoferesView> createState() => _HomeChoferesViewState();
}

class _HomeChoferesViewState extends State<HomeChoferesView> {
  final controller = ChoferController();

  void _registrarChofer(
    String nombre,
    String horasLunes,
    String horasMartes,
    String horasMiercoles,
    String horasJueves,
    String horasViernes,
    String horasSabado,
    String sueldoPorHora,
    bool estaActivo,
    bool recibeBono,
    String tipoChofer,
  ) {
    final resultado = controller.registrarChofer(
      nombre: nombre,
      horasLunes: horasLunes,
      horasMartes: horasMartes,
      horasMiercoles: horasMiercoles,
      horasJueves: horasJueves,
      horasViernes: horasViernes,
      horasSabado: horasSabado,
      sueldoPorHoraStr: sueldoPorHora,
      estaActivo: estaActivo,
      recibeBono: recibeBono,
      tipoChofer: tipoChofer,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resultado)),
    );

    setState(() {});
  }

  void _calcularNomina() {
    final resultado = controller.procesarNomina();
    Navigator.pushNamed(context, '/resultado', arguments: resultado);
  }

  void _limpiarTodo() {
    controller.limpiar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Todos los datos han sido eliminados')),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nómina de Choferes'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FormularioChofer(
        onRegistrar: _registrarChofer,
        onLimpiar: _limpiarTodo,
        onCalcular: _calcularNomina,
        choferesRegistrados: controller.totalChoferesRegistrados,
      ),
    );
  }
}
