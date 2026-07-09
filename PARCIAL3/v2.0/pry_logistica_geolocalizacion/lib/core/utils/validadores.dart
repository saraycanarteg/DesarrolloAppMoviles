/// Validadores de formularios reutilizables (login, pedidos, repartidores).
/// Son funciones puras para poder probarlas sin Flutter ni Firebase.
class Validadores {
  static String? requerido(String? valor, String mensaje) {
    if (valor == null || valor.trim().isEmpty) return mensaje;
    return null;
  }

  static String? email(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Por favor ingresa el correo';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(valor.trim())) {
      return 'El formato del correo es inválido';
    }
    return null;
  }

  static String? password(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Por favor ingresa la contraseña';
    }
    if (valor.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  /// Cédula ecuatoriana: 10 dígitos, código de provincia válido y
  /// dígito verificador según el algoritmo de módulo 10.
  static String? cedulaEcuatoriana(String? valor) {
    final cedula = valor?.trim() ?? '';
    if (cedula.isEmpty) return 'Por favor ingresa la cédula';
    if (!RegExp(r'^\d{10}$').hasMatch(cedula)) {
      return 'La cédula debe tener exactamente 10 dígitos';
    }

    final provincia = int.parse(cedula.substring(0, 2));
    if ((provincia < 1 || provincia > 24) && provincia != 30) {
      return 'El código de provincia de la cédula no es válido';
    }

    final tercerDigito = int.parse(cedula[2]);
    if (tercerDigito > 5) {
      return 'La cédula no corresponde a una persona natural';
    }

    // Dígito verificador: coeficientes 2,1,2,1... sobre los 9 primeros dígitos;
    // si el producto pasa de 9 se le resta 9.
    var suma = 0;
    for (var i = 0; i < 9; i++) {
      var producto = int.parse(cedula[i]) * (i.isEven ? 2 : 1);
      if (producto > 9) producto -= 9;
      suma += producto;
    }
    final verificador = (10 - (suma % 10)) % 10;
    if (verificador != int.parse(cedula[9])) {
      return 'La cédula no es válida (dígito verificador incorrecto)';
    }
    return null;
  }

  /// Teléfono celular ecuatoriano: 09XXXXXXXX o +593XXXXXXXXX.
  static String? telefonoEcuatoriano(String? valor) {
    final telefono = valor?.trim() ?? '';
    if (telefono.isEmpty) return 'Por favor ingresa el teléfono';
    if (!RegExp(r'^(09\d{8}|\+593\d{9})$').hasMatch(telefono)) {
      return 'Formato inválido (ej. 0991234567 o +593991234567)';
    }
    return null;
  }

  /// Placa ecuatoriana: vehículos ABC-1234 / ABC-123, motos AB123C.
  static String? placaEcuatoriana(String? valor) {
    final placa = valor?.trim().toUpperCase() ?? '';
    if (placa.isEmpty) return 'Por favor ingresa la placa';
    final esVehiculo = RegExp(r'^[A-Z]{3}-?\d{3,4}$').hasMatch(placa);
    final esMoto = RegExp(r'^[A-Z]{2}\d{3}[A-Z]$').hasMatch(placa);
    if (!esVehiculo && !esMoto) {
      return 'Formato inválido (ej. ABC-1234 o AB123C)';
    }
    return null;
  }
}
