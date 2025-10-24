# Diagnóstico: Problema de Navegación en Consulta → Veterinarias

**Fecha**: 23 de octubre de 2025  
**Proceso**: PROC-005 (Consulta Express IA) + PROC-004 (Veterinarias)  
**Síntoma**: Al regresar de VetMapScreen a ChatActiveScreen, aparece error de ruta

---

## 🔍 ANÁLISIS DEL PROBLEMA

### Arquitectura de Navegación Actual

```
MainNavigator (IndexedStack con 5 tabs)
├── Tab 0: Home Navigator
├── Tab 1: Plan Navigator
├── Tab 2: Reminders Navigator
├── Tab 3: Vets Navigator
├── Tab 4: Consult Navigator ← Aquí está el problema
    └── ChatHomeScreen (raíz del tab)
        └── Navigator.push → ChatActiveScreen
            └── Navigator.push → VetMapScreen
                └── Navigator.push → VetDetailScreen
```

### Stack de Navegación Real

#### Stack ESPERADO (cuando todo funciona):
```
[Tab 4: Consult Navigator]
  └── ChatHomeScreen (isFirst: true)
      └── ChatActiveScreen (Navigator.push)
          └── VetMapScreen (Navigator.push)
              └── VetDetailScreen (Navigator.push)
```

**Al presionar back desde VetDetailScreen**: VetDetailScreen → VetMapScreen → ChatActiveScreen ✅

#### Stack PROBLEMÁTICO (cuando hay error):
```
[Tab 4: Consult Navigator]
  └── ChatHomeScreen (isFirst: true)
      └── ChatSummaryScreen (Navigator.pushReplacement)
          
[VetMapScreen flotando sin contexto] ← Error: perdió su Navigator padre
```

---

## 🐛 CAUSAS IDENTIFICADAS

### **Causa #1: pushReplacement en _finishConsultation**

**Archivo**: `chat_active_screen.dart` línea 552  
**Código problemático**:
```dart
void _finishConsultation() {
  // ...
  Navigator.pushReplacement(  // ← PROBLEMA
    context,
    MaterialPageRoute(
      builder: (context) => ChatSummaryScreen(consulta: consulta),
    ),
  );
}
```

**¿Qué pasa?**
- `Navigator.pushReplacement` REEMPLAZA ChatActiveScreen con ChatSummaryScreen
- Si el usuario está navegando por VetMapScreen mientras esto ocurre, VetMapScreen queda "huérfano"
- Al presionar back, VetMapScreen intenta volver a ChatActiveScreen pero YA NO EXISTE

**Flujo del error**:
1. Usuario inicia consulta en ChatActiveScreen
2. Bot responde con mensaje + acción "Buscar Veterinarias"
3. Usuario toca el botón → Navigator.push a VetMapScreen
4. Usuario navega a VetDetailScreen
5. **Mientras está en VetDetailScreen, el bot puede seguir respondiendo**
6. **Si el usuario toca "Finalizar" desde AppBar → pushReplacement**
7. ChatActiveScreen se reemplaza por ChatSummaryScreen
8. Usuario presiona back desde VetDetailScreen → back a VetMapScreen → **ERROR**: intenta regresar a ChatActiveScreen que ya no existe

---

### **Causa #2: Contexto de Navigator Anidado**

**Archivo**: `main_navigator.dart` líneas 211-223  
**Arquitectura**:
```dart
Navigator(  // Navigator del Tab (anidado)
  key: navigatorKey,
  initialRoute: AppRoutes.consult,
  onGenerateRoute: (settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => _buildScreen(route: settings.name ?? initialRoute),
    );
  },
)
```

**¿Qué pasa?**
- Cada tab tiene su propio Navigator anidado
- ChatActiveScreen usa `Navigator.push(context, ...)` 
- Si el `context` se confunde entre el Navigator raíz y el Navigator del tab, el stack se rompe
- Al hacer push desde ChatActiveScreen, usa el Navigator del tab (correcto)
- Pero si hay un cambio de tab mientras VetMapScreen está abierto, el estado se pierde

---

### **Causa #3: WillPopScope/PopScope en MainNavigator**

**Archivo**: `main_navigator.dart` líneas 157-159  
**Código**:
```dart
bool _onWillPop() {
  final currentNavigator = _navigatorKeys[_currentTabIndex].currentState;
  
  if (currentNavigator != null && currentNavigator.canPop()) {
    currentNavigator.pop();  // Pop dentro del tab
    return false;
  }
  
  if (_currentTabIndex != AppRoutes.tabHome) {
    setState(() {
      _currentTabIndex = AppRoutes.tabHome;  // ← Cambio de tab sin preservar estado
    });
    return false;
  }
  
  return true;
}
```

