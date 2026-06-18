class Articulo {
  final double precio;

  Articulo(this.precio);

  // Calcula el descuento basado en el precio
  double calcularDescuento() {
    if (precio >= 200) {
      return precio * 0.15; // 15% descuento
    } else if (precio > 100 && precio < 200) {
      return precio * 0.12; // 12% descuento
    } else {
      return precio * 0.10; // 10% descuento
    }
  }

  // Obtiene el porcentaje de descuento
  int obtenerPorcentajeDescuento() {
    if (precio >= 200) {
      return 15;
    } else if (precio > 100 && precio < 200) {
      return 12;
    } else {
      return 10;
    }
  }

  // Calcula el precio final después del descuento
  double calcularPrecioFinal() {
    return precio - calcularDescuento();
  }
}

class CantidadModel {
  final List<double> precios;

  CantidadModel(this.precios);

  // Obtiene lista de artículos con sus descuentos
  List<Articulo> get articulos => precios.map((p) => Articulo(p)).toList();

  // Calcula el costo total sin descuentos
  double get costoTotal {
    return precios.fold(0.0, (sum, precio) => sum + precio);
  }

  // Calcula el descuento total
  double get descuentoTotal {
    return articulos.fold(0.0, (sum, articulo) => sum + articulo.calcularDescuento());
  }

  // Calcula el total a pagar después de descuentos
  double get totalAPagar {
    return costoTotal - descuentoTotal;
  }

  // Obtiene resultados detallados por artículo
  List<Map<String, dynamic>> obtenerDetalleArticulos() {
    return articulos.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final articulo = entry.value;
      return {
        'numero': index,
        'precio': articulo.precio,
        'porcentajeDescuento': articulo.obtenerPorcentajeDescuento(),
        'descuento': articulo.calcularDescuento(),
        'precioFinal': articulo.calcularPrecioFinal(),
      };
    }).toList();
  }
}
