import 'package:flutter/material.dart';
import '../molecules/info_cliente.dart';
import '../molecules/selector_servicio.dart';
import '../molecules/datos_consumo.dart';
import '../molecules/opciones_descuento.dart';
import '../molecules/opciones_recargo.dart';
import '../atoms/custom_button.dart';

class FormularioPago extends StatefulWidget {
  final Function(
    String, // nombre
    String, // cedula
    String, // direccion
    String, // servicio
    String, // consumo
    bool, // tieneDescuento
    double, // porcentajeDescuento
    bool, // tieneRecargo
    double, // porcentajeRecargo
  ) onCalcular;
  final VoidCallback onLimpiar;

  const FormularioPago({
    super.key,
    required this.onCalcular,
    required this.onLimpiar,
  });

  @override
  State<FormularioPago> createState() => _FormularioPagoState();
}

class _FormularioPagoState extends State<FormularioPago> {
  final nombreController = TextEditingController();
  final cedulaController = TextEditingController();
  final direccionController = TextEditingController();
  final consumoController = TextEditingController();
  final porcentajeDescuentoController = TextEditingController(text: '0');
  final porcentajeRecargoController = TextEditingController(text: '0');

  String servicioSeleccionado = 'Agua Potable';
  bool tieneDescuento = false;
  bool tieneRecargo = false;

  @override
  void dispose() {
    nombreController.dispose();
    cedulaController.dispose();
    direccionController.dispose();
    consumoController.dispose();
    porcentajeDescuentoController.dispose();
    porcentajeRecargoController.dispose();
    super.dispose();
  }

  void _calcular() {
    try {
      final porcentajeDesc = tieneDescuento
          ? double.parse(porcentajeDescuentoController.text)
          : 0.0;
      final porcentajeRec = tieneRecargo
          ? double.parse(porcentajeRecargoController.text)
          : 0.0;

      widget.onCalcular(
        nombreController.text,
        cedulaController.text,
        direccionController.text,
        servicioSeleccionado,
        consumoController.text,
        tieneDescuento,
        porcentajeDesc,
        tieneRecargo,
        porcentajeRec,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Ingrese valores válidos')),
      );
    }
  }

  void _limpiar() {
    nombreController.clear();
    cedulaController.clear();
    direccionController.clear();
    consumoController.clear();
    porcentajeDescuentoController.text = '0';
    porcentajeRecargoController.text = '0';
    setState(() {
      servicioSeleccionado = 'Agua Potable';
      tieneDescuento = false;
      tieneRecargo = false;
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
            InfoCliente(
              nombreController: nombreController,
              cedulaController: cedulaController,
              direccionController: direccionController,
            ),
            SizedBox(height: 20),
            SelectorServicio(
              servicioSeleccionado: servicioSeleccionado,
              onServicioChanged: (valor) {
                setState(() {
                  servicioSeleccionado = valor ?? servicioSeleccionado;
                });
              },
            ),
            DatosConsumo(
              consumoController: consumoController,
              servicioSeleccionado: servicioSeleccionado,
            ),
            SizedBox(height: 20),
            OpcionesDescuento(
              tieneDescuento: tieneDescuento,
              porcentajeDescuento:
                  double.tryParse(porcentajeDescuentoController.text) ?? 0.0,
              onDescuentoChanged: (valor) {
                setState(() {
                  tieneDescuento = valor ?? false;
                });
              },
              onPorcentajeChanged: (valor) {
                porcentajeDescuentoController.text = valor;
              },
              porcentajeController: porcentajeDescuentoController,
            ),
            SizedBox(height: 20),
            OpcionesRecargo(
              tieneRecargo: tieneRecargo,
              porcentajeRecargo:
                  double.tryParse(porcentajeRecargoController.text) ?? 0.0,
              onRecargoChanged: (valor) {
                setState(() {
                  tieneRecargo = valor ?? false;
                });
              },
              onPorcentajeChanged: (valor) {
                porcentajeRecargoController.text = valor;
              },
              porcentajeController: porcentajeRecargoController,
            ),
            SizedBox(height: 24),
            CustomButton(
              label: 'Calcular Pago',
              onPressed: _calcular,
              backgroundColor: Colors.blue,
            ),
            SizedBox(height: 12),
            CustomButton(
              label: 'Limpiar',
              onPressed: _limpiar,
              backgroundColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
