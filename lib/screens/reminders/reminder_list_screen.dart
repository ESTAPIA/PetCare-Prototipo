import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/mock_reminders.dart';
import '../../data/mock_pets.dart';
import '../../models/reminder.dart';
import '../../models/pet.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';
import 'reminder_new_screen.dart';
import 'reminder_calendar_screen.dart';
import 'reminder_edit_screen.dart';

/// SCR-REM-LIST: Lista de recordatorios agrupados
/// PROC-003: Recordatorios
class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  String _selectedFilter = 'Todos';
  bool _isLoading = true;
  List<Reminder> _reminders = [];
  List<Pet> _pets = [];
  final Set<String> _processingIds = {}; // IDs en proceso

  @override
  void initState() {
    super.initState();
    _loadReminders();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final pets = await MockPetsRepository.getAllPets();
    setState(() {
      _pets = pets;
    });
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _reminders = MockRemindersRepository.getAllReminders();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Vista calendario',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReminderCalendarScreen(),
                ),
              );
              _loadReminders(); // Recargar al volver
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildRemindersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const ReminderNewScreen()),
          );

          if (result == true && mounted) {
            _loadReminders(); // Recargar lista tras crear
          }
        },
        tooltip: 'Crear recordatorio',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          _buildFilterChip('Todos'),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip('Hoy'),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip('Esta semana'),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip('Vencidos'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    final count = _getFilterCount(label);

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0 && label == 'Vencidos') ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected && _selectedFilter != label) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
    );
  }

  int _getFilterCount(String filter) {
    if (filter != 'Vencidos') return 0;
    return _reminders.where((r) => r.isOverdue).length;
  }

  Widget _buildRemindersList() {
    final filteredReminders = _getFilteredReminders();

    if (filteredReminders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: EmptyState(
          icon: Icons.calendar_today,
          message: 'No hay recordatorios',
          instruction: 'Crea el primero para no olvidar tareas.',
        ),
      );
    }

    final grouped = _groupByDate(filteredReminders);

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        return _buildGroup(entry.key, entry.value);
      },
    );
  }

  Widget _buildGroup(String dateLabel, List<Reminder> reminders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(dateLabel, style: AppTypography.h2),
        ),
        ...reminders.map((r) => _buildReminderItem(r)),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildReminderItem(Reminder reminder) {
    final isDone = reminder.status == ReminderStatus.done;
    final isProcessing = _processingIds.contains(reminder.id);

    return Opacity(
      opacity: isDone ? 0.5 : (isProcessing ? 0.7 : 1.0),
      child: AppCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        onTap: () async {
          // FASE 2 Paso B: Navegar a pantalla de edición
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => ReminderEditScreen(reminder: reminder),
            ),
          );
          if (result == true && mounted) {
            _loadReminders(); // Recargar lista tras editar/eliminar
          }
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: _getTypeColor(reminder.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                reminder.type.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reminder.title,
                          style:
                              isDone
                                  ? AppTypography.bodyBold.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                  )
                                  : AppTypography.bodyBold,
                        ),
                      ),
                      if (reminder.isOverdue && !isDone)
                        _buildBadge('Vencido', AppColors.error),
                      if (reminder.isDueSoon && !isDone)
                        _buildBadge('Pronto', AppColors.warning),
                      if (isDone)
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${reminder.time} • ${_getPetName(reminder.petId)}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!isDone && !isProcessing) ...[
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: Icon(Icons.check, color: AppColors.success),
                tooltip: 'Marcar como hecho',
                onPressed: () => _markAsDone(reminder),
              ),
              IconButton(
                icon: Icon(Icons.schedule, color: AppColors.warning),
                tooltip: 'Posponer',
                onPressed: () => _snooze(reminder),
              ),
            ],
            if (isProcessing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getTypeColor(ReminderType type) {
    switch (type) {
      case ReminderType.vaccine:
        return AppColors.primary;
      case ReminderType.medication:
        return AppColors.secondary;
      case ReminderType.appointment:
        return AppColors.warning;
      case ReminderType.grooming:
        return AppColors.success;
      case ReminderType.other:
        return AppColors.textSecondary;
    }
  }

  String _getPetName(String petId) {
    try {
      return _pets.firstWhere((p) => p.id == petId).nombre;
    } catch (e) {
      return 'Mascota';
    }
  }

  Future<void> _markAsDone(Reminder reminder) async {
    // Prevenir múltiples clics
    if (_processingIds.contains(reminder.id)) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // No cerrar tocando fuera
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar'),
            content: Text('¿Completar "${reminder.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                child: const Text('Sí, hecho'),
              ),
            ],
          ),
    );

    if (confirm != true || !mounted) return;

    // Marcar como en proceso
    setState(() {
      _processingIds.add(reminder.id);
    });

    try {
      final success = await MockRemindersRepository.markAsDone(reminder.id);

      if (!mounted) return;

      if (success) {
        // Recargar lista
        await _loadReminders();

        // Limpiar de procesamiento
        setState(() {
          _processingIds.remove(reminder.id);
        });

        // Mostrar confirmación
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ "${reminder.title}" completado'),
              backgroundColor: AppColors.success,
              action: SnackBarAction(
                label: 'Deshacer',
                textColor: Colors.white,
                onPressed: () => _undoMarkAsDone(reminder.id),
              ),
              duration: const Duration(seconds: 8),
            ),
          );
        }
      } else {
        throw Exception('Error al marcar como hecho');
      }
    } catch (e) {
      if (!mounted) return;

      // Limpiar de procesamiento
      setState(() {
        _processingIds.remove(reminder.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _undoMarkAsDone(String reminderId) async {
    // Prevenir múltiples clics
    if (_processingIds.contains(reminderId)) {
      return;
    }

    setState(() {
      _processingIds.add(reminderId);
    });

    try {
      final reminder = MockRemindersRepository.getReminderById(reminderId);
      if (reminder != null) {
        await MockRemindersRepository.updateReminder(
          reminderId,
          reminder.copyWith(
            status: ReminderStatus.pending,
            clearCompletedAt: true,
          ),
        );

        if (!mounted) return;

        await _loadReminders();

        setState(() {
          _processingIds.remove(reminderId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recordatorio restaurado'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _processingIds.remove(reminderId);
      });
    }
  }

  Future<void> _snooze(Reminder reminder) async {
    // Prevenir múltiples clics
    if (_processingIds.contains(reminder.id)) {
      return;
    }

    final selectedMinutes = await showModalBottomSheet<int>(
      context: context,
      isDismissible: true,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Posponer recordatorio', style: AppTypography.h2),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  leading: Icon(Icons.schedule, color: AppColors.warning),
                  title: const Text('10 minutos'),
                  onTap: () => Navigator.pop(context, 10),
                ),
                ListTile(
                  leading: Icon(Icons.schedule, color: AppColors.warning),
                  title: const Text('30 minutos'),
                  onTap: () => Navigator.pop(context, 30),
                ),
                ListTile(
                  leading: Icon(Icons.schedule, color: AppColors.warning),
                  title: const Text('1 hora'),
                  onTap: () => Navigator.pop(context, 60),
                ),
                ListTile(
                  leading: Icon(Icons.schedule, color: AppColors.warning),
                  title: const Text('3 horas'),
                  onTap: () => Navigator.pop(context, 180),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
    );

    if (selectedMinutes == null || !mounted) return;

    // Marcar como en proceso
    setState(() {
      _processingIds.add(reminder.id);
    });

    try {
      final newTime = DateTime.now().add(Duration(minutes: selectedMinutes));
      await MockRemindersRepository.snoozeReminder(reminder.id, newTime);

      if (!mounted) return;

      await _loadReminders();

      setState(() {
        _processingIds.remove(reminder.id);
      });

      if (mounted) {
        final formattedTime = DateFormat('HH:mm').format(newTime);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⏰ Reprogramado para $formattedTime'),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _processingIds.remove(reminder.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al posponer: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  List<Reminder> _getFilteredReminders() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedFilter) {
      case 'Hoy':
        return _reminders.where((r) {
          final reminderDate = DateTime.parse(r.date);
          final reminderDay = DateTime(
            reminderDate.year,
            reminderDate.month,
            reminderDate.day,
          );
          return reminderDay == today;
        }).toList();

      case 'Esta semana':
        final weekEnd = today.add(const Duration(days: 7));
        return _reminders.where((r) {
          final reminderDate = DateTime.parse(r.date);
          final reminderDay = DateTime(
            reminderDate.year,
            reminderDate.month,
            reminderDate.day,
          );
          return (reminderDay.isAfter(today) || reminderDay == today) &&
              reminderDay.isBefore(weekEnd);
        }).toList();

      case 'Vencidos':
        return _reminders.where((r) => r.isOverdue).toList();

      default: // Todos
        return _reminders;
    }
  }

  Map<String, List<Reminder>> _groupByDate(List<Reminder> reminders) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final grouped = <String, List<Reminder>>{};

    for (final reminder in reminders) {
      final reminderDate = DateTime.parse(reminder.date);
      final normalizedDate = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
      );

      String label;
      if (normalizedDate == today) {
        label = 'Hoy';
      } else if (normalizedDate == tomorrow) {
        label = 'Mañana';
      } else {
        label = DateFormat('EEEE d MMM', 'es').format(reminderDate);
      }

      grouped.putIfAbsent(label, () => []);
      grouped[label]!.add(reminder);
    }

    return grouped;
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: 100,
              color: AppColors.surfaceVariant,
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            ),
            ...List.generate(
              2,
              (_) => AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      color: AppColors.surfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: double.infinity,
                            color: AppColors.surfaceVariant,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            height: 12,
                            width: 150,
                            color: AppColors.surfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
