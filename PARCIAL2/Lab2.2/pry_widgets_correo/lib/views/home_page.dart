import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/correo_viewmodel.dart';
import '../widgets/gmail_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios del ViewModel para poder actualizar la UI según el modo (real o simulado)
    final vm = Provider.of<CorreoViewModel>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Prototipo de Widget Gmail',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.red[700],
        elevation: 2,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(vm.esModoReal ? Icons.sync : Icons.refresh, color: Colors.white),
            tooltip: vm.esModoReal ? 'Sincronizar Gmail' : 'Simular Recibir Correo',
            onPressed: () async {
              if (vm.esModoReal) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sincronizando con Gmail...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                await vm.cargarCorreosDesdeGmail();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  if (vm.errorMsg != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(vm.errorMsg!),
                        backgroundColor: Colors.red[700],
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bandeja de entrada de Gmail actualizada'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } else {
                vm.recibirNuevoCorreo();
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nuevo correo simulado recibido en el buzón'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Integración de nuestro widget tipo Gmail
            GmailWidget(
              onBuscarTap: () {
                // Diálogo instructivo sobre la búsqueda
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Row(
                      children: [
                        Icon(Icons.search, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        const Text('Búsqueda Interactiva'),
                      ],
                    ),
                    content: const Text(
                      '¡La búsqueda ya es funcional!\n\nEscribe directamente en el buscador superior del widget para filtrar los correos en tiempo real por asunto, remitente o cuerpo.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Entendido'),
                      ),
                    ],
                  ),
                );
              },
              
              onRedactarTap: () {
                // Abre el modal/formulario real de redacción de correo
                _mostrarFormularioRedactar(context, vm);
              },
              
              onNoLeidosTap: () {
                vm.marcarTodosLeidos();
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Todos los correos han sido marcados como leídos'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: vm.esModoReal
          ? FloatingActionButton.extended(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sincronizando con Gmail...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                await vm.cargarCorreosDesdeGmail();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  if (vm.errorMsg != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(vm.errorMsg!),
                        backgroundColor: Colors.red[700],
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bandeja de entrada de Gmail actualizada'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar Gmail'),
            )
          : FloatingActionButton.extended(
              onPressed: () {
                vm.recibirNuevoCorreo();
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recibiendo nuevo correo simulado...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Simular Recibido'),
            ),
    );
  }

  // Muestra un BottomSheet o Dialog interactivo para redactar un nuevo correo
  void _mostrarFormularioRedactar(BuildContext context, CorreoViewModel vm) {
    final formKey = GlobalKey<FormState>();
    String destinatario = '';
    String asunto = '';
    String cuerpo = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite subir el modal con el teclado
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Ajuste para el teclado
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        vm.esModoReal ? 'Redactar Correo Real' : 'Redactar Correo (Simulado)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  
                  // Campo "Para" con Autocompletado de Correos Recomendados
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      final List<String> listadeCorreosRecomendados = [
                        'profesor@moviles.edu.ec',
                        'soporte@google.com',
                        'contacto@netflix.com',
                        'alertas@github.com',
                        'info@spotify.com',
                        'estudiante@correo.com',
                      ];
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return listadeCorreosRecomendados.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      destinatario = selection;
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Para (Destinatario)',
                          hintText: 'ejemplo@correo.com',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa un destinatario';
                          }
                          // Expresión regular para validar formato de correo electrónico
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Ingresa un correo electrónico válido (ejemplo@correo.com)';
                          }
                          return null;
                        },
                        onSaved: (value) => destinatario = value ?? '',
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Asunto',
                      hintText: 'Asunto del correo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa un asunto';
                      }
                      return null;
                    },
                    onSaved: (value) => asunto = value ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Cuerpo del Correo',
                      hintText: 'Escribe tu mensaje aquí...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor escribe el contenido del mensaje';
                      }
                      return null;
                    },
                    onSaved: (value) => cuerpo = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          
                          // Mostrar SnackBar inicial de progreso
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Procesando envío de correo...'),
                              duration: Duration(seconds: 1),
                            ),
                          );

                          final exito = await vm.redactarNuevoCorreo(destinatario, asunto, cuerpo);
                          
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            if (exito) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(vm.esModoReal 
                                      ? 'Correo enviado exitosamente vía Gmail' 
                                      : 'Correo enviado a "$destinatario" (Simulado)'),
                                  backgroundColor: Colors.green[700],
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(vm.errorMsg ?? 'Error al enviar el correo'),
                                  backgroundColor: Colors.red[700],
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send),
                          const SizedBox(width: 8),
                          Text(
                            vm.esModoReal ? 'Enviar Correo Real' : 'Simular Envío',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