**¿Qué pasa?**
- Si el usuario presiona back del sistema cuando está en VetMapScreen
- Y el tab actual es Consulta (index 4)
- El código intenta hacer pop dentro del Navigator del tab
- Pero si ChatActiveScreen ya fue reemplazado, el pop no encuentra la pantalla correcta

---

## 🔧 SOLUCIONES PROPUESTAS

### **Solución #1: Cambiar pushReplacement por push en _finishConsultation** ✅ RECOMENDADA

**Cambio en**: `chat_active_screen.dart` línea 552

**Antes**:
```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => ChatSummaryScreen(consulta: consulta),
  ),
);
```

**Después**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatSummaryScreen(consulta: consulta),
  ),
);
```

**Ventajas**:
- ✅ ChatActiveScreen permanece en el stack
- ✅ VetMapScreen/VetDetailScreen pueden regresar correctamente
- ✅ Usuario puede volver a ChatActiveScreen desde ChatSummaryScreen
- ✅ No rompe el flujo de navegación

**Desventaja**:
- ⚠️ Usuario puede regresar de ChatSummaryScreen a ChatActiveScreen (puede ser confuso)

---

### **Solución #2: Deshabilitar "Finalizar" cuando hay navegación activa** ⚠️ ALTERNATIVA

**Cambio en**: `chat_active_screen.dart` líneas 201-206

**Antes**:
```dart
if (!_isReadonly && _messages.isNotEmpty)
  IconButton(
    icon: const Icon(Icons.check),
    onPressed: _finishConsultation,
    tooltip: 'Finalizar consulta',
  ),
```

**Después**:
```dart
if (!_isReadonly && _messages.isNotEmpty)
  IconButton(
    icon: const Icon(Icons.check),
    onPressed: _isNavigating ? null : _finishConsultation,  // Deshabilitar si está navegando
    tooltip: _isNavigating ? 'Regresa para finalizar' : 'Finalizar consulta',
  ),
```

**Requiere**:
- Agregar variable `bool _isNavigating = false`
- Detectar cuando el usuario navega a otra pantalla
- Habilitar el botón solo cuando regresa a ChatActiveScreen

**Ventajas**:
- ✅ Previene el problema por completo
- ✅ Usuario no puede romper el stack

**Desventajas**:
- ⚠️ Más complejo de implementar
- ⚠️ Requiere tracking de navegación

---

### **Solución #3: Usar Navigator.popUntil en lugar de pushReplacement** ⚠️ COMPLEJA

**Cambio en**: `chat_active_screen.dart` línea 552

**Antes**:
```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => ChatSummaryScreen(consulta: consulta),
  ),
);
```

**Después**:
```dart
// Cerrar TODAS las pantallas sobre ChatActiveScreen primero
Navigator.of(context).popUntil((route) {
  return route.settings.name == '/chat_active' || route.isFirst;
});

