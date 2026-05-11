# Aplicación 2: Nómina de Choferes - Documentación

## Descripción General
Aplicación Flutter para calcular la nómina semanal de choferes de una compañía de transporte, implementando MVC y Atomic Design.

## Estructura del Proyecto

```
pagos_choferes/
├── lib/
│   ├── main.dart                              # Punto de entrada, configuración de rutas
│   ├── model/
│   │   └── chofer_model.dart                 # Modelos: ChoferModel, NominaModel
│   ├── controller/
│   │   └── chofer_controller.dart            # Lógica de negocio: registrarChofer(), procesarNomina()
│   ├── view/
│   │   ├── home_choferes_view.dart           # Pantalla principal con formulario
│   │   └── resultado_choferes_view.dart      # Pantalla de reporte de nómina
│   └── widgets/
│       ├── atoms/                            # Componentes individuales (Atomic Design)
│       │   ├── input_text.dart              # Campo de texto personalizado
│       │   ├── custom_label.dart            # Etiqueta personalizada
│       │   ├── custom_button.dart           # Botón personalizado
│       │   ├── custom_checkbox.dart         # CheckBox personalizado
│       │   └── custom_radio.dart            # RadioButton personalizado
│       ├── molecules/                        # Combinaciones de átomos
│       │   ├── info_chofer.dart             # Sección de datos del chofer
│       │   ├── datos_horas.dart             # Sección de horas (lunes a sábado)
│       │   ├── selector_tipo_chofer.dart    # Sección de tipo de jornada
│       │   └── opciones_estado_chofer.dart  # Sección de estado (activo, bono)
│       └── organisms/                        # Formularios completos
│           └── formulario_chofer.dart       # Formulario completo de registro
├── pubspec.yaml                              # Dependencias del proyecto
└── pubspec.lock                              # Dependencias bloqueadas
```

## Patrones Implementados

### 1. MVC (Model-View-Controller)
- **Model**: `chofer_model.dart` - Estructuras de datos (ChoferModel, NominaModel)
- **Controller**: `chofer_controller.dart` - Lógica de negocio y validaciones
- **View**: Carpeta `view/` - Interfaces de usuario

### 2. Atomic Design
- **Atoms**: Componentes básicos reutilizables (InputText, CustomButton, etc.)
- **Molecules**: Agrupaciones de átomos (InfoChofer, DatosHoras, etc.)
- **Organisms**: Formularios complejos (FormularioChofer)

### 3. Rutas de navegación
- `/`: HomeChoferesView (pantalla principal)
- `/resultado`: ResultadoChoferesView (pantalla de reporte)

## Especificaciones de Negocio

### Datos Requeridos por Chofer
- Nombre completo
- Horas trabajadas por cada día (lunes a sábado = 6 días)
- Sueldo por hora
- Tipo de jornada (Diurno, Nocturno, Mixto)
- Estado del chofer (Activo/Inactivo)
- Opción de bono (10% adicional)

### Cálculos Realizados

#### Para cada chofer:
```
Total Horas = Lunes + Martes + Miércoles + Jueves + Viernes + Sábado
Sueldo Base = Total Horas × Sueldo por Hora
Bono = (Sueldo Base × 10%) si recibe bono, sino 0
Sueldo Total = Sueldo Base + Bono
```

#### Reportes globales:
- Total de horas trabajadas por cada chofer
- Sueldo semanal de cada chofer (con o sin bono)
- Total general que pagará la empresa (suma de sueldos de choferes activos)
- Nombre del chofer que trabajó más horas el día lunes
- Reporte detallado con todos los datos calculados

### Controles Obligatorios Implementados

✓ **Cajas de texto** para:
  - Nombre del chofer
  - Horas trabajadas (lunes a sábado)
  - Sueldo por hora

✓ **Labels** para:
  - Títulos de secciones
  - Mostrar información de choferes registrados
  - Mostrar resultados en el reporte

