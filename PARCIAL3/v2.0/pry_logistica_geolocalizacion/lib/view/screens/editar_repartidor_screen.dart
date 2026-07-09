import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/vehiculo_constants.dart';
import '../../core/utils/validadores.dart';
import '../../model/domain/entities/repartidor_entity.dart';
import '../../viewmodel/gestion_repartidor_viewmodel.dart';

/// Edición de un repartidor existente (solo administrador): permite cambiar
/// el teléfono, el correo y los datos del vehículo. El nombre y la cédula
/// identifican a la persona y no se modifican.
class EditarRepartidorScreen extends StatefulWidget {
  final RepartidorEntity repartidor;

  const EditarRepartidorScreen({super.key, required this.repartidor});

  @override
  State<EditarRepartidorScreen> createState() => _EditarRepartidorScreenState();
}

class _EditarRepartidorScreenState extends State<EditarRepartidorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _telefonoController;
  late final TextEditingController _emailController;
  late final TextEditingController _marcaController;
  late final TextEditingController _placaController;
  late String _tipoVehiculo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<GestionRepartidorViewModel>().limpiar();
    });
    final r = widget.repartidor;
    _telefonoController = TextEditingController(text: r.telefono ?? '');
    _emailController = TextEditingController(text: r.email ?? '');
    _marcaController = TextEditingController(text: r.vehiculoMarca ?? '');
    _placaController = TextEditingController(text: r.vehiculoPlaca ?? '');
    _tipoVehiculo = VehiculoConstants.tipos.contains(r.vehiculoTipo)
        ? r.vehiculoTipo!
        : VehiculoConstants.tipos.first;
  }

  @override
  void dispose() {
    _telefonoController.dispose();
    _emailController.dispose();
    _marcaController.dispose();
    _placaController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<GestionRepartidorViewModel>();
    final actualizado = await viewModel.actualizarRepartidor(
      widget.repartidor.uid,
      telefono: _telefonoController.text.trim(),
      email: _emailController.text.trim(),
      vehiculoTipo: _tipoVehiculo,
      vehiculoMarca: _marcaController.text.trim(),
      vehiculoPlaca: _placaController.text.trim().toUpperCase(),
    );

    if (actualizado && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Datos de ${widget.repartidor.nombre} actualizados.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GestionRepartidorViewModel>();
    final cargando = viewModel.state == GestionRepartidorState.loading;
    final r = widget.repartidor;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Repartidor')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.sports_motorsports, color: Colors.white),
                ),
                title: Text(
                  r.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Cédula: ${r.cedula ?? 'N/D'}'),
              ),
            ),
            const SizedBox(height: 16),
            const _TituloSeccion('Datos de contacto', Icons.contact_phone),
            const SizedBox(height: 8),
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono celular',
                prefixIcon: Icon(Icons.phone_android),
              ),
              keyboardType: TextInputType.phone,
              validator: Validadores.telefonoEcuatoriano,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
                helperText:
                    'Actualiza el correo registrado; el correo con el que el '
                    'repartidor inicia sesión no cambia.',
                helperMaxLines: 2,
              ),
              keyboardType: TextInputType.emailAddress,
              validator: Validadores.email,
            ),
            const SizedBox(height: 24),
            const _TituloSeccion('Datos del vehículo', Icons.two_wheeler),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _tipoVehiculo,
              decoration: const InputDecoration(
                labelText: 'Tipo de vehículo',
                prefixIcon: Icon(Icons.commute),
              ),
              items: VehiculoConstants.tipos
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _tipoVehiculo = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _marcaController,
              decoration: const InputDecoration(
                labelText: 'Marca / modelo',
                prefixIcon: Icon(Icons.build_circle_outlined),
              ),
              validator: (v) => Validadores.requerido(v, 'Ingresa la marca o modelo'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _placaController,
              decoration: const InputDecoration(
                labelText: 'Placa',
                prefixIcon: Icon(Icons.pin_outlined),
                helperText: 'Ej. ABC-1234 (vehículo) o AB123C (moto)',
              ),
              textCapitalization: TextCapitalization.characters,
              validator: Validadores.placaEcuatoriana,
            ),
            const SizedBox(height: 16),
            if (viewModel.state == GestionRepartidorState.error &&
                viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: cargando
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Guardar cambios'),
              onPressed: cargando ? null : _guardar,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  final String titulo;
  final IconData icono;

  const _TituloSeccion(this.titulo, this.icono);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
