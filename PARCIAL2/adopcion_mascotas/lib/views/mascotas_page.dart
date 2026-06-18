import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/mascota_viewmodel.dart';
import '../widgets/mascota_card.dart';
import 'mascota_form_page.dart';
import 'detalle_mascota_page.dart';

class MascotasPage extends StatefulWidget {
  const MascotasPage({super.key});

  @override
  State<MascotasPage> createState() => _MascotasPageState();
}

class _MascotasPageState extends State<MascotasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MascotaViewmodel>(context, listen: false).cargarMascotas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MascotaViewmodel>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.teal,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(
                  left: 16,
                  bottom: 8,
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.pets,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Mascotas en adopción',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.teal, Colors.tealAccent],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => vm.cargarMascotas(),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Encuentra a tu mejor amigo',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cada huellita merece una familia',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          vm.loading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : vm.mascotas.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.pets,
                                  size: 64, color: Colors.teal.withValues(alpha: 0.2)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay mascotas registradas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '¡Pronto llegarán nuevos amigos!',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final mascota = vm.mascotas[i];
                            return MascotaCard(
                              mascota: mascota,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetalleMascotaPage(mascota: mascota),
                                ),
                              ),
                            );
                          },
                          childCount: vm.mascotas.length,
                        ),
                      ),
                    ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MascotaFormPage()),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
        elevation: 4,
      ),
    );
  }
}