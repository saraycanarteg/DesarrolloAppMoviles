class CantidadModel {
  final List<double> cantidades;

  CantidadModel(this.cantidades);

  int get contarCeros {
    return cantidades.where((num) => num == 0).length;
  }

  int get contarNegativos {
    return cantidades.where((num) => num < 0).length;
  }

  int get contarPositivos {
    return cantidades.where((num) => num > 0).length;
  }

  int get total => cantidades.length;

  Map<String, dynamic> obtenerResultados() {
    return {
      'ceros': contarCeros,
      'negativos': contarNegativos,
      'positivos': contarPositivos,
      'total': total,
    };
  }
}
