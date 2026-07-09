import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validadores.dart';
import '../../model/domain/entities/repartidor_entity.dart';
import '../../viewmodel/auth_viewmodel.dart';

/// Pantalla "Mi Perfil" del repartidor: muestra la información registrada
/// por el administrador (solo lectura) y permite cambiar la contraseña.
/// Los datos personales solo los modifica el administrador.
class MiPerfilScreen extends StatefulWidget {
  final RepartidorEntity repartidor;

  const MiPerfilScreen({super.key, required this.repartidor});

  @override
  State<MiPerfilScreen> createState() => _MiPerfilScreenState();
}

class _MiPerfilScreenState extends State<MiPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordActualController = TextEditingController();
  final _passwordNuevaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _ocultarPassword = true;
  String? _errorCambio;

  @override
  void dispose() {
    _passwordActualController.dispose();
    _passwordNuevaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _cambiarPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<AuthViewModel>();
    final error = await viewModel.cambiarPassword(
      passwordActual: _passwordActualController.text,
      passwordNueva: _passwordNuevaController.text,
    );

    if (!mounted) return;
    if (error == null) {
      _passwordActualController.clear();
      _passwordNuevaController.clear();
      _confirmarController.clear();
      setState(() => _errorCambio = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente.')),
      );
    } else {
      setState(() => _errorCambio = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final cargando = authViewModel.cambiandoPassword;
    final r = widget.repartidor;
    final email = authViewModel.sesion?.usuario.email ?? r.email;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.colorPrimario,
                        child: Icon(Icons.sports_motorsports,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          r.nombre,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _FilaPerfil(
                      icono: Icons.fingerprint,
                      etiqueta: 'Cédula',
                      valor: r.cedula ?? 'N/D'),
                  _FilaPerfil(
                      icono: Icons.phone_android,
                      etiqueta: 'Teléfono',
                      valor: r.telefono ?? 'N/D'),
                  _FilaPerfil(
                      icono: Icons.email_outlined,
                      etiqueta: 'Correo',
                      valor: email ?? 'N/D'),
                  _FilaPerfil(
                    icono: Icons.commute,
                    etiqueta: 'Vehículo',
                    valor: r.vehiculoTipo != null
                        ? '${r.vehiculoTipo} ${r.vehiculoMarca ?? ''} — placa ${r.vehiculoPlaca ?? 'N/D'}'
                        : r.vehiculo ?? 'Sin registrar',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Si deseas modificar tus datos personales registrados, '
                      'contacta al administrador.',
                      style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.lock_outline,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Cambiar contraseña',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _passwordActualController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña actual',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
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
                  controller: _passwordNuevaController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña nueva',
                    prefixIcon: Icon(Icons.lock_reset),
                  ),
                  obscureText: _ocultarPassword,
                  validator: (v) {
                    final error = Validadores.password(v);
                    if (error != null) return error;
                    if (v == _passwordActualController.text) {
                      return 'La contraseña nueva debe ser distinta a la actual';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmarController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar contraseña nueva',
                    prefixIcon: Icon(Icons.check_circle_outline),
                  ),
                  obscureText: _ocultarPassword,
                  validator: (v) => v != _passwordNuevaController.text
                      ? 'Las contraseñas no coinciden'
                      : null,
                ),
                const SizedBox(height: 16),
                if (_errorCambio != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _errorCambio!,
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
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Actualizar contraseña'),
                  onPressed: cargando ? null : _cambiarPassword,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FilaPerfil extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _FilaPerfil({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              etiqueta,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
