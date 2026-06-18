class PerfectoModel {
  final int numero;
  final bool esPerfecto;
  final List<int> divisores;
  final int sumaDivisores;

  PerfectoModel({
    required this.numero,
    required this.esPerfecto,
    required this.divisores,
    required this.sumaDivisores,
  });

  static PerfectoModel calcular(int numero) {
    List<int> divisores = [];

    // Encontrar todos los divisores (excluyendo el propio número)
    for (int i = 1; i < numero; i++) {
      if (numero % i == 0) {
        divisores.add(i);
      }
    }

    // Sumar los divisores
    int suma = divisores.fold(0, (x, y) => x + y);

    // Un número es perfecto si la suma de sus divisores es igual al número
    bool esPerfecto = suma == numero;

    return PerfectoModel(
      numero: numero,
      esPerfecto: esPerfecto,
      divisores: divisores,
      sumaDivisores: suma,
    );
  }
}
