class VendedorModel {
  final double venta1, venta2, venta3;
  VendedorModel(this.venta1, this.venta2, this.venta3);

  double get totalVentas => venta1 + venta2 + venta3;

  // Cálculo del sueldo del vendedor
  double calcularSueldo() {
    double sueldoBase = 482.0;
    double comision = totalVentas * 0.12; // 12% de comisión
    return sueldoBase + comision;
  }

  // Cálculos para la factura
  double calcularSubtotal() => totalVentas;

  double calcularDescuento() {
    if (totalVentas > 2000) {
      return totalVentas * 0.20; // 20% de descuento
    }
    return 0.0;
  }

  double calcularIVA(double subtotalConDescuento) {
    return subtotalConDescuento * 0.15; // 15% de IVA
  }

  double calcularTotalFactura() {
    double subtotal = calcularSubtotal();
    double descuento = calcularDescuento();
    double subtotalConDescuento = subtotal - descuento;
    double iva = calcularIVA(subtotalConDescuento);
    return subtotalConDescuento + iva;
  }
}
