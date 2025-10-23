import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';

/// SCR-HOME-DASH: Dashboard principal
/// PROC-001: Gestión de Mascotas
/// 
/// Objetivo: Mostrar acceso rápido a mascotas, próximo recordatorio y acciones frecuentes
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            
            // SECCIÓN 1: MIS MASCOTAS
            _buildSectionHeader('Mis Mascotas'),
            _buildPetsSection(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // SECCIÓN 2: PRÓXIMO RECORDATORIO
            _buildSectionHeader('Próximo recordatorio'),
            _buildNextReminderSection(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // SECCIÓN 3: ACCESOS RÁPIDOS
            _buildSectionHeader('Accesos rápidos'),
            _buildQuickActionsSection(),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  /// Construir encabezado de sección
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Text(
        title,
        style: AppTypography.h2,
      ),
    );
  }

  /// Construir sección de mascotas (horizontal scroll)
  Widget _buildPetsSection() {
    // TODO: Conectar con datos mock
    final hasPets = false; // Cambiar a true cuando haya datos
    
    if (!hasPets) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: EmptyState(
          icon: Icons.pets,
          message: 'Aún no tienes mascotas',
          instruction: '¡Agrega tu primera compañera!',
          actionLabel: 'Agregar mascota',
          // onAction: () => Navigator.push(...),
        ),
      );
    }
    
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          _buildPetCard('Luna', 'Perra mestiza', Icons.pets),
          _buildPetCard('Max', 'Gato persa', Icons.pets),
          _buildAddPetCard(),
        ],
      ),
    );
  }

  /// Card de mascota individual
  Widget _buildPetCard(String name, String species, IconData icon) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        onTap: () {
          // TODO: Navegar a detalle de mascota
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary,
              child: Icon(icon, color: AppColors.onPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              name,
              style: AppTypography.bodyBold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              species,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Card para agregar nueva mascota
  Widget _buildAddPetCard() {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        onTap: () {
          // TODO: Navegar a crear mascota
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Agregar',
              style: AppTypography.label.copyWith(
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Construir sección de próximo recordatorio
  Widget _buildNextReminderSection() {
    // TODO: Conectar con datos mock
    final hasReminder = false; // Cambiar a true cuando haya datos
    
    if (!hasReminder) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: AppCard(
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 40,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'No tienes recordatorios pendientes. ¡Todo al día!',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.vaccines, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Vacuna Rabia - Luna',
                  style: AppTypography.bodyBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Hoy, 10:00 AM',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check),
                  label: const Text('Hecho'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: BorderSide(color: AppColors.success),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.schedule),
                  label: const Text('Posponer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    side: BorderSide(color: AppColors.warning),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construir sección de accesos rápidos
  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          _buildQuickActionChip(
            label: 'Productos y Notas',
            icon: Icons.shopping_bag_outlined,
            onTap: () {
              // TODO: Navegar a productos
            },
          ),
          _buildQuickActionChip(
            label: 'Perfil y Ayuda',
            icon: Icons.person_outline,
            onTap: () {
              // TODO: Navegar a perfil
            },
          ),
          _buildQuickActionChip(
            label: 'Buscar veterinarias',
            icon: Icons.local_hospital_outlined,
            onTap: () {
              // TODO: Cambiar a tab Veterinarias
            },
          ),
        ],
      ),
    );
  }

  /// Chip de acción rápida
  Widget _buildQuickActionChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
