import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/mock_reminders.dart';
import '../../navigation/app_routes.dart';
import '../../navigation/main_navigator.dart';

/// SCR-PLAN-SUCCESS: Confirmación de plan creado
/// PROC-002: Plan de Cuidado Rápido
class PlanSuccessScreen extends StatefulWidget {
  final int taskCount;
  final String petName;
  final List<String> createdReminderIds;

  const PlanSuccessScreen({
    super.key,
    required this.taskCount,
    required this.petName,
    required this.createdReminderIds,
  });

  @override
  State<PlanSuccessScreen> createState() => _PlanSuccessScreenState();
}

class _PlanSuccessScreenState extends State<PlanSuccessScreen> {
  bool _isUndoing = false;

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
                '${widget.taskCount} recordatorios agregados para ${widget.petName}',
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
                  onPressed: _isUndoing
                      ? null
                      : () {
                    // 1. Salir del stack de navegación del tab Plan
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    
                    // 2. Cambiar al tab Recordatorios (índice 2)
                    context.findAncestorStateOfType<MainNavigatorState>()
                        ?.navigateToTab(AppRoutes.tabReminders);
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
                  onPressed: _isUndoing
                      ? null
                      : () {
                    // Salir del stack y volver al tab Plan
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    
                    // Ya estamos en tab Plan (índice 1), solo limpiar stack
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Crear otro plan'),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Botón deshacer: Deshacer plan
              TextButton.icon(
                onPressed: _isUndoing ? null : _undoPlan,
                icon: _isUndoing
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.undo),
                label: const Text('Deshacer este plan'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Botón terciario: Cerrar
              TextButton(
                onPressed: _isUndoing
                    ? null
                    : () {
                  // Salir del stack y volver al tab Inicio
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  context.findAncestorStateOfType<MainNavigatorState>()
                      ?.navigateToTab(AppRoutes.tabHome);
                },
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Deshacer plan eliminando todos los recordatorios creados
  Future<void> _undoPlan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Deshacer plan?'),
        content: Text(
          'Se eliminarán los ${widget.taskCount} recordatorios creados. Esta acción no se puede revertir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isUndoing = true);

    try {
      // Eliminar cada recordatorio creado
      for (final reminderId in widget.createdReminderIds) {
        await MockRemindersRepository.deleteReminder(reminderId);
      }

      if (!mounted) return;

      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plan eliminado correctamente'),
          backgroundColor: AppColors.success,
        ),
      );

      // Volver al tab Inicio
      Navigator.of(context).popUntil((route) => route.isFirst);
      context.findAncestorStateOfType<MainNavigatorState>()
          ?.navigateToTab(AppRoutes.tabHome);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar plan: $e'),
          backgroundColor: AppColors.error,
        ),
      );

      setState(() => _isUndoing = false);
    }
  }
}
