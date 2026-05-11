# 🚕 Nómina de Choferes - Aplicación 2

## Descripción
Aplicación Flutter para calcular la nómina semanal de choferes siguiendo el patrón **MVC** y **Atomic Design**.

## 🎯 Especificaciones Cumplidas

### ✅ Requisitos del TXT
- ✓ Registro de 5 choferes
- ✓ Horas trabajadas por 6 días (lunes a sábado)
- ✓ Sueldo por hora
- ✓ Cálculo total de horas/semana
- ✓ Cálculo de sueldo semanal (con opción de bono)
- ✓ Total general empresa
- ✓ Chofer con más horas el lunes
- ✓ Reporte general detallado

### ✅ Controles Obligatorios
- ✓ Cajas de texto (nombres, horas, sueldo)
- ✓ Labels (títulos y resultados)
- ✓ Botones (registrar, calcular, limpiar, navegar)
- ✓ CheckBox (activo, bono)
- ✓ RadioButton (tipo de jornada)

### ✅ Requisitos Técnicos
- ✓ Patrón MVC completo
- ✓ Atomic Design (Atoms, Molecules, Organisms)
- ✓ Rutas en Flutter (push, pop, pushNamed)
- ✓ Separación de carpetas
- ✓ Interfaz clara y funcional

## 📂 Estructura del Proyecto

```
pagos_choferes/lib/
├── main.dart (routing: / y /resultado)
├── model/chofer_model.dart (ChoferModel, NominaModel)
├── controller/chofer_controller.dart (registrarChofer, procesarNomina)
├── view/ (HomeChoferesView, ResultadoChoferesView)
└── widgets/
    ├── atoms/ (5 componentes)
    ├── molecules/ (4 composiciones)
    └── organisms/ (formulario)
```

## 🚀 Cómo Ejecutar

```bash
# Obtener dependencias
flutter pub get

# Ejecutar la app
flutter run
```

## 💼 Funcionalidades

1. **Registro de Chofer**: Nombre, horas (6 días), sueldo/hora
2. **Tipo de Jornada**: Diurno, Nocturno, Mixto (RadioButtons)
3. **Estado**: Activo/Inactivo, con opción de bono 10% (CheckBox)
4. **Cálculos**: Horas totales, sueldo base, sueldo con bono
5. **Reportes**: Total empresa, chofer con más horas lunes

## 📊 Cálculos

```
Total Horas = Suma de horas (lunes a sábado)
Sueldo Base = Total Horas × Sueldo/Hora
Bono = 10% del Sueldo Base (si aplica)
Sueldo Total = Sueldo Base + Bono
Total Empresa = Suma de sueldos (solo choferes activos)
```

## 🎨 Diseño

- Material Design 3
- Tema naranja (#FF6F00)
- Componentes Atomic Design
- Interfaz intuitiva

## 👥 Choferes

- Máximo 5 choferes por nómina
- Solo calcula choferes activos
- Soporta múltiples tipos de jornada

---

**Desarrollado para la Tarea 1.2**
