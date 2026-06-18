import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/luz_controller.dart';
import '../providers/luz_provider.dart';
import '../widgets/luz_gauge.dart';
import '../widgets/luz_info_card.dart';

class LuzView extends StatelessWidget {
  const LuzView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LuzProvider>(context);
    final controller = LuzController(provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detector de Luz"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gauge central
            if (provider.luzActual != null) ...[
              LuzGauge(
                lux: provider.luzActual!.lux,
                color: controller.obtenerColorEstado(provider.luzActual!.estado),
              ),
              const SizedBox(height: 8),
              Text(
                "Luz detectada: ${provider.luzActual!.lux} lux",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              LuzInfoCard(
                luz: provider.luzActual!,
                controller: controller,
              ),
            ] else ...[
              const SizedBox(height: 60),
              Icon(Icons.light_mode, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 20),
              Text(
                provider.monitoreando
                    ? "Esperando datos del sensor..."
                    : "Presiona el botón para iniciar\nel monitoreo de luz ambiental.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.monitoreando
            ? () => controller.detenerMonitoreo(context)
            : () => controller.iniciarMonitoreo(context),
        backgroundColor: provider.monitoreando ? Colors.red : Colors.deepPurple,
        icon: Icon(provider.monitoreando ? Icons.stop : Icons.sensors),
        label: Text(provider.monitoreando ? "Detener" : "Iniciar"),
      ),
    );
  }
}
