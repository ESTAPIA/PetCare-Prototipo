import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../navigation/app_routes.dart';

/// SCR-PLAN-SUCCESS: Confirmación de plan creado
/// PROC-002: Plan de Cuidado Rápido
class PlanSuccessScreen extends StatelessWidget {
  final int taskCount;
  final String petName;

  const PlanSuccessScreen({
    super.key,
    required this.taskCount,
    required this.petName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono de éxito con animación
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: AppColors.success,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Título
              Text(
                '¡Plan creado correctamente!',
                style: AppTypography.h1,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              // Detalle
              Text(
                '$taskCount recordatorios agregados para $petName',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Botón primario: Ver recordatorios
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    // Navegar a tab de recordatorios
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    // Cambiar a tab recordatorios (requiere acceso al MainNavigator)
                  },
                  icon: const Icon(Icons.notifications),
                  label: const Text('Ver recordatorios'),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Botón secundario: Crear otro plan
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Crear otro plan'),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Botón terciario: Cerrar
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
