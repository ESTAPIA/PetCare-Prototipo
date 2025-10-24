import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/plan_template.dart';
import '../../widgets/common/app_card.dart';
import 'plan_review_screen.dart';

/// SCR-PLAN-CUSTOMIZE: Personalizar tareas del plan
/// PROC-002: Plan de Cuidado Rápido
class PlanCustomizeScreen extends StatefulWidget {
  final PlanTemplate template;

  const PlanCustomizeScreen({super.key, required this.template});

  @override
  State<PlanCustomizeScreen> createState() => _PlanCustomizeScreenState();
}

class _PlanCustomizeScreenState extends State<PlanCustomizeScreen> {
  late List<Task> _tasks;
  late DateTime _startDate;
  int get _activeTasksCount => _tasks.where((t) => t.isActive).length;

  @override
  void initState() {
    super.initState();
    // Copiar tareas de la plantilla
    _tasks =
        widget.template.tasks.map((t) {
          return t.copyWith(
            scheduledDate: DateTime.now().add(Duration(days: t.offsetDays)),
            scheduledTime: t.defaultTime,
          );
        }).toList();
    _startDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalizar plan'),
        actions: [
          // Contador de tareas activas
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                '$_activeTasksCount activas',
                style: AppTypography.label.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          // Botón continuar
          TextButton(
            onPressed: _activeTasksCount > 0 ? _onContinue : null,
            child: const Text('Continuar'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de fecha de inicio
          _buildStartDateSelector(),

          // Lista de tareas personalizables
          Expanded(child: _buildTasksList()),

          // Mensaje si no hay tareas activas
          if (_activeTasksCount == 0) _buildNoTasksWarning(),
        ],
      ),
    );
  }

  /// Selector de fecha de inicio del plan
  Widget _buildStartDateSelector() {
    return AppCard(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: InkWell(
        onTap: _selectStartDate,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha de inicio',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_startDate),
                      style: AppTypography.bodyBold,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit_outlined),
            ],
          ),
        ),
      ),
    );
  }

  /// Lista de tareas editables
  Widget _buildTasksList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return _buildTaskItem(task, index);
      },
    );
  }

  /// Item de tarea editable
  Widget _buildTaskItem(Task task, int index) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Opacity(
        opacity: task.isActive ? 1.0 : 0.4,
        child: Column(
          children: [
            // Toggle y título
            Row(
              children: [
                // Toggle activar/desactivar
                Switch(
                  value: task.isActive,
                  onChanged: (value) {
                    setState(() {
                      _tasks[index] = task.copyWith(isActive: value);
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),

                // Emoji e info
                Text(task.type.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.label, style: AppTypography.bodyBold),
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

                // Botón editar
                if (task.isActive)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editTask(task, index),
                    tooltip: 'Editar fecha y hora',
                  ),
              ],
            ),

            // Fecha y hora programadas
            if (task.isActive && task.scheduledDate != null) ...[
              const Divider(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(task.scheduledDate!)} • ${task.scheduledTime}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (task.repeat != RepeatFrequency.none) ...[
                      const SizedBox(width: AppSpacing.sm),
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
          ],
        ),
      ),
    );
  }

  /// Mensaje de advertencia si no hay tareas activas
  Widget _buildNoTasksWarning() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.warning.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: AppColors.warning),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Activa al menos una tarea para continuar',
              style: AppTypography.body.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  /// Seleccionar fecha de inicio del plan
  Future<void> _selectStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );

    if (selectedDate != null) {
      setState(() {
        _startDate = selectedDate;
        // Actualizar fechas de todas las tareas
        for (int i = 0; i < _tasks.length; i++) {
          _tasks[i] = _tasks[i].copyWith(
            scheduledDate: selectedDate.add(
              Duration(days: _tasks[i].offsetDays),
            ),
          );
        }
      });
    }
  }

  /// Editar fecha y hora de una tarea específica
  Future<void> _editTask(Task task, int index) async {
    // Seleccionar fecha
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: task.scheduledDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );

    if (selectedDate == null) return;

    // Verificar si la fecha está en el pasado
    if (selectedDate.isBefore(
      DateTime.now().subtract(const Duration(days: 1)),
    )) {
      final shouldMarkDone = await _showPastDateDialog(task.label);
      if (shouldMarkDone == true) {
        // Marcar como hecha (desactivar)
        setState(() {
          _tasks[index] = task.copyWith(isActive: false);
        });
        return;
      } else if (shouldMarkDone == false) {
        // Volver a abrir el selector de fecha
        _editTask(task, index);
        return;
      }
      // Si cancela, no hacer nada
      return;
    }

    // Seleccionar hora
    if (!mounted) return;
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(task.scheduledTime?.split(':')[0] ?? '10'),
        minute: int.parse(task.scheduledTime?.split(':')[1] ?? '00'),
      ),
    );

    if (selectedTime != null) {
      setState(() {
        _tasks[index] = task.copyWith(
          scheduledDate: selectedDate,
          scheduledTime:
              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
        );
      });

      // Mostrar confirmación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Fecha actualizada a ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Diálogo de conflicto de fecha pasada
  Future<bool?> _showPastDateDialog(String taskName) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tarea vencida'),
            content: Text('$taskName ya venció. ¿Qué deseas hacer?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cambiar fecha'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Marcar como hecho'),
              ),
            ],
          ),
    );
  }

  /// Continuar a revisión del plan
  void _onContinue() {
    // Filtrar solo tareas activas
    final activeTasks = _tasks.where((t) => t.isActive).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PlanReviewScreen(
              template: widget.template,
              tasks: activeTasks,
              startDate: _startDate,
            ),
      ),
    );
  }
}
