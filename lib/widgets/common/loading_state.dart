import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

/// Indicador de carga animado con mensaje opcional
/// Usado mientras se cargan datos
class LoadingState extends StatelessWidget {
  /// Mensaje opcional que se muestra debajo del indicador
  final String? message;
  
  /// Tamaño del indicador de progreso
  /// Por defecto 48.0
  final double? size;

  const LoadingState({
    super.key,
    this.message,
    this.size,
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
            // Indicador circular
            SizedBox(
              width: size ?? 48.0,
              height: size ?? 48.0,
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            
            // Mensaje opcional
            if (message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                message!,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget de skeleton (placeholder animado) para cards
/// Usado para simular carga de contenido
class SkeletonCard extends StatefulWidget {
  /// Altura del skeleton
  final double height;
  
  /// Ancho del skeleton (null = expandir)
  final double? width;

  const SkeletonCard({
    super.key,
    this.height = 100,
    this.width,
  });

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        );
      },
    );
  }
}
