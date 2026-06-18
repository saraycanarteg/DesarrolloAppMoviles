import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mascota.dart';
import '../viewmodels/mascota_viewmodel.dart';
import '../widgets/campo_texto.dart';

class MascotaFormPage extends StatefulWidget {
  final Mascota? mascotaEditar;
  const MascotaFormPage({super.key, this.mascotaEditar});

  @override
  State<MascotaFormPage> createState() => _MascotaFormPageState();
}

class _MascotaFormPageState extends State<MascotaFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreCtrl;
  late TextEditingController _razaCtrl;
  late TextEditingController _edadCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _imgCtrl;

  String _especie = 'Perro';
  final List<String> _especies = ['Perro', 'Gato', 'Conejo', 'Ave', 'Otro'];

  bool get _esEdicion => widget.mascotaEditar != null;

  @override
  void initState() {
    super.initState();
    final m = widget.mascotaEditar;
    _nombreCtrl = TextEditingController(text: m?.nombre ?? '');
    _razaCtrl   = TextEditingController(text: m?.raza ?? '');
    _edadCtrl   = TextEditingController(text: m?.edad.toString() ?? '');
    _descCtrl   = TextEditingController(text: m?.descripcion ?? '');
    _imgCtrl    = TextEditingController(text: m?.imagenUrl ?? '');
    if (m != null) _especie = m.especie;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _razaCtrl.dispose();
    _edadCtrl.dispose();
    _descCtrl.dispose();
    _imgCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = Provider.of<MascotaViewmodel>(context, listen: false);

    final mascota = Mascota(
      id:          widget.mascotaEditar?.id,
      nombre:      _nombreCtrl.text.trim(),
      especie:     _especie,
      raza:        _razaCtrl.text.trim(),
      edad:        int.parse(_edadCtrl.text.trim()),
      descripcion: _descCtrl.text.trim(),
      imagenUrl:   _imgCtrl.text.trim().isEmpty ? null : _imgCtrl.text.trim(),
    );

    bool ok;
    if (_esEdicion) {
      ok = await vm.actualizarMascota(widget.mascotaEditar!.id!, mascota);
    } else {
      ok = await vm.crearMascota(mascota);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? (_esEdicion ? ' Mascota actualizada' : ' Mascota registrada')
            : '${vm.errorMessage}'),
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
        title: Text(
          _esEdicion ? 'Editar mascota' : 'Nueva mascota',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.pets,
                      size: 40, color: Colors.teal),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Información básica',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              CampoTexto(
                  ctrl: _nombreCtrl,
                  label: 'Nombre de la mascota',
                  icon: Icons.badge_outlined),
              const SizedBox(height: 20),
              const Text(
                'Especie',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _especie,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category_outlined, color: Colors.teal),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _especies
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _especie = v!),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CampoTexto(
                        ctrl: _razaCtrl,
                        label: 'Raza',
                        icon: Icons.pets_outlined,
                        soloLetras: true),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CampoTexto(
                      ctrl: _edadCtrl,
                      label: 'Edad',
                      icon: Icons.cake_outlined,
                      esNumero: true,
                      minVal: 0,
                      maxVal: 100,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Detalles adicionales',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              CampoTexto(
                ctrl: _descCtrl,
                label: 'Descripción',
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              CampoTexto(
                ctrl: _imgCtrl,
                label: 'URL de la foto',
                icon: Icons.link_outlined,
                requerido: false,
                esUrl: true,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    _esEdicion ? 'Actualizar mascota' : 'Guardar mascota',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
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