// Luego hacer pushReplacement (ahora seguro)
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    settings: const RouteSettings(name: '/chat_summary'),
    builder: (context) => ChatSummaryScreen(consulta: consulta),
  ),
);
```

**Ventajas**:
- ✅ Cierra todas las pantallas abiertas antes de reemplazar
- ✅ Mantiene el comportamiento original (no se puede volver a ChatActiveScreen)

**Desventajas**:
- ⚠️ Usuario pierde progreso si estaba en VetDetailScreen
- ⚠️ Experiencia de usuario brusca (cierra pantallas sin avisar)

---

### **Solución #4: Implementar WillPopCallback en VetMapScreen** 🔄 COMPLEMENTARIA

**Cambio en**: `vet_map_screen.dart`

**Agregar**:
```dart
@override
Widget build(BuildContext context) {
  return PopScope(
    canPop: true,
    onPopInvokedWithResult: (didPop, result) {
      if (didPop) {
        // Notificar que regresamos a la pantalla anterior
        // Esto puede ayudar a ChatActiveScreen a detectar el regreso
      }
    },
    child: Scaffold(
      // ... resto del código
    ),
  );
}
```

**Ventajas**:
- ✅ Permite manejar el back de forma más controlada
- ✅ Puede limpiar estado o notificar a pantallas padre

**Desventajas**:
- ⚠️ No soluciona el problema raíz
- ⚠️ Solo complementa otras soluciones

---

## 📊 COMPARACIÓN DE SOLUCIONES

| Solución | Complejidad | Efectividad | UX | Recomendado |
|----------|-------------|-------------|-----|-------------|
| #1: push en lugar de pushReplacement | ⭐ Baja | ⭐⭐⭐ Alta | ⭐⭐⭐ Buena | ✅ SÍ |
| #2: Deshabilitar botón cuando navega | ⭐⭐⭐ Alta | ⭐⭐⭐ Alta | ⭐⭐ Regular | ⚠️ Alternativa |
| #3: popUntil antes de pushReplacement | ⭐⭐ Media | ⭐⭐ Media | ⭐ Mala | ❌ NO |
| #4: WillPopCallback | ⭐⭐ Media | ⭐ Baja | ⭐⭐⭐ Buena | 🔄 Complemento |

---

## ✅ RECOMENDACIÓN FINAL

**Implementar Solución #1**: Cambiar `pushReplacement` por `push` en `_finishConsultation`

**Razones**:
1. ✅ **Simplicidad**: Cambio de 1 línea
2. ✅ **Efectividad**: Soluciona el problema raíz
3. ✅ **Seguridad**: No rompe el stack de navegación
4. ✅ **UX**: Mantiene flujo natural
5. ✅ **Mantenibilidad**: Fácil de entender y mantener

**Trade-off aceptable**:
- Usuario puede regresar de ChatSummaryScreen a ChatActiveScreen
- Esto es realmente una MEJORA: permite revisar la conversación después del resumen
- Si queremos prevenir esto, podemos agregar WillPopScope en ChatSummaryScreen para mostrar confirmación

**Implementación adicional (opcional)**:
- Agregar diálogo de confirmación en ChatSummaryScreen al presionar back:
  ```dart
  "¿Quieres volver a la consulta anterior?"
  - "Sí, revisar conversación"
  - "No, ir a inicio"
  ```

---

## 🧪 CASOS DE PRUEBA

Después de implementar la solución, validar:

### Test Case 1: Flujo Normal
1. ✅ Iniciar nueva consulta
2. ✅ Enviar mensaje al bot
3. ✅ Tocar "Buscar Veterinarias"
4. ✅ Navegar a VetMapScreen
5. ✅ Abrir VetDetailScreen
6. ✅ Presionar back → Regresa a VetMapScreen
7. ✅ Presionar back → Regresa a ChatActiveScreen
8. ✅ Presionar "Finalizar consulta"
9. ✅ Ver ChatSummaryScreen

### Test Case 2: Navegación desde Consulta Activa
1. ✅ Iniciar nueva consulta
2. ✅ Bot responde con acción "Buscar Veterinarias"
3. ✅ Tocar botón → VetMapScreen
4. ✅ Navegar por lista de veterinarias
5. ✅ Presionar back → Regresa a ChatActiveScreen
6. ✅ Mensajes y estado preservados

### Test Case 3: Finalizar desde Veterinarias (antes del fix)
1. ❌ Iniciar consulta
2. ❌ Tocar "Buscar Veterinarias"
3. ❌ Mientras está en VetMapScreen, tocar "Finalizar"
4. ❌ **ERROR**: VetMapScreen pierde contexto

### Test Case 3: Finalizar desde Veterinarias (después del fix)
1. ✅ Iniciar consulta
2. ✅ Tocar "Buscar Veterinarias"
3. ✅ Tocar "Finalizar" → Va a ChatSummaryScreen
4. ✅ Presionar back → Opción de regresar a ChatActiveScreen

### Test Case 4: Cambio de Tab
1. ✅ Iniciar consulta en Tab Consulta
2. ✅ Tocar "Buscar Veterinarias"
3. ✅ Cambiar a Tab Veterinarias
4. ✅ Regresar a Tab Consulta
5. ✅ Estado preservado o restablecido correctamente

---

## 📝 NOTAS DE IMPLEMENTACIÓN

### Archivos a modificar:
1. `lib/screens/chat/chat_active_screen.dart` - Línea 552

### Validaciones post-implementación:
1. ✅ flutter analyze (0 errores)
2. ✅ Probar flujo completo de navegación
3. ✅ Verificar que no hay memory leaks
4. ✅ Probar en Android (botón back del sistema)
5. ✅ Probar en iOS (gesto de swipe)

### Consideraciones futuras:
- Si queremos prevenir volver de Summary a Active, agregar confirmación
- Considerar añadir analytics para tracking de navegación
- Documentar el flujo en arquitectura del proyecto

---

**FIN DEL DIAGNÓSTICO**
