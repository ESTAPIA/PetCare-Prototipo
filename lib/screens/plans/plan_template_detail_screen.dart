import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/plan_template.dart';
import '../../widgets/common/app_card.dart';
import 'plan_customize_screen.dart';

/// SCR-PLAN-TEMPLATE-DETAIL: Preview de plantilla
class PlanTemplateDetailScreen extends StatelessWidget {
  final PlanTemplate template;

  const PlanTemplateDetailScreen({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(template.name)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // Header descriptivo
                _buildHeader(),
                const SizedBox(height: AppSpacing.lg),

                // Lista de tareas (preview)
                _buildTasksList(),
              ],
            ),
          ),

          // Botón sticky
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(template.description, style: AppTypography.body),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildInfoChip(
                Icons.calendar_today,
                'Duración: ${template.durationDays} días',
              ),
              _buildInfoChip(Icons.task_alt, '${template.tasks.length} tareas'),
              ...template.species.map(
                (species) => _buildInfoChip(Icons.pets, species),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppColors.surfaceVariant,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildTasksList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tareas incluidas', style: AppTypography.h2),
        const SizedBox(height: AppSpacing.md),
        ...template.tasks.map((task) => _buildTaskPreview(task)),
      ],
    );
  }

  Widget _buildTaskPreview(Task task) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: _getTaskColor(task.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(task.type.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.label, style: AppTypography.bodyBold),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _getTaskTiming(task),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (task.description != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    task.description!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTaskColor(TaskType type) {
    switch (type) {
      case TaskType.vaccine:
        return AppColors.primary;
      case TaskType.medication:
        return AppColors.secondary;
      case TaskType.appointment:
        return AppColors.warning;
      case TaskType.grooming:
        return AppColors.success;
    }
  }

  String _getTaskTiming(Task task) {
    final weeks = (task.offsetDays / 7).floor();
    final repeatText =
        task.repeat != RepeatFrequency.none
            ? ' · ${task.repeat.displayName}'
            : '';

    if (task.offsetDays == 0) {
      return 'Inicio del plan · ${task.defaultTime}$repeatText';
    } else if (weeks > 0) {
      return 'Semana $weeks · ${task.defaultTime}$repeatText';
    } else {
      return 'Día ${task.offsetDays} · ${task.defaultTime}$repeatText';
    }
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlanCustomizeScreen(template: template),
                ),
              );
            },
            child: const Text('Usar plantilla'),
          ),
        ),
      ),
    );
  }
}
