import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mascota.dart';
import '../viewmodels/mascota_viewmodel.dart';
import 'mascota_form_page.dart';
import 'solicitud_form_page.dart';

class DetalleMascotaPage extends StatelessWidget {
  final Mascota mascota;
  const DetalleMascotaPage({super.key, required this.mascota});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MascotaViewmodel>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.teal),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.teal),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MascotaFormPage(mascotaEditar: mascota),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmarEliminar(context, vm),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen / hero
                Hero(
                  tag: 'mascota-${mascota.id}',
                  child: Container(
                    width: double.infinity,
                    height: 400,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      child: mascota.imagenUrl != null
                          ? Image.network(
                              mascota.imagenUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.teal.withOpacity(0.1),
                              child: const Icon(Icons.pets,
                                  size: 100, color: Colors.teal),
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mascota.nombre,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 16, color: Colors.teal),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Refugio Local',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: mascota.adoptada
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              mascota.adoptada ? 'Adoptada' : 'Disponible',
                              style: TextStyle(
                                color: mascota.adoptada
                                    ? Colors.orange
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoChip(
                              Icons.category, 'Especie', mascota.especie),
                          _buildInfoChip(Icons.pets, 'Raza', mascota.raza),
                          _buildInfoChip(
                              Icons.cake, 'Edad', '${mascota.edad} años'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Sobre mí',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        mascota.descripcion,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!mascota.adoptada)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SolicitudFormPage(mascota: mascota),
                    ),
                  ),
                  icon: const Icon(Icons.favorite),
                  label: const Text(
                    'Solicitar adopción',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.teal, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String valor) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Text('$label: ',
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.grey)),
        Text(valor),
      ],
    ),
  );

  void _confirmarEliminar(BuildContext context, MascotaViewmodel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar mascota'),
        content: Text('¿Deseas eliminar a ${mascota.nombre}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final ok = await vm.eliminarMascota(mascota.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok
                      ? ' Mascota eliminada'
                      : ' ${vm.errorMessage}'),
                  behavior: SnackBarBehavior.floating,
                ));
                if (ok) Navigator.pop(context);
              }
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}