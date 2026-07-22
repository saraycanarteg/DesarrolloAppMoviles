import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/contacto.dart';

class PdfGenerator {
  static Future<void> generateContactReport(List<Contacto> contactos) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Reporte de Contactos', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.TableHelper.fromTextArray(
            headers: ['Nombre', 'Teléfono', 'Correo'],
            data: contactos.map((c) => [c.nombre, c.telefono, c.correo]).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
