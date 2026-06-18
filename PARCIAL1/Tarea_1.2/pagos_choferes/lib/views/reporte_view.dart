import 'package:flutter/material.dart';

import '../models/chofer_models.dart';
import '../models/reportes_models.dart';

class ReporteView extends StatelessWidget {

  final List<ChoferModels> choferes;

  const ReporteView({
    super.key,
    required this.choferes,
  });

  @override
  Widget build(BuildContext context) {

    final reporte = ReportesModels(
      choferes: choferes,
    );
    final mayorLunes = reporte.obtenerMayorLunes();
    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text('Reporte General'),
        centerTitle: true,
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            Container(

              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                  )
                ],
              ),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Text(
                    'Resumen General',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Total empresa: \$${reporte.calcularTotalGeneral().toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    mayorLunes != null
                        ? 'Mayor horas lunes: ${mayorLunes.nombre} '
                        '(${mayorLunes.horasPorDia[0]} horas)'
                        : 'No hay choferes registrados',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(

              child: ListView.builder(

                itemCount: choferes.length,

                itemBuilder: (context, index) {

                  final chofer = choferes[index];

                  return Card(

                    elevation: 4,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Padding(

                      padding: const EdgeInsets.all(16),

                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Text(
                            chofer.nombre,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'Horas semanales: ${chofer.calcularTotalHoras()}',
                          ),

                          Text(
                            'Sueldo semanal: \$${chofer.calcularSueldoSemanal().toStringAsFixed(2)}',
                          ),

                          Text(
                            'Jornada: ${chofer.tipoJornada}',
                          ),

                          Text(
                            'Activo: ${chofer.activo ? "Sí" : "No"}',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}