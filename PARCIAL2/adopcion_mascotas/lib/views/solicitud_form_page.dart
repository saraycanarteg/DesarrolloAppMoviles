import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mascota.dart';
import '../models/solicitud.dart';
import '../viewmodels/solicitud_viewmodel.dart';
import '../widgets/campo_texto.dart';

class SolicitudFormPage extends StatefulWidget {
  final Mascota mascota;
  const SolicitudFormPage({super.key, required this.mascota});

  @override
  State<SolicitudFormPage> createState() => _SolicitudFormPageState();
}

class _SolicitudFormPageState extends State<SolicitudFormPage> {
  final _formKey      = GlobalKey<FormState>();
  final _nombreCtrl   = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _motivoCtrl   = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _motivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = Provider.of<SolicitudViewmodel>(context, listen: false);

    final sol = Solicitud(
      nombreSolicitante: _nombreCtrl.text.trim(),
      telefono:          _telefonoCtrl.text.trim(),
      motivo:            _motivoCtrl.text.trim(),
      mascotaId:         widget.mascota.id!,
    );

    final ok = await vm.crearSolicitud(sol);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? '✅ Solicitud enviada' : '❌ ${vm.errorMessage}'),
        behavior: SnackBarBehavior.floating,
      ));
      if (ok) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Solicitud de Adopción',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info mascota animada/bonita
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: widget.mascota.imagenUrl != null
                            ? DecorationImage(
                                image: NetworkImage(widget.mascota.imagenUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.teal.withValues(alpha: 0.1),
                      ),
                      child: widget.mascota.imagenUrl == null
                          ? const Icon(Icons.pets, color: Colors.teal)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estas solicitando a:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            widget.mascota.nombre,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          Text(
                            '${widget.mascota.especie} • ${widget.mascota.raza}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Tus datos de contacto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              CampoTexto(
                ctrl: _nombreCtrl,
                label: 'Nombre completo',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              CampoTexto(
                ctrl: _telefonoCtrl,
                label: 'Teléfono o celular',
                icon: Icons.phone_outlined,
                esTelefono: true,
              ),
              const SizedBox(height: 32),
              const Text(
                'Cuéntanos más',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              CampoTexto(
                ctrl: _motivoCtrl,
                label: '¿Por qué deseas adoptar?',
                icon: Icons.favorite_border,
                maxLines: 4,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _enviar,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text(
                    'Enviar mi solicitud',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}