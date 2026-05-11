# 📱 Servicios Básicos - Aplicación 1

## Descripción
Aplicación Flutter para calcular pagos de servicios básicos siguiendo el patrón **MVC** y **Atomic Design**.

## 🎯 Especificaciones Cumplidas

### ✅ Requisitos del TXT
- ✓ Registro de datos del cliente (nombre, cédula, dirección)
- ✓ Selección de tipo de servicio (5 opciones)
- ✓ Ingreso de consumo o valor base
- ✓ Aplicación de tarifa según servicio
- ✓ Cálculo de subtotal
- ✓ Aplicación de descuentos y recargos
- ✓ Cálculo total a pagar
- ✓ Generación de resumen del pago

### ✅ Controles Obligatorios
- ✓ Cajas de texto (TextFields)
- ✓ Labels (CustomLabel)
- ✓ Botones (CustomButton)
- ✓ CheckBox (CustomCheckbox)
- ✓ RadioButton (CustomRadio)

### ✅ Requisitos Técnicos
- ✓ Patrón MVC (Model-View-Controller)
- ✓ Atomic Design (Atoms, Molecules, Organisms)
- ✓ Rutas en Flutter (push, pop, pushNamed)
- ✓ Separación de carpetas (models, controllers, views, widgets)
- ✓ Interfaz clara y funcional

## 📂 Estructura del Proyecto

```
servicios_basicos/
├── lib/
│   ├── main.dart                    # Punto de entrada
│   ├── model/
│   │   └── servicio_model.dart      # Modelos de datos
│   ├── controller/
│   │   └── servicio_controller.dart # Lógica de negocio
│   ├── view/
│   │   ├── home_servicios_view.dart
│   │   └── resultado_servicios_view.dart
│   └── widgets/
│       ├── atoms/                   # Componentes básicos
│       ├── molecules/               # Composiciones
│       └── organisms/               # Formularios
├── pubspec.yaml
└── pubspec.lock
```

## 🚀 Cómo Ejecutar

```bash
# Obtener dependencias
flutter pub get

# Ejecutar la app
flutter run
```

## 💡 Funcionalidades

1. **Registro de Cliente**: Nombre, Cédula, Dirección
2. **Selección de Servicio**: 5 tipos con tarifas predefinidas
3. **Cálculo de Pago**: Consumo × Tarifa con descuentos/recargos
4. **Comprobante**: Resumen detallado del pago

## 🎨 Diseño

- Material Design 3
- Tema azul (#2196F3)
- Componentes Atomic Design

---

**Desarrollado para la Tarea 1.2**
