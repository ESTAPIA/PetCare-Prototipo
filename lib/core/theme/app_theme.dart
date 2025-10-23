import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Tema unificado de la aplicación PetCare
/// Combina todos los tokens de diseño (colores, tipografía, espaciado)
/// en un ThemeData coherente para Material Design 3
class AppTheme {
  // Constructor privado para evitar instanciación
  AppTheme._();

  /// Tema principal de la aplicación
  static ThemeData get lightTheme {
    return ThemeData(
      // ========================================
      // CONFIGURACIÓN BASE
      // ========================================
      useMaterial3: true,
      brightness: Brightness.light,

      // ========================================
      // ESQUEMA DE COLORES
      // ========================================
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onPrimary,
        error: AppColors.error,
        onError: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        outline: AppColors.divider,
      ),

      // ========================================
      // COLORES DE SCAFFOLD
      // ========================================
      scaffoldBackgroundColor: AppColors.background,

      // ========================================
      // TIPOGRAFÍA
      // ========================================
      textTheme: AppTypography.textTheme,
      fontFamily: 'Roboto', // Por defecto en Android, SF Pro en iOS

      // ========================================
      // APP BAR
      // ========================================
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimary,
        ),
      ),

      // ========================================
      // BOTONES ELEVADOS (PRIMARY)
      // ========================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 2,
          shadowColor: Colors.black26,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.button,
        ),
      ),

      // ========================================
      // BOTONES DE TEXTO
      // ========================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.button,
        ),
      ),

      // ========================================
      // BOTONES CON BORDE (SECONDARY)
      // ========================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.button,
        ),
      ),

      // ========================================
      // INPUTS (TEXTFIELD)
      // ========================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        
        // Borde normal
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        
        // Borde cuando está habilitado pero sin foco
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        
        // Borde cuando tiene foco
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        
        // Borde de error
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        
        // Borde de error con foco
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        
        // Estilos de texto
        labelStyle: AppTypography.label.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTypography.body.copyWith(color: AppColors.textDisabled),
        errorStyle: AppTypography.caption.copyWith(color: AppColors.error),
        
        // Íconos
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),

      // ========================================
      // CARDS
      // ========================================
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),

      // ========================================
      // DIVIDER
      // ========================================
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: AppSpacing.md,
      ),

      // ========================================
      // ICONOS
      // ========================================
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),

      // ========================================
      // BOTTOM NAVIGATION BAR
      // ========================================
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ========================================
      // FLOATING ACTION BUTTON
      // ========================================
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }
}
