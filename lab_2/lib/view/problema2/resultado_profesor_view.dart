import 'package:flutter/material.dart';
import '../../widgets/atoms/custom_button.dart';
import '../../widgets/molecules/labeled_data.dart';
import '../../widgets/organisms/result_card.dart';

class ResultadoProfesorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final datos = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final List<String> salarios = datos['salarios'];
    final String salarioAnio6 = datos['salarioAnio6'];

    return Scaffold(
      appBar: AppBar(title: Text("Proyección Salarial")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            ResultCard(
              title: "RESUMEN FINAL",
              icon: Icons.auto_graph,
              children: [
                LabeledData(
                  label: "Salario al cabo de 6 años:", 
                  value: "\$$salarioAnio6",
                  isBold: true, 
                  valueColor: Colors.blueAccent
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.list_alt, color: Colors.blueAccent),
                          SizedBox(width: 10),
                          Text("Desglose Anual", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        itemCount: salarios.length,
                        separatorBuilder: (context, index) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.blueAccent.withOpacity(0.1),
                              child: Text("${index + 1}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                            ),
                            title: Text("Año ${index + 1}", style: TextStyle(fontSize: 14)),
                            trailing: Text("\$${salarios[index]}", style: TextStyle(fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: "REGRESAR", 
              onPressed: () => Navigator.pop(context),
              color: Colors.grey[800],
            ),
          ],
        ),
      ),
    );
  }
}
