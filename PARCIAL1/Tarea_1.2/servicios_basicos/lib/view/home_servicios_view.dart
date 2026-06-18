import 'package:flutter/material.dart';
import '../controller/servicio_controller.dart';
import '../widgets/organisms/formulario_pago.dart';

class HomeServiciosView extends StatefulWidget {
  const HomeServiciosView({super.key});

  @override
  State<HomeServiciosView> createState() => _HomeServiciosViewState();
}

class _HomeServiciosViewState extends State<HomeServiciosView> {
  final controller = ServicioController();

  void _procesarPago(
    String nombre,
    String cedula,
    String direccion,
    String servicio,
    String consumo,
    bool tieneDescuento,
    double porcentajeDescuento,
    bool tieneRecargo,
    double porcentajeRecargo,
  ) {
    final resultado = controller.procesarPago(
      nombreCliente: nombre,
      cedulaCliente: cedula,
      direccionCliente: direccion,
      tipoServicio: servicio,
      consumoStr: consumo,
      tieneDescuento: tieneDescuento,
      porcentajeDescuento: porcentajeDescuento,
      tieneRecargo: tieneRecargo,
      porcentajeRecargo: porcentajeRecargo,
    );

    if (resultado.startsWith('====')) {
      Navigator.pushNamed(context, '/resultado', arguments: resultado);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagos de Servicios Básicos'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FormularioPago(
        onCalcular: _procesarPago,
        onLimpiar: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Formulario limpiado')),
          );
        },
      ),
    );
  }
}
