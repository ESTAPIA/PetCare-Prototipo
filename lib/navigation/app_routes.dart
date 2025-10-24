/// Rutas de navegación de la aplicación PetCare
/// Basado en documentación: 01-mapa-navegacion.md, 04-inventario-pantallas.md
/// 
/// Patrón: Bottom Navigation (5 tabs) + Stack Navigation por proceso
class AppRoutes {
  // Constructor privado para evitar instanciación
  AppRoutes._();

  // ========================================
  // TAB 1: INICIO (Home/Dashboard + Mascotas)
  // PROC-001: Gestión de Mascotas
  // ========================================
  
  /// Dashboard principal - Pantalla inicial del tab Inicio
  static const String home = '/home';
  
  /// Lista de mascotas del usuario
  static const String petList = '/pet/list';
  
  /// Crear nueva mascota (modal fullscreen)
  static const String petNew = '/pet/new';
  
  /// Detalle de una mascota específica
  /// Parámetro: petId (String)
  static const String petDetail = '/pet/detail';
  
  /// Editar información de mascota
  /// Parámetro: petId (String)
  static const String petEdit = '/pet/edit';
  
  /// Productos y notas de una mascota
  /// Parámetro: petId (String)
  static const String petProducts = '/pet/products';
  
  /// Perfil de usuario y ayuda
  static const String profile = '/home/profile';

  // ========================================
  // TAB 2: PLAN DE CUIDADO
  // PROC-002: Plan de Cuidado Rápido
  // ========================================
  
  /// Seleccionar plantilla de plan - Pantalla inicial del tab Plan
  static const String planTemplates = '/plan';
  
  /// Detalle de plantilla seleccionada
  /// Parámetro: templateId (String)
  static const String planTemplateDetail = '/plan/template';
  
  /// Personalizar tareas del plan
  /// Parámetro: templateId (String)
  static const String planCustomize = '/plan/customize';
  
  /// Revisar plan antes de confirmar
  static const String planReview = '/plan/review';
  
  /// Confirmación de plan creado
  static const String planConfirm = '/plan/confirm';

  // ========================================
  // TAB 3: RECORDATORIOS
  // PROC-003: Recordatorios
  // ========================================
  
  /// Lista de recordatorios - Pantalla inicial del tab Recordatorios
  static const String reminders = '/reminders';
  
  /// Crear nuevo recordatorio
  static const String reminderNew = '/reminders/new';
  
  /// Detalle de recordatorio
  /// Parámetro: reminderId (String)
  static const String reminderDetail = '/reminders/detail';
  
  /// Editar recordatorio existente
  /// Parámetro: reminderId (String)
  static const String reminderEdit = '/reminders/edit';
  
  /// Vista de calendario de recordatorios
  static const String reminderCalendar = '/reminders/calendar';

  // ========================================
  // TAB 4: VETERINARIAS
  // PROC-004: Veterinarias Cercanas
  // ========================================
  
  /// Mapa y lista de veterinarias - Pantalla inicial del tab Veterinarias
  static const String vets = '/vets';
  
  /// Detalle de veterinaria
  /// Parámetro: vetId (String)
  static const String vetDetail = '/vets/detail';

  // ========================================
  // TAB 5: CONSULTA EXPRESS
  // PROC-005: Consulta Express
  // ========================================
  
  /// Inicio de consulta express - Pantalla inicial del tab Consulta
  static const String consult = '/consult';
  
  /// Chat con bot veterinario
  /// Parámetros: petId (String), mode ('active' | 'readonly')
  static const String consultChat = '/consult/chat';
  
  /// Resumen de consulta finalizada
  /// Parámetro: consultId (String)
  static const String consultSummary = '/consult/summary';

  // ========================================
  // HELPERS DE RUTAS DINÁMICAS
  // ========================================
  
  /// Construir ruta de detalle de mascota
  static String petDetailRoute(String petId) => '$petDetail/$petId';
  
  /// Construir ruta de edición de mascota
  static String petEditRoute(String petId) => '$petEdit/$petId';
  
  /// Construir ruta de productos de mascota
  static String petProductsRoute(String petId) => '$petProducts/$petId';
  
  /// Construir ruta de detalle de plantilla
  static String planTemplateDetailRoute(String templateId) => 
      '$planTemplateDetail/$templateId';
  
  /// Construir ruta de personalización de plan
  static String planCustomizeRoute(String templateId) => 
      '$planCustomize/$templateId';
  
  /// Construir ruta de detalle de recordatorio
  static String reminderDetailRoute(String reminderId) => 
      '$reminderDetail/$reminderId';
  
  /// Construir ruta de edición de recordatorio
  static String reminderEditRoute(String reminderId) => 
      '$reminderEdit/$reminderId';
  
  /// Construir ruta de detalle de veterinaria
  static String vetDetailRoute(String vetId) => '$vetDetail/$vetId';
  
  /// Construir ruta de chat de consulta
  static String consultChatRoute(String petId, {bool readonly = false}) => 
      '$consultChat/$petId?mode=${readonly ? "readonly" : "active"}';
  
  /// Construir ruta de resumen de consulta
  static String consultSummaryRoute(String consultId) => 
      '$consultSummary/$consultId';

  // ========================================
  // ÍNDICES DE TABS (Bottom Navigation Bar)
  // ========================================
  
  /// Índice del tab Inicio
  static const int tabHome = 0;
  
  /// Índice del tab Plan
  static const int tabPlan = 1;
  
  /// Índice del tab Recordatorios
  static const int tabReminders = 2;
  
  /// Índice del tab Veterinarias
  static const int tabVets = 3;
  
  /// Índice del tab Consulta
  static const int tabConsult = 4;

  // ========================================
  // MAPEO DE RUTAS A TABS
  // ========================================
  
  /// Obtener índice de tab según la ruta actual
  static int getTabIndexFromRoute(String route) {
    if (route.startsWith('/home') || route.startsWith('/pet')) {
      return tabHome;
    } else if (route.startsWith('/plan')) {
      return tabPlan;
    } else if (route.startsWith('/reminders')) {
      return tabReminders;
    } else if (route.startsWith('/vets')) {
      return tabVets;
    } else if (route.startsWith('/consult')) {
      return tabConsult;
    }
    return tabHome; // Default
  }
  
  /// Obtener ruta inicial de cada tab
  static String getInitialRouteForTab(int tabIndex) {
    switch (tabIndex) {
      case tabHome:
        return home;
      case tabPlan:
        return planTemplates;
      case tabReminders:
        return reminders;
      case tabVets:
        return vets;
      case tabConsult:
        return consult;
      default:
        return home;
    }
  }
}
