import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/solicitud_viewmodel.dart';

class SolicitudesPage extends StatefulWidget {
  const SolicitudesPage({super.key});

  @override
  State<SolicitudesPage> createState() => _SolicitudesPageState();
}

class _SolicitudesPageState extends State<SolicitudesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SolicitudViewmodel>(context, listen: false)
          .cargarSolicitudes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SolicitudViewmodel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.teal,
                Colors.tealAccent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: const [
            Icon(Icons.assignment_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Solicitudes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: vm.cargarSolicitudes,
          ),
        ],
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.solicitudes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.inbox_outlined,
                            size: 80, color: Colors.teal.withValues(alpha: 0.2)),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Bandeja vacía',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aún no has recibido solicitudes de adopción.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: vm.solicitudes.length,
                  itemBuilder: (context, i) {
                    final sol = vm.solicitudes[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: sol.aprobada
                                              ? Colors.green.withValues(alpha: 0.1)
                                              : Colors.teal.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Icon(
                                          sol.aprobada
                                              ? Icons.verified_rounded
                                              : Icons.pending_actions_rounded,
                                          color: sol.aprobada
                                              ? Colors.green
                                              : Colors.teal,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sol.nombreSolicitante,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            Text(
                                              'Para: ${sol.mascota?.nombre ?? "Mascota"}',
                                              style: TextStyle(
                                                color: Colors.teal[700],
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.phone_iphone_rounded,
                                                size: 16, color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Text(
                                              sol.telefono,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          sol.motivo,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!sol.aprobada)
                              Container(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () async {
                                          final ok = await vm
                                              .eliminarSolicitud(sol.id!);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(ok
                                                  ? 'Solicitud rechazada'
                                                  : (vm.errorMessage ?? 'Error')),
                                              behavior: SnackBarBehavior.floating,
                                            ));
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red[400],
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        child: const Text('Rechazar',
                                            style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          final ok = await vm
                                              .aprobarSolicitud(sol.id!);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(ok
                                                  ? 'Solicitud aprobada'
                                                  : (vm.errorMessage ?? 'Error')),
                                              behavior: SnackBarBehavior.floating,
                                            ));
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('Aprobar',
                                            style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.05),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        color: Colors.green, size: 16),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Adopción concretada',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 20, color: Colors.grey),
                                      onPressed: () async {
                                        final ok =
                                            await vm.eliminarSolicitud(sol.id!);
                                        if (context.mounted && ok) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text('Registro eliminado'),
                                            behavior: SnackBarBehavior.floating,
                                          ));
                                        }
                                      },
                                    )
                                  ],
                                ),
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