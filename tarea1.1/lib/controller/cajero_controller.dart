import 'package:deber_p1/model/cajero_model.dart';

class CajeroController {
  String procesar (String productosIngresados){
    try{
      final precios = productosIngresados.split(',').map((e) => double.parse(e.trim())).toList();
      final resultado = CajeroModel.calcular(precios);

      return '''
      Total a pagar: \$ ${resultado.totalCliente.toStringAsFixed(2)}
      Acumuladoo del día: \$ ${resultado.totalDia.toStringAsFixed(2)}
      ''';
    }catch(e){
      return 'Ingrese valores en el formato: 10, 20, 30';
    }
  }
}