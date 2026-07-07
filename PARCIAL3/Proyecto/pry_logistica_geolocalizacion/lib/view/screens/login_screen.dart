import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../model/domain/entities/usuario_entity.dart';
import 'home_admin_screen.dart';
import 'home_repartidor_screen.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<AuthViewModel>();
      await viewModel.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
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
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Consumer<AuthViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                      onPressed: viewModel.state == AuthState.loading ? null : _submitLogin,
                      child: viewModel.state == AuthState.loading
                          ? const CircularProgressIndicator()
                          : const Text('Entrar'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegistroScreen()),
                      );
                    },
                    child: const Text('¿No tienes cuenta? Regístrate aquí'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
