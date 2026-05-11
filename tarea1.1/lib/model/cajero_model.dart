class CajeroModel{
  final double totalCliente;
  final double totalDia;

  //constructor
  CajeroModel({required this.totalCliente, required this.totalDia});

  static double acumulado = 0;
  static CajeroModel calcular (List<double> precios){
    final totalCliente = precios.fold(0.0, (x,y)=> x+y);
    acumulado += totalCliente;
    
    return CajeroModel(totalCliente: totalCliente, totalDia: acumulado);
  }

}