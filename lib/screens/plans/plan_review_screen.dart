import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/plan_template.dart';
import '../../data/mock_plan_templates.dart';
import '../../widgets/common/app_card.dart';
import 'plan_success_screen.dart';

/// SCR-PLAN-REVIEW: Resumen final antes de crear plan
/// PROC-002: Plan de Cuidado Rápido
class PlanReviewScreen extends StatefulWidget {
  final PlanTemplate template;
  final List<Task> tasks;
  final DateTime startDate;

  const PlanReviewScreen({
    super.key,
    required this.template,
    required this.tasks,
    required this.startDate,
  });

  @override
  State<PlanReviewScreen> createState() => _PlanReviewScreenState();
}

class _PlanReviewScreenState extends State<PlanReviewScreen> {
  bool _isCreating = false;
  List<String> _createdReminderIds = []; // Para poder hacer undo

  @override
  Widget build(BuildContext context) {
    final endDate = widget.tasks
        .map((t) => t.scheduledDate ?? DateTime.now())
        .reduce((a, b) => a.isAfter(b) ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Revisar plan')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // Mascota asignada (mock)
                _buildPetCard(),
                const SizedBox(height: AppSpacing.lg),

                // Resumen del plan
                _buildSummaryCard(endDate),
                const SizedBox(height: AppSpacing.lg),

                // Tareas programadas
                Text('Tareas programadas', style: AppTypography.h2),
                const SizedBox(height: AppSpacing.md),
                ...widget.tasks.map((task) => _buildTaskCard(task)),
              ],
            ),
          ),

          // Botones inferiores
          _buildBottomButtons(),
        ],
      ),
    );
  }

  /// Card de mascota asignada
  Widget _buildPetCard() {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.pets, size: 32, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan para',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Luna', style: AppTypography.h2),
                Text(
                  'Perra mestiza, 3 años',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card resumen del plan
  Widget _buildSummaryCard(DateTime endDate) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.template.name, style: AppTypography.h2),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.template.description,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _buildInfoRow(Icons.task_alt, '${widget.tasks.length} tareas'),
              _buildInfoRow(
                Icons.calendar_today,
                '${DateFormat('dd/MM/yyyy').format(widget.startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  /// Card de tarea programada
  Widget _buildTaskCard(Task task) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(task.type.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.label, style: AppTypography.bodyBold),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${DateFormat('dd/MM/yyyy').format(task.scheduledDate!)} • ${task.scheduledTime}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (task.repeat != RepeatFrequency.none) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Chip(
                    label: Text(
                      task.repeat.displayName,
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: AppColors.primaryLight,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Botones inferiores
  Widget _buildBottomButtons() {
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
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isCreating ? null : () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _isCreating ? null : _confirmAndCreatePlan,
                child:
                    _isCreating
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text('Crear plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Confirmar antes de crear plan
  Future<void> _confirmAndCreatePlan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar creación'),
        content: Text(
          '¿Crear plan de cuidado con ${widget.tasks.length} tareas para Luna?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, crear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _createPlan();
    }
  }

  /// Crear plan
  Future<void> _createPlan() async {
    setState(() => _isCreating = true);

    try {
      // Simular creación de plan
      final result = await MockPlanTemplatesRepository.createPlan(
        templateId: widget.template.id,
        petId: 'pet-001', // Mock
        tasks: widget.tasks,
        startDate: widget.startDate,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // Guardar IDs de recordatorios creados
        _createdReminderIds = List<String>.from(result['reminderIds'] ?? []);

        // Navegar a pantalla de éxito
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => PlanSuccessScreen(
                  taskCount: widget.tasks.length,
                  petName: 'Luna',
                  createdReminderIds: _createdReminderIds,
                ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear plan: $e'),
          backgroundColor: AppColors.error,
        ),
      );

      setState(() => _isCreating = false);
    }
  }
}
