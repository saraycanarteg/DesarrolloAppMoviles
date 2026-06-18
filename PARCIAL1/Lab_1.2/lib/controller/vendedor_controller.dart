import '../model/vendedor_model.dart';

class VendedorController {
  Map<String, String> calcularResultados(String s1, String s2, String s3) {
    if (s1.isEmpty || s2.isEmpty || s3.isEmpty) {
      return {"error": "Ingrese todos los valores"};
    }

    final v1 = double.tryParse(s1);
    final v2 = double.tryParse(s2);
    final v3 = double.tryParse(s3);

    if (v1 == null || v2 == null || v3 == null) {
      return {"error": "Ingrese números válidos"};
    }

    final vendedor = VendedorModel(v1, v2, v3);
    
    double sueldo = vendedor.calcularSueldo();
    double subtotal = vendedor.calcularSubtotal();
    double descuento = vendedor.calcularDescuento();
    double subtotalConDescuento = subtotal - descuento;
    double iva = vendedor.calcularIVA(subtotalConDescuento);
    double total = vendedor.calcularTotalFactura();

    return {
      "sueldo": sueldo.toStringAsFixed(2),
      "subtotal": subtotal.toStringAsFixed(2),
      "descuento": descuento.toStringAsFixed(2),
      "iva": iva.toStringAsFixed(2),
      "total": total.toStringAsFixed(2),
    };
  }
}
