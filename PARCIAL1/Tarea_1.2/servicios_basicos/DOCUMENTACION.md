# Aplicación 1: Pagos de Servicios Básicos
## Documentación técnica

### Descripción General
Aplicación Flutter para registrar y calcular pagos de servicios básicos, implementando MVC y Atomic Design.

### Estructura del Proyecto

```
servicios_basicos/
├── lib/
│   ├── main.dart                              # Punto de entrada, configuración de rutas
│   ├── model/
│   │   └── servicio_model.dart               # Modelos: ServicioModel, ClienteModel, PagoServicioModel
│   ├── controller/
│   │   └── servicio_controller.dart          # Lógica de negocio: procesarPago(), validaciones
│   ├── view/
│   │   ├── home_servicios_view.dart          # Pantalla principal con formulario
│   │   └── resultado_servicios_view.dart     # Pantalla de resultados/comprobante
│   └── widgets/
│       ├── atoms/                            # Componentes individuales (Atomic Design)
│       │   ├── input_text.dart              # Campo de texto personalizado
│       │   ├── custom_label.dart            # Etiqueta personalizada
│       │   ├── custom_button.dart           # Botón personalizado
│       │   ├── custom_checkbox.dart         # CheckBox personalizado
│       │   └── custom_radio.dart            # RadioButton personalizado
│       ├── molecules/                        # Combinaciones de átomos
│       │   ├── info_cliente.dart            # Sección de datos del cliente
│       │   ├── selector_servicio.dart       # Sección de selección de servicio
│       │   ├── datos_consumo.dart           # Sección de consumo/valor
│       │   ├── opciones_descuento.dart      # Sección de descuentos
│       │   └── opciones_recargo.dart        # Sección de recargos
│       └── organisms/                        # Formularios completos
│           └── formulario_pago.dart         # Formulario completo de pago
├── pubspec.yaml                              # Dependencias del proyecto
└── pubspec.lock                              # Dependencias bloqueadas
```

### Patrones Implementados

#### 1. MVC (Model-View-Controller)
- **Model**: `servicio_model.dart` - Estructuras de datos
- **Controller**: `servicio_controller.dart` - Lógica de negocio y validaciones
- **View**: Carpeta `view/` - Interfaces de usuario

#### 2. Atomic Design
- **Atoms**: Componentes básicos reutilizables (InputText, CustomButton, etc.)
- **Molecules**: Agrupaciones de átomos (InfoCliente, SelectorServicio, etc.)
- **Organisms**: Formularios complejos (FormularioPago)

#### 3. Rutas de navegación
- `/`: HomeServiciosView (pantalla principal)
- `/resultado`: ResultadoServiciosView (pantalla de resultados)

### Funcionalidades Principales

#### 1. Registro de Cliente
- Nombre completo
- Cédula
- Dirección

#### 2. Selección de Servicio
RadioButtons para seleccionar:
- Agua Potable (tarifa: 0.50 por m³)
- Energía Eléctrica (tarifa: 0.15 por kWh)
- Internet y Telefonía (fijo: 25.00)
- TV por Cable (fijo: 20.00)
- Otros Pagos (variable)

#### 3. Entrada de Consumo/Valor
- Campo numérico dinámico según servicio
- Validaciones de valores positivos

#### 4. Opciones de Descuento
- CheckBox para aplicar descuento
- Campo de porcentaje personalizable

#### 5. Opciones de Recargo
- CheckBox para aplicar recargo
- Campo de porcentaje personalizable

#### 6. Cálculo de Pago
- Subtotal = Consumo × Tarifa
- Monto Descuento = Subtotal × (Porcentaje / 100)
- Monto Recargo = Subtotal × (Porcentaje / 100)
- Total = Subtotal - Descuento + Recargo

#### 7. Comprobante de Pago
Muestra resumen detallado con:
- Datos del cliente
- Tipo de servicio
- Consumo/Valor
- Tarifa
- Subtotal
- Descuentos (si aplica)
- Recargos (si aplica)
- Total a pagar
- Fecha y hora

### Controles Utilizados

✓ **Cajas de Texto** (TextFields)
- Nombre, cédula, dirección, consumo, porcentajes

✓ **Labels** (CustomLabel)
- Títulos de secciones y resultados

✓ **Botones** (CustomButton)
- Calcular Pago: procesa el formulario
- Limpiar: reinicia todos los campos
- Volver: regresa a pantalla anterior
- Guardar Comprobante: guarda el resultado

✓ **CheckBox** (CustomCheckbox)
- Aplicar descuento
- Aplicar recargo

✓ **RadioButton** (CustomRadio)
- Selección de tipo de servicio

### Validaciones Implementadas

1. Datos del cliente: Todos los campos requeridos
2. Servicio: Debe estar seleccionado
3. Consumo: Debe ser positivo y numérico
4. Porcentajes: Validados solo si están habilitados
5. Mensajes de error: Mostrados mediante SnackBar

### Estilos y Temas

- **Color primario**: Azul (Colors.blue)
- **Color secundario**: Verde (descuentos)
- **Color de alerta**: Rojo (recargos)
- **Material Design 3**: Activado

### Navegación

```
HomeServiciosView
    ↓ (Calcular)
ResultadoServiciosView
    ↓ (Volver)
HomeServiciosView
```

### Rutas Implementadas

- Push: `Navigator.pushNamed(context, '/resultado', arguments: resultado)`
- Pop: `Navigator.pop(context)`

### Cómo Usar la Aplicación

1. Ingresar datos del cliente (nombre, cédula, dirección)
2. Seleccionar el tipo de servicio mediante RadioButton
3. Ingresar el consumo o valor del servicio
4. Opcionalmente, aplicar descuento o recargo con CheckBox
5. Presionar "Calcular Pago"
6. Revisar el comprobante en la pantalla de resultados
7. Presionar "Volver" para realizar otro cálculo

### Requisitos Técnicos Cumplidos

✓ Patrón MVC implementado
✓ Atomic Design con atoms, molecules, organisms
✓ Rutas con push, pop, pushNamed
✓ Separación de carpetas (models, controllers, views, widgets)
✓ Interfaz clara, ordenada y funcional
✓ Todos los controles obligatorios implementados
✓ Validaciones completas
✓ Cálculos precisos
✓ Resumen detallado de pago
