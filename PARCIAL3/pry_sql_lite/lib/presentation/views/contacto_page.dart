import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/contacto.dart';
import '../../themes/app_styles.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_icon.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../providers/contacto_provider.dart';

import 'contactos_list_page.dart';

class ContactoPage extends ConsumerStatefulWidget {
  const ContactoPage({super.key});

  @override
  ConsumerState<ContactoPage> createState() => _ContactoPageState();
}

class _ContactoPageState extends ConsumerState<ContactoPage> {
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();
  final correoController = TextEditingController();

  int? contactoEditandoId;

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    correoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactos = ref.watch(contactoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Contactos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactosListPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomText(
              text: contactoEditandoId == null
                  ? 'Nuevo contacto'
                  : 'Editar contacto',
              style: AppStyles.title,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Nombre',
              controller: nombreController,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              label: 'Teléfono',
              controller: telefonoController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              label: 'Correo',
              controller: correoController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            CustomElevatedButton(
              text: contactoEditandoId == null ? 'Guardar' : 'Actualizar',
              onPressed: guardarOActualizar,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: contactos.isEmpty
                  ? const Center(
                child: CustomText(
                  text: 'No existen contactos registrados',
                ),
              )
                  : ListView.builder(
                itemCount: contactos.length,
                itemBuilder: (context, index) {
                  final contacto = contactos[index];

                  return CustomCard(
                    child: ListTile(
                      leading: const CustomIcon(
                        icon: Icons.person,
                      ),
                      title: CustomText(
                        text: contacto.nombre,
                        style: AppStyles.subtitle,
                      ),
                      subtitle: CustomText(
                        text: '${contacto.telefono}${contacto.correo}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const CustomIcon(
                              icon: Icons.edit,
                            ),
                            onPressed: () {
                              cargarParaEditar(contacto);
                            },
                          ),
                          IconButton(
                            icon: const CustomIcon(
                              icon: Icons.delete,
                            ),
                            onPressed: () {
                              ref
                                  .read(
                                contactoProvider.notifier,
                              )
                                  .eliminarContactos(contacto.id!);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void guardarOActualizar() {
    final nombre = nombreController.text.trim();
    final telefono = telefonoController.text.trim();
    final correo = correoController.text.trim();

    if (nombre.isEmpty || telefono.isEmpty || correo.isEmpty) {
      return;
    }

    if (contactoEditandoId == null) {
      ref.read(contactoProvider.notifier).agregarContactos(
        nombre,
        telefono,
        correo,
      );
    } else {
      ref.read(contactoProvider.notifier).actualizarContactos(
        contactoEditandoId!,
        nombre,
        telefono,
        correo,
      );
    }

    limpiarFormulario();
  }

  void cargarParaEditar(Contacto contacto) {
    setState(() {
      contactoEditandoId = contacto.id;
      nombreController.text = contacto.nombre;
      telefonoController.text = contacto.telefono;
      correoController.text = contacto.correo;
    });
  }

  void limpiarFormulario() {
    setState(() {
      contactoEditandoId = null;
      nombreController.clear();
      telefonoController.clear();
      correoController.clear();
    });
  }
}
