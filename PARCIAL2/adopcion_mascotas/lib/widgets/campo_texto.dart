import 'package:flutter/material.dart';

class CampoTexto extends StatelessWidget {
  final TextEditingController ctrl;
  final String   label;
  final IconData icon;
  final bool     requerido;
  final bool     esNumero;
  final bool     esTelefono;
  final bool     esUrl;
  final bool     soloLetras;
  final int?     minVal;
  final int?     maxVal;
  final int      maxLines;

  const CampoTexto({
    super.key,
    required this.ctrl,
    required this.label,
    required this.icon,
    this.requerido  = true,
    this.esNumero   = false,
    this.esTelefono = false,
    this.esUrl      = false,
    this.soloLetras = false,
    this.minVal,
    this.maxVal,
    this.maxLines   = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: (esNumero || esTelefono) ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Ingresa $label...',
            prefixIcon: Icon(icon, color: Colors.teal),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.teal, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
          ),
          validator: (v) {
            final value = v?.trim() ?? '';
            
            if (requerido && value.isEmpty) {
              return 'Este campo es obligatorio';
            }
            
            if (value.isEmpty) return null;

            if (esNumero) {
              final n = int.tryParse(value);
              if (n == null) return 'Ingresa un número válido';
              if (minVal != null && n < minVal!) return 'Mínimo $minVal';
              if (maxVal != null && n > maxVal!) return 'Máximo $maxVal';
            }

            if (esTelefono) {
              if (value.length != 10 || int.tryParse(value) == null) {
                return 'El teléfono debe tener 10 dígitos';
              }
            }

            if (soloLetras) {
              if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
                return 'Solo se permiten letras';
              }
            }

            if (esUrl) {
              final uri = Uri.tryParse(value);
              if (uri == null || !uri.hasAbsolutePath || !value.startsWith('http')) {
                return 'Ingresa una URL válida (http/https)';
              }
            }

            return null;
          },
        ),
      ],
    );
  }
}
