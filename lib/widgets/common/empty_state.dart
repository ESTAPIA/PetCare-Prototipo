import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

/// Estado vacío con ilustración, mensaje y acción opcional
/// Usado cuando no hay datos para mostrar
class EmptyState extends StatelessWidget {
  /// Ícono que representa el estado vacío
  final IconData icon;
  
  /// Mensaje principal explicando por qué está vacío
  final String message;
  
  /// Mensaje secundario con instrucción (opcional)
  final String? instruction;
  
  /// Texto del botón de acción (opcional)
  final String? actionLabel;
  
  /// Callback del botón de acción
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.instruction,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono grande con color suave
            Icon(
              icon,
              size: 80,
              color: AppColors.textDisabled.withValues(alpha: 0.5),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Mensaje principal
            Text(
              message,
              style: AppTypography.h2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Instrucción opcional
            if (instruction != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                instruction!,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Botón de acción opcional
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
