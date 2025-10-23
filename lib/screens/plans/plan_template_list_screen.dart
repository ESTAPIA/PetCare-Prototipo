import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';

/// SCR-PLAN-TMPL: Seleccionar plantilla de plan
/// PROC-002: Plan de Cuidado Rápido
/// 
/// Objetivo: Mostrar plantillas predefinidas para crear plan de cuidado
class PlanTemplateListScreen extends StatelessWidget {
  const PlanTemplateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan de Cuidado'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Header con instrucción
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            color: AppColors.surfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Elige una plantilla',
                  style: AppTypography.h2,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Selecciona un plan según la especie de tu mascota',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de plantillas
          Expanded(
            child: _buildTemplatesList(),
          ),
        ],
      ),
    );
  }

  /// Construir lista de plantillas
  Widget _buildTemplatesList() {
    // TODO: Conectar con datos mock
    final hasTemplates = true; // Cambiar según datos
    
    if (!hasTemplates) {
      return const EmptyState(
        icon: Icons.calendar_today_outlined,
        message: 'No hay plantillas disponibles',
        instruction: 'Crea recordatorios personalizados desde la sección Recordatorios',
        actionLabel: 'Ir a Recordatorios',
        // onAction: () => cambiar a tab Recordatorios,
      );
    }
    
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        _buildTemplateCard(
          title: 'Plan Cachorro - Perro',
          description: 'Vacunas, desparasitación y controles para cachorros',
          tasks: 12,
          duration: '6 meses',
          icon: Icons.pets,
          color: AppColors.primary,
        ),
        _buildTemplateCard(
          title: 'Plan Adulto - Perro',
          description: 'Mantenimiento anual para perros adultos',
          tasks: 8,
          duration: '12 meses',
          icon: Icons.pets,
          color: AppColors.secondary,
        ),
        _buildTemplateCard(
          title: 'Plan Cachorro - Gato',
          description: 'Vacunas y cuidados esenciales para gatitos',
          tasks: 10,
          duration: '6 meses',
          icon: Icons.pets,
          color: AppColors.primary,
        ),
        _buildTemplateCard(
          title: 'Plan Adulto - Gato',
          description: 'Controles y vacunas para gatos adultos',
          tasks: 6,
          duration: '12 meses',
          icon: Icons.pets,
          color: AppColors.secondary,
        ),
      ],
    );
  }

  /// Card de plantilla individual
  Widget _buildTemplateCard({
    required String title,
    required String description,
    required int tasks,
    required String duration,
    required IconData icon,
    required Color color,
  }) {
    return AppCard(
      onTap: () {
        // TODO: Navegar a detalle de plantilla
      },
      child: Row(
        children: [
          // Ícono
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyBold),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.task_alt, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '$tasks tareas',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Flecha
          Icon(
            Icons.chevron_right,
            color: AppColors.textDisabled,
          ),
        ],
      ),
    );
  }
}
