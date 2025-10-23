import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';

/// SCR-REM-LIST: Lista de recordatorios
/// PROC-003: Recordatorios
/// 
/// Objetivo: Mostrar agenda de recordatorios pendientes con acciones rápidas
class ReminderListScreen extends StatelessWidget {
  const ReminderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // TODO: Navegar a vista calendario
            },
            tooltip: 'Vista calendario',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Mostrar filtros
            },
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros rápidos (chips)
          _buildQuickFilters(),
          
          // Lista de recordatorios
          Expanded(
            child: _buildRemindersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navegar a crear recordatorio
        },
        child: const Icon(Icons.add),
        tooltip: 'Agregar recordatorio',
      ),
    );
  }

  /// Construir filtros rápidos
  Widget _buildQuickFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('Todos'),
              selected: true,
              onSelected: (selected) {},
            ),
            const SizedBox(width: AppSpacing.sm),
            FilterChip(
              label: const Text('Hoy'),
              selected: false,
              onSelected: (selected) {},
            ),
            const SizedBox(width: AppSpacing.sm),
            FilterChip(
              label: const Text('Esta semana'),
              selected: false,
              onSelected: (selected) {},
            ),
            const SizedBox(width: AppSpacing.sm),
            FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Vencidos'),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '2',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              selected: false,
              onSelected: (selected) {},
            ),
          ],
        ),
      ),
    );
  }

  /// Construir lista de recordatorios
  Widget _buildRemindersList() {
    // TODO: Conectar con datos mock
    final hasReminders = true; // Cambiar según datos
    
    if (!hasReminders) {
      return const EmptyState(
        icon: Icons.notifications_outlined,
        message: 'No tienes recordatorios',
        instruction: 'Crea un plan de cuidado o agrega recordatorios personalizados',
        actionLabel: 'Crear recordatorio',
        // onAction: () => navegar a crear,
      );
    }
    
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: [
        // Grupo: Hoy
        _buildGroupHeader('Hoy'),
        _buildReminderCard(
          title: 'Vacuna Rabia - Luna',
          time: '10:00 AM',
          petName: 'Luna',
          icon: Icons.vaccines,
          iconColor: AppColors.warning,
          isOverdue: false,
        ),
        _buildReminderCard(
          title: 'Desparasitación - Max',
          time: '3:00 PM',
          petName: 'Max',
          icon: Icons.medication,
          iconColor: AppColors.info,
          isOverdue: false,
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Grupo: Mañana
        _buildGroupHeader('Mañana'),
        _buildReminderCard(
          title: 'Control veterinario - Luna',
          time: '9:00 AM',
          petName: 'Luna',
          icon: Icons.local_hospital,
          iconColor: AppColors.secondary,
          isOverdue: false,
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Grupo: Próximos 7 días
        _buildGroupHeader('Próximos 7 días'),
        _buildReminderCard(
          title: 'Corte de uñas - Max',
          time: 'Vie 15, 2:00 PM',
          petName: 'Max',
          icon: Icons.cut,
          iconColor: AppColors.primary,
          isOverdue: false,
        ),
      ],
    );
  }

  /// Header de grupo de fechas
  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTypography.bodyBold.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// Card de recordatorio individual
  Widget _buildReminderCard({
    required String title,
    required String time,
    required String petName,
    required IconData icon,
    required Color iconColor,
    required bool isOverdue,
  }) {
    return AppCard(
      onTap: () {
        // TODO: Navegar a detalle de recordatorio
      },
      child: Row(
        children: [
          // Ícono
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyBold),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Chip(
                      label: Text(petName),
                      labelStyle: AppTypography.caption,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Botones de acción
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.check_circle_outline, color: AppColors.success),
                onPressed: () {
                  // TODO: Marcar como hecho
                },
                tooltip: 'Hecho',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(AppSpacing.xs),
              ),
              IconButton(
                icon: Icon(Icons.schedule, color: AppColors.warning),
                onPressed: () {
                  // TODO: Posponer
                },
                tooltip: 'Posponer',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(AppSpacing.xs),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
