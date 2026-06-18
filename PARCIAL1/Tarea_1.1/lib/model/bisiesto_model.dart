class BisiestoModel {
  final int year;
  final bool esBisiesto;

  BisiestoModel({required this.year, required this.esBisiesto});

  static BisiestoModel calcular(int year) {
    bool esBisiesto;

    // Un año es bisiesto si:
    // - Es múltiplo de 400, OR
    // - Es múltiplo de 4 pero NO es múltiplo de 100
    if (year % 400 == 0) {
      esBisiesto = true;
    } else if (year % 100 == 0) {
      esBisiesto = false;
    } else if (year % 4 == 0) {
      esBisiesto = true;
    } else {
      esBisiesto = false;
    }

    return BisiestoModel(year: year, esBisiesto: esBisiesto);
  }
}
