import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Card estándar de PetCare con sombra y padding consistentes
/// Usado para agrupar contenido relacionado
class AppCard extends StatelessWidget {
  /// Contenido del card
  final Widget child;
  
  /// Padding interno del card
  /// Por defecto usa AppSpacing.md (16dp)
  final EdgeInsetsGeometry? padding;
  
  /// Margin externo del card
  /// Por defecto usa AppSpacing.sm vertical
  final EdgeInsetsGeometry? margin;
  
  /// Callback cuando se toca el card (opcional)
  final VoidCallback? onTap;
  
  /// Color de fondo del card
  /// Por defecto usa AppColors.surface
  final Color? backgroundColor;
  
  /// Elevación del card (sombra)
  /// Por defecto 2
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: child,
    );

    return Card(
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
      color: backgroundColor ?? AppColors.surface,
      elevation: elevation ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: cardContent,
            )
          : cardContent,
    );
  }
}
