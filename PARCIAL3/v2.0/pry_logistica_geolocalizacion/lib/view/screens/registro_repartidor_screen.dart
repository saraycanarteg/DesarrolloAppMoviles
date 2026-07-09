import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/vehiculo_constants.dart';
import '../../core/utils/validadores.dart';
import '../../viewmodel/gestion_repartidor_viewmodel.dart';

/// Alta de repartidores (solo administrador): pide los datos personales
/// (la cédula se valida con el dígito verificador y se verifica que no esté
/// repetida en la base) y los datos del vehículo de reparto.
class RegistroRepartidorScreen extends StatefulWidget {
  const RegistroRepartidorScreen({super.key});

  @override
  State<RegistroRepartidorScreen> createState() => _RegistroRepartidorScreenState();
}

class _RegistroRepartidorScreenState extends State<RegistroRepartidorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _marcaController = TextEditingController();
  final _placaController = TextEditingController();

  String _tipoVehiculo = VehiculoConstants.tipos.first;
  bool _ocultarPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<GestionRepartidorViewModel>().limpiar();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _marcaController.dispose();
    _placaController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<GestionRepartidorViewModel>();
    final creado = await viewModel.registrarRepartidor(
      nombre: _nombreController.text.trim(),
      cedula: _cedulaController.text.trim(),
      telefono: _telefonoController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      vehiculoTipo: _tipoVehiculo,
      vehiculoMarca: _marcaController.text.trim(),
      vehiculoPlaca: _placaController.text.trim().toUpperCase(),
    );

    if (creado && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Repartidor ${_nombreController.text.trim()} registrado. '
            'Ya puede iniciar sesión con su correo.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GestionRepartidorViewModel>();
    final cargando = viewModel.state == GestionRepartidorState.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Repartidor')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _TituloSeccion('Datos personales', Icons.person),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => Validadores.requerido(v, 'Ingresa el nombre del repartidor'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cedulaController,
              decoration: const InputDecoration(
                labelText: 'Cédula (10 dígitos)',
                prefixIcon: Icon(Icons.fingerprint),
                helperText: 'Se verificará que no exista otro repartidor con esta cédula',
              ),
              keyboardType: TextInputType.number,
              maxLength: 10,
              validator: Validadores.cedulaEcuatoriana,
            ),
            const SizedBox(height: 12),
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
                labelText: 'Correo electrónico (para iniciar sesión)',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: Validadores.email,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña inicial',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _ocultarPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _ocultarPassword = !_ocultarPassword);
                  },
                ),
              ),
              obscureText: _ocultarPassword,
              validator: Validadores.password,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
                prefixIcon: Icon(Icons.lock_reset),
              ),
              obscureText: _ocultarPassword,
              validator: (v) =>
                  v != _passwordController.text ? 'Las contraseñas no coinciden' : null,
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
              icon: const Icon(Icons.person_add),
              label: cargando
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Registrar repartidor'),
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
