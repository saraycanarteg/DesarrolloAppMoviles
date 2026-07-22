import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/contacto.dart';
import '../providers/contacto_provider.dart';
import '../utils/pdf_generator.dart';

class ContactosListPage extends ConsumerStatefulWidget {
  const ContactosListPage({super.key});

  @override
  ConsumerState<ContactosListPage> createState() => _ContactosListPageState();
}

class _ContactosListPageState extends ConsumerState<ContactosListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final contactos = ref.watch(contactoProvider);

    // Filtrar y Ordenar Alfabéticamente
    List<Contacto> filteredContactos = contactos
        .where((c) =>
            c.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.telefono.contains(_searchQuery))
        .toList();

    filteredContactos.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Contactos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => PdfGenerator.generateContactReport(filteredContactos),
            tooltip: 'Descargar PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar contacto',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: filteredContactos.isEmpty
                ? const Center(child: Text('No se encontraron contactos'))
                : ListView.builder(
                    itemCount: filteredContactos.length,
                    itemBuilder: (context, index) {
                      final contacto = filteredContactos[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(contacto.nombre),
                        subtitle: Text(contacto.telefono),
                        trailing: IconButton(
                          icon: const Icon(Icons.call, color: Colors.green),
                          onPressed: () => _makePhoneCall(contacto.telefono),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo realizar la llamada')),
      );
    }
  }
}
