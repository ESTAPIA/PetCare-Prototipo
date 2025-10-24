import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tokens de tipografía del sistema de diseño PetCare
/// Basado en documentación: 03-tokens-diseno.md
/// Escala modular con valores en sp (scale-independent pixels)
class AppTypography {
  // Constructor privado para evitar instanciación
  AppTypography._();

  // ========================================
  // TÍTULOS
  // ========================================
  
  /// Título H1: 20sp Bold
  /// Uso: Títulos principales de pantalla
  /// Line height: 1.4 (28sp)
  static const TextStyle h1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700, // Bold
    height: 1.4,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );
  
  /// Título H2: 16sp Bold
  /// Uso: Secciones dentro de pantalla, títulos de cards
  /// Line height: 1.5 (24sp)
  static const TextStyle h2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700, // Bold
    height: 1.5,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  // ========================================
  // CUERPO DE TEXTO
  // ========================================
  
  /// Body: 14sp Regular
  /// Uso: Texto principal, descripciones, contenido general
  /// Line height: 1.43 (20sp)
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    height: 1.43,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );
  
  /// Body Bold: 14sp Bold
  /// Uso: Énfasis en texto de cuerpo, valores destacados
  /// Line height: 1.43 (20sp)
  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700, // Bold
    height: 1.43,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  // ========================================
  // TEXTO PEQUEÑO
  // ========================================
  
  /// Caption: 12sp Regular
  /// Uso: Texto de apoyo, timestamps, metadatos
  /// Line height: 1.33 (16sp)
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    height: 1.33,
    color: AppColors.textSecondary,
    letterSpacing: 0,
  );

  // ========================================
  // COMPONENTES
  // ========================================
  
  /// Button: 14sp SemiBold
  /// Uso: Texto de botones
  /// Line height: 1.43 (20sp)
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.43,
    letterSpacing: 0.5, // Mejor legibilidad en mayúsculas
  );
  
  /// Label: 12sp SemiBold
  /// Uso: Labels de inputs, etiquetas, badges
  /// Line height: 1.33 (16sp)
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.33,
    color: AppColors.textPrimary,
    letterSpacing: 0.4,
  );

  // ========================================
  // TEXTTHEME PARA MATERIAL
  // ========================================
  
  /// TextTheme completo para usar en ThemeData
  static const TextTheme textTheme = TextTheme(
    // Mapeo a nomenclatura Material Design 3
    headlineLarge: h1,
    headlineMedium: h2,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: caption,
    labelLarge: button,
    labelMedium: label,
    labelSmall: caption,
  );
}
