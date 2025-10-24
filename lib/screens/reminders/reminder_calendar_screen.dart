import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/mock_reminders.dart';
import '../../models/reminder.dart';
import '../../widgets/common/app_card.dart';

/// SCR-REM-CALENDAR: Vista calendario mensual
/// PROC-003: Recordatorios
class ReminderCalendarScreen extends StatefulWidget {
  const ReminderCalendarScreen({super.key});

  @override
  State<ReminderCalendarScreen> createState() => _ReminderCalendarScreenState();
}

class _ReminderCalendarScreenState extends State<ReminderCalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<Reminder>> _remindersByDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
    _loadReminders();
  }

  void _loadReminders() {
    final reminders = MockRemindersRepository.getAllReminders();
    _remindersByDate = {};

    for (final reminder in reminders) {
      final date = DateTime.parse(reminder.date);
      final normalizedDate = DateTime(date.year, date.month, date.day);

      _remindersByDate.putIfAbsent(normalizedDate, () => []);
      _remindersByDate[normalizedDate]!.add(reminder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          TextButton.icon(
            onPressed: _goToToday,
            icon: const Icon(Icons.today),
            label: const Text('Hoy'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const Divider(height: 1),
          Expanded(child: _buildSelectedDayReminders()),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar<Reminder>(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      locale: 'es_ES',
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: AppTypography.h2,
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
      ),
      eventLoader: (day) {
        final normalizedDay = DateTime(day.year, day.month, day.day);
        return _remindersByDate[normalizedDay] ?? [];
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = DateTime(
            selectedDay.year,
            selectedDay.month,
            selectedDay.day,
          );
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }

  Widget _buildSelectedDayReminders() {
    final reminders = _remindersByDate[_selectedDay] ?? [];
    final dateStr = DateFormat('EEEE d \'de\' MMMM', 'es').format(_selectedDay);

    if (reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin recordatorios',
              style: AppTypography.h2.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No hay recordatorios para $dateStr',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(child: Text(dateStr, style: AppTypography.h2)),
              _buildDaySummary(reminders),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              return _buildReminderItem(reminders[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDaySummary(List<Reminder> reminders) {
    final pending =
        reminders.where((r) => r.status == ReminderStatus.pending).length;
    final done = reminders.where((r) => r.status == ReminderStatus.done).length;

    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        if (pending > 0)
          Chip(
            label: Text('$pending pendientes'),
            backgroundColor: AppColors.primary.withOpacity(0.1),
            labelStyle: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        if (done > 0)
          Chip(
            label: Text('$done completados'),
            backgroundColor: AppColors.success.withOpacity(0.1),
            labelStyle: TextStyle(
              fontSize: 12,
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
      ],
    );
  }

  Widget _buildReminderItem(Reminder reminder) {
    final isDone = reminder.status == ReminderStatus.done;

    return Opacity(
      opacity: isDone ? 0.6 : 1.0,
      child: AppCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        onTap: () {
          // TODO: Navegar a detalle
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
                  Text(
                    reminder.title,
                    style:
                        isDone
                            ? AppTypography.bodyBold.copyWith(
                              decoration: TextDecoration.lineThrough,
                            )
                            : AppTypography.bodyBold,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reminder.time,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        Icons.pets,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Luna', // Mock
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isDone)
              Icon(Icons.check_circle, color: AppColors.success, size: 24)
            else if (reminder.isOverdue)
              Icon(Icons.warning_amber, color: AppColors.error, size: 24),
          ],
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

  void _goToToday() {
    setState(() {
      final now = DateTime.now();
      _focusedDay = DateTime(now.year, now.month, now.day);
      _selectedDay = _focusedDay;
    });
  }
}