✓ **Botones** para:
  - Registrar Chofer
  - Calcular Nómina
  - Limpiar Todo
  - Volver
  - Guardar Nómina

✓ **CheckBox** para:
  - Marcar si el chofer está activo
  - Marcar si recibe bono

✓ **RadioButton** para:
  - Seleccionar tipo de jornada (Diurno, Nocturno, Mixto)

## Funcionalidades Principales

### 1. Registro de Choferes
- Se pueden registrar hasta 5 choferes
- Validaciones de datos completas
- Contador visual de choferes registrados

### 2. Datos de Consumo (Horas)
- Entrada separada para cada día de trabajo
- Unidad: horas (máximo 24 por día)
- Validación de valores numéricos positivos

### 3. Estado del Chofer
- CheckBox para marcar como activo/inactivo
- CheckBox para indicar si recibe bono (10%)
- Solo se calculan los choferes activos

### 4. Tipo de Jornada
- RadioButtons para seleccionar:
  - Diurno
  - Nocturno
  - Mixto

### 5. Cálculo de Nómina
- Procesa todos los choferes registrados
- Calcula totales de horas y sueldos
- Identifica chofer con más horas el lunes
- Suma total que pagará la empresa

### 6. Reporte de Nómina
Muestra resumen detallado con:
- Número de chofer
- Nombre
- Tipo de jornada
- Estado (Activo/Inactivo)
- Horas por día
- Total de horas
- Sueldo por hora
- Sueldo base
- Bono (si aplica)
- Sueldo total
- Resumen general (total empresa, chofer con más horas)
- Fecha y hora del reporte

## Validaciones Implementadas

1. **Nombre**: Campo requerido, sin duplicados
2. **Horas**: Deben ser numéricas, positivas, máximo 24 por día
3. **Sueldo**: Debe ser positivo y numérico
4. **Todos los días**: Deben tener valor de horas
5. **Al calcular**: Debe haber al menos un chofer registrado
6. **Estado**: Solo calcula choferes activos

## Estilos y Temas

- **Color primario**: Naranja/Naranja Oscuro (Colors.deepOrange)
- **Color secundario**: Verde (para botones de registro)
- **Color de cálculo**: Naranja oscuro (para botones de nómina)
- **Color de descarte**: Gris (para limpiar)
- **Material Design 3**: Activado

## Navegación

```
HomeChoferesView (Formulario de registro)
         ↓
    [Registrar] (x5)
         ↓
    [Calcular Nómina]
         ↓
ResultadoChoferesView (Reporte)
         ↓
    [Volver]
         ↓
HomeChoferesView
```

## Rutas Implementadas

- Push: `Navigator.pushNamed(context, '/resultado', arguments: resultado)`
- Pop: `Navigator.pop(context)`

## Cómo Usar la Aplicación

1. Ingresar datos del primer chofer (nombre, horas 6 días, sueldo/hora)
2. Seleccionar tipo de jornada mediante RadioButton
3. Marcar si está activo y si recibe bono (CheckBox)
4. Presionar "Registrar Chofer"
5. Repetir pasos 1-4 para los demás choferes (máximo 5)
6. Presionar "Calcular Nómina" cuando todos están registrados
7. Revisar el reporte con todos los cálculos
8. Presionar "Volver" para hacer modificaciones
9. Presionar "Limpiar Todo" para comenzar de nuevo

## Límites

- Máximo 5 choferes por nómina
- Máximo 24 horas de trabajo por día
- Mínimo 1 chofer activo para calcular nómina

## Requisitos Técnicos Cumplidos

✓ Patrón MVC implementado completamente
✓ Atomic Design con atoms, molecules, organisms
✓ Rutas con push, pop, pushNamed
✓ Separación de carpetas (models, controllers, views, widgets)
✓ Interfaz clara, ordenada y funcional
✓ Todos los controles obligatorios implementados
✓ Validaciones completas
✓ Cálculos precisos
✓ Reporte detallado
