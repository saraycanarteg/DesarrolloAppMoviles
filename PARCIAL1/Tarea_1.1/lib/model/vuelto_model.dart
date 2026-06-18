class VueltoModel {
  final double precio;
  final double valorentregado;
  final double vuelto;
  final List<double> monedasCambio;

  VueltoModel({required this.precio, required this.valorentregado, required this.vuelto, required this.monedasCambio});

  static VueltoModel calcularvuelto(double valorentregado, double precio){
    const List<double> monedas = [2.0, 1.0, 0.5, 0.25, 0.1];
    List<double> vueltomonedas =[];
    double vuelto = valorentregado - precio;

    for (var moneda in monedas){
      while (vuelto >= moneda){
        vueltomonedas.add(moneda);
        vuelto -= moneda;
      }
    }

    return VueltoModel(
      precio: precio,
      valorentregado: valorentregado,
      vuelto: valorentregado - precio,
      monedasCambio: vueltomonedas
    );
  }
}