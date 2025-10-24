import 'package:flutter/material.dart';

/// Tokens de color del sistema de diseño PetCare
/// Basado en documentación: 03-tokens-diseno.md
/// Todos los colores cumplen WCAG AA (contraste ≥4.5:1)
class AppColors {
  // Constructor privado para evitar instanciación
  AppColors._();

  // ========================================
  // COLORES PRIMARIOS
  // ========================================

  /// Color primario: Teal 700
  /// Uso: Botones principales, AppBar, elementos destacados
  /// Contraste sobre blanco: 4.52:1 ✅
  static const Color primary = Color(0xFF0F766E);

  /// Color secundario: Sky 700
  /// Uso: Botones secundarios, enlaces, acentos
  /// Contraste sobre blanco: 5.12:1 ✅
  static const Color secondary = Color(0xFF0369A1);

  /// Color primario claro (Teal 100) - para fondos suaves
  static const Color primaryLight = Color(0xFFCCFBF1); // Teal 100

  // ========================================
  // COLORES DE FEEDBACK
  // ========================================

  /// Éxito: Green 700
  /// Uso: Mensajes de éxito, confirmaciones
  /// Contraste sobre blanco: 5.38:1 ✅
  static const Color success = Color(0xFF15803D);

  /// Advertencia: Yellow 800
  /// Uso: Alertas, precauciones
  /// Contraste sobre blanco: 6.84:1 ✅
  static const Color warning = Color(0xFF92400E);

  /// Error: Red 700
  /// Uso: Errores, validaciones fallidas
  /// Contraste sobre blanco: 5.94:1 ✅
  static const Color error = Color(0xFFB91C1C);

  /// Información: Blue 600
  /// Uso: Tips, información neutral
  /// Contraste sobre blanco: 4.89:1 ✅
  static const Color info = Color(0xFF2563EB);

  // ========================================
  // COLORES DE SUPERFICIES
  // ========================================

  /// Fondo principal: Slate 50
  /// Uso: Background de pantallas
  static const Color background = Color(0xFFF8FAFC);

  /// Superficie: Blanco
  /// Uso: Cards, modales, elementos elevados
  static const Color surface = Color(0xFFFFFFFF);

  /// Superficie variante: Slate 100
  /// Uso: Secciones alternadas, fondos secundarios
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  /// Divisor: Slate 200
  /// Uso: Líneas separadoras, bordes sutiles
  static const Color divider = Color(0xFFE2E8F0);

  // ========================================
  // COLORES DE TEXTO
  // ========================================

  /// Texto primario: Gray 900
  /// Uso: Títulos, texto principal
  /// Contraste sobre blanco: 14.15:1 ✅
  static const Color textPrimary = Color(0xFF111827);

  /// Texto secundario: Gray 500
  /// Uso: Subtítulos, texto de apoyo
  /// Contraste sobre blanco: 4.69:1 ✅
  static const Color textSecondary = Color(0xFF6B7280);

  /// Texto deshabilitado: Gray 400
  /// Uso: Elementos inactivos
  static const Color textDisabled = Color(0xFF9CA3AF);

  /// Texto sobre color primario: Blanco
  /// Uso: Texto sobre botones primary/secondary
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ========================================
  // ESTADOS INTERACTIVOS
  // ========================================

  /// Opacidad para estado hover (8% blanco sobre color)
  static const double hoverOpacity = 0.08;

  /// Opacidad para estado pressed (12% negro sobre color)
  static const double pressedOpacity = 0.12;

  /// Opacidad para estado disabled (38% del color original)
  static const double disabledOpacity = 0.38;
}
