import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../model/domain/entities/usuario_entity.dart';
import 'home_admin_screen.dart';
import 'home_repartidor_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  RolUsuario _rolSeleccionado = RolUsuario.admin;

  Future<void> _submitRegistro() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<AuthViewModel>();
      await viewModel.registrar(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nombreController.text.trim(),
        _rolSeleccionado,
      );
      
      if (viewModel.state == AuthState.success && mounted) {
        if (viewModel.sesion!.usuario.rol == RolUsuario.admin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeAdminScreen()),
          );
        } else if (viewModel.sesion!.usuario.rol == RolUsuario.repartidor) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeRepartidorScreen(
                repartidor: viewModel.sesion!.repartidor!,
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: Consumer<AuthViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo Electrónico',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu correo';
                        }
                        final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!regex.hasMatch(value)) {
                          return 'El formato del correo es inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar Contraseña',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<RolUsuario>(
                      value: _rolSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Cuenta',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: RolUsuario.admin,
                          child: Text('Administrador'),
                        ),
                        DropdownMenuItem(
                          value: RolUsuario.repartidor,
                          child: Text('Repartidor'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _rolSeleccionado = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (viewModel.state == AuthState.error && viewModel.errorMessage != null)
                      Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: viewModel.state == AuthState.loading ? null : _submitRegistro,
                        child: viewModel.state == AuthState.loading
                            ? const CircularProgressIndicator()
                            : const Text('Registrarse'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('¿Ya tienes cuenta? Inicia sesión aquí'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
