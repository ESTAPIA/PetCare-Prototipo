/// Tokens de espaciado del sistema de diseño PetCare
/// Basado en documentación: 03-tokens-diseno.md
/// Sistema de grid de 8dp con múltiplos para consistencia visual
class AppSpacing {
  // Constructor privado para evitar instanciación
  AppSpacing._();

  // ========================================
  // GRID BASE
  // ========================================
  
  /// Unidad base del sistema de grid
  /// Todos los espaciados son múltiplos de este valor
  static const double gridBase = 8.0;

  // ========================================
  // ESCALA DE ESPACIADO
  // ========================================
  
  /// Extra Small: 4dp (0.5 × grid)
  /// Uso: Espaciado mínimo entre elementos muy relacionados
  static const double xs = 4.0;
  
  /// Small: 8dp (1 × grid)
  /// Uso: Padding interno de componentes pequeños, separación entre ícono y texto
  static const double sm = 8.0;
  
  /// Medium: 16dp (2 × grid)
  /// Uso: Padding estándar de cards/containers, separación entre elementos relacionados
  static const double md = 16.0;
  
  /// Large: 24dp (3 × grid)
  /// Uso: Separación entre secciones, margins laterales de pantalla
  static const double lg = 24.0;
  
  /// Extra Large: 32dp (4 × grid)
  /// Uso: Separación entre bloques grandes, padding vertical de pantalla
  static const double xl = 32.0;
  
  /// Extra Extra Large: 48dp (6 × grid)
  /// Uso: Separación máxima, espacios destacados
  static const double xxl = 48.0;

  // ========================================
  // MEDIDAS ESPECÍFICAS
  // ========================================
  
  /// Altura/ancho mínimo de área táctil (según Shneiderman)
  /// Uso: Botones, checkboxes, elementos interactivos
  static const double minTouchTarget = 48.0;
  
  /// Border radius pequeño: 4dp
  /// Uso: Badges, chips pequeños
  static const double radiusSm = 4.0;
  
  /// Border radius medio: 8dp
  /// Uso: Botones, inputs, elementos estándar
  static const double radiusMd = 8.0;
  
  /// Border radius grande: 12dp
  /// Uso: Cards, modales, contenedores destacados
  static const double radiusLg = 12.0;

  // ========================================
  // HELPERS DE PADDING
  // ========================================
  
  /// Padding horizontal estándar de pantalla (lg en ambos lados)
  static const double screenHorizontalPadding = lg;
  
  /// Padding vertical estándar de pantalla (xl arriba y abajo)
  static const double screenVerticalPadding = xl;
}
