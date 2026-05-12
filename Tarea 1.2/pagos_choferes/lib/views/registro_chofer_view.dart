import 'package:flutter/material.dart';

import '../controllers/chofer_controller.dart';
import '../models/chofer_models.dart';
import '../widgets/input_chofer.dart';
import '../widgets/checkbox_chofer.dart';
import '../widgets/radiobox_jornada.dart';
import '../widgets/boton_calcular.dart';
import '../widgets/boton_limpiar.dart';
import 'reporte_view.dart';

class RegistroView extends StatefulWidget {
  const RegistroView({super.key});

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {

  final ChoferController controller = ChoferController();

  final TextEditingController txtNombre = TextEditingController();
  final TextEditingController txtSueldo = TextEditingController();

  final List<TextEditingController> txtHoras = List.generate(
    6,
        (_) => TextEditingController(),
  );

  bool activo = false;
  bool bono = false;

  String jornada = 'Diurna';

  String resultado = '';

  List<ChoferModels> choferes = [];

  void registrarChofer() {

    // VALIDAR
    final validacion = controller.validar(
      txtNombre.text,
      txtHoras.map((e) => e.text).toList(),
      txtSueldo.text,
    );

    // SI HAY ERROR
    if(validacion != 'OK'){

      setState(() {
        resultado = validacion;
      });

      return;
    }

    // CREAR OBJETO
    final chofer = controller.crearChofer(
      txtNombre.text,
      txtHoras.map((e) => e.text).toList(),
      txtSueldo.text,
      activo,
      bono,
      jornada,
    );

    // GUARDAR EN LISTA
    setState(() {

      choferes.add(chofer);

      resultado =
      '''
      Chofer registrado correctamente
      
      Nombre: ${chofer.nombre}
      Horas semanales: ${chofer.calcularTotalHoras()}
      Sueldo semanal: \$${chofer.calcularSueldoSemanal().toStringAsFixed(2)}
      
      Choferes registrados: ${choferes.length}
      ''';
    });
  }

  void limpiarCampos() {

    txtNombre.clear();
    txtSueldo.clear();

    for (var txt in txtHoras) {
      txt.clear();
    }

    setState(() {
      activo = false;
      bono = false;
      jornada = 'Diurna';
      resultado = '';
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text('Registro de Choferes'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Container(

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

                children: [

                  const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 20),

                  InputChofer(
                    controller: txtNombre,
                    label: 'Nombre',
                    keyboardType: TextInputType.text,
                  ),

                  InputChofer(
                    controller: txtSueldo,
                    label: 'Sueldo por hora',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 10),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Horas trabajadas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  InputChofer(
                    controller: txtHoras[0],
                    label: 'Lunes',
                    keyboardType: TextInputType.number,
                  ),

                  InputChofer(
                    controller: txtHoras[1],
                    label: 'Martes',
                    keyboardType: TextInputType.number,
                  ),

                  InputChofer(
                    controller: txtHoras[2],
                    label: 'Miércoles',
                    keyboardType: TextInputType.number,
                  ),

                  InputChofer(
                    controller: txtHoras[3],
                    label: 'Jueves',
                    keyboardType: TextInputType.number,
                  ),

                  InputChofer(
                    controller: txtHoras[4],
                    label: 'Viernes',
                    keyboardType: TextInputType.number,
                  ),

                  InputChofer(
                    controller: txtHoras[5],
                    label: 'Sábado',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 10),

                  CheckBoxChofer(
                    value: activo,
                    texto: 'Chofer activo',
                    onChanged: (value) {
                      setState(() {
                        activo = value!;
                      });
                    },
                  ),

                  CheckBoxChofer(
                    value: bono,
                    texto: 'Recibe bono',
                    onChanged: (value) {
                      setState(() {
                        bono = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Jornada',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  RadioboxJornada(
                    value: 'Diurna',
                    groupValue: jornada,
                    texto: 'Diurna',
                    onChanged: (value) {
                      setState(() {
                        jornada = value!;
                      });
                    },
                  ),

                  RadioboxJornada(
                    value: 'Nocturna',
                    groupValue: jornada,
                    texto: 'Nocturna',
                    onChanged: (value) {
                      setState(() {
                        jornada = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  Row(

                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                    children: [

                      BotonCalcular(
                        onPressed: registrarChofer,
                      ),

                      BotonLimpiar(
                        onPressed: limpiarCampos,
                      ),

                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    resultado,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (choferes.isNotEmpty)

                    SizedBox(

                      width: double.infinity,

                      child: ElevatedButton.icon(

                        icon: const Icon(Icons.analytics),

                        label: const Text('Ver Reporte'),

                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),

                        onPressed: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReporteView(
                                choferes: choferes,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}