# ESTRUCTURA DE CARPETAS - PETCARE+ PROYECTO

## 📂 Arquitectura de carpetas creada:

```
petcare_app/
├── lib/
│   ├── main.dart                    # Entry point de la aplicación
│   ├── core/
│   │   ├── theme/                   # Tokens de diseño (colores, tipografía, espaciado)
│   │   ├── constants/               # Constantes de la app (IDs, límites, duraciones)
│   │   └── utils/                   # Utilidades reutilizables (validadores, helpers)
│   ├── data/
│   │   ├── models/                  # Modelos de datos (Pet, Plan, Reminder, Vet, Chat)
│   │   └── mock/                    # Datos mock de todos los procesos
│   ├── screens/                     # Pantallas de la aplicación
│   │   ├── home/                    # Dashboard principal
│   │   ├── pets/                    # PROC-001: 6 pantallas mascotas
│   │   ├── plans/                   # PROC-002: 6 pantallas plan de cuidado
│   │   ├── reminders/               # PROC-003: 6 pantallas recordatorios
│   │   ├── vets/                    # PROC-004: 2 pantallas veterinarias
│   │   └── chat/                    # PROC-005: 3 pantallas consulta express
│   ├── widgets/                     # Componentes reutilizables
│   │   ├── common/                  # Widgets comunes (botones, inputs, cards)
│   │   ├── pets/                    # Widgets específicos de mascotas
│   │   ├── plans/                   # Widgets específicos de planes
│   │   ├── reminders/               # Widgets específicos de recordatorios
│   │   ├── vets/                    # Widgets específicos de veterinarias
│   │   └── chat/                    # Widgets específicos de chat
│   └── navigation/                  # Rutas y Bottom Navigation Bar
└── assets/
    ├── images/                      # Imágenes del proyecto
    └── icons/                       # Iconos personalizados

```

## ✅ Justificación de la estructura:

### 📦 **core/** - Base reutilizable
- **theme/**: Tokens de diseño de Fase 2 (colores Teal, tipografía, espaciado grid 8dp)
- **constants/**: IDs estables (pet-001, plan-tmpl-001, etc.)
- **utils/**: Validadores, formateo de fechas, helpers

### 💾 **data/** - Datos y modelos
- **models/**: Clases Dart para Pet, Plan, Reminder, Veterinaria, Chat
- **mock/**: JSON fixtures con datos de prueba (3 mascotas, 4 plantillas, 7 recordatorios, 6 veterinarias)

### 📱 **screens/** - Pantallas por proceso
- Carpeta separada para cada proceso (PROC-001 a PROC-005)
- Facilita navegación y mantenimiento
- Alineado con documentación de Fase 3

### 🧩 **widgets/** - Componentes reutilizables
- **common/**: Componentes usados en múltiples procesos
- **específicos/**: Widgets únicos de cada proceso (pet_card, reminder_card, chat_bubble)

### 🗺️ **navigation/** - Navegación centralizada
- Rutas de toda la app
- Bottom Navigation Bar (5 tabs)

### 🎨 **assets/** - Recursos estáticos
- **images/**: Fotos de mascotas, veterinarias
- **icons/**: Iconos personalizados si necesarios

## 🎯 Estado actual:
- ✅ **18 carpetas** creadas
- ✅ **18 archivos .gitkeep** para mantener estructura en git
- ✅ Alineado con documentación de Fase 2 y Fase 3
- ✅ Preparado para recibir archivos de Sección C (tokens de diseño)

## 📊 Total de elementos:
- **Carpetas**: 18 (3 core + 2 data + 6 screens + 6 widgets + 1 navigation + 2 assets)
- **Archivos**: 19 (main.dart + 18 .gitkeep)
