import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../data/mock_reminders.dart';
import '../../models/reminder.dart';
import '../../data/mock_pets.dart';
import '../../models/pet.dart';
import '../../navigation/app_routes.dart';

/// SCR-HOME-DASH: Dashboard principal
/// PROC-001: Gestión de Mascotas
///
/// Objetivo: Mostrar acceso rápido a mascotas, próximo recordatorio y acciones frecuentes
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Pet> _pets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  /// Cargar mascotas desde el repositorio
  Future<void> _loadPets() async {
    setState(() => _isLoading = true);
    
    // Nielsen H1: Visibilidad del estado con delay mínimo
    await Future.delayed(const Duration(milliseconds: 500));
    
    final pets = await MockPetsRepository.getAllPets();
    
    setState(() {
      _pets = pets;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtener próximo recordatorio
    final nextReminder = MockRemindersRepository.getNextReminder();

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
            _buildNextReminderSection(nextReminder),

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
      child: Text(title, style: AppTypography.h2),
    );
  }

  /// Construir sección de mascotas (horizontal scroll)
  Widget _buildPetsSection() {
    // Nielsen H1: Mostrar loading state mientras carga
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Nielsen H10: EmptyState con instrucción clara
    if (_pets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: EmptyState(
          icon: Icons.pets,
          message: 'Aún no tienes mascotas',
          instruction: '¡Agrega tu primera compañera!',
          actionLabel: 'Agregar mascota',
          onAction: () async {
            final result = await Navigator.pushNamed(
              context,
              AppRoutes.petNew,
            );
            if (result == true) {
              _loadPets(); // Recargar después de crear
            }
          },
        ),
      );
    }

    // Nielsen H6: Reconocimiento - mostrar pets con datos reales
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          ..._pets.map((pet) => _buildPetCard(pet)),
          _buildAddPetCard(),
        ],
      ),
    );
  }

  /// Card de mascota individual
  Widget _buildPetCard(Pet pet) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        onTap: () async {
          // Nielsen H4: Consistencia - mismo patrón de navegación
          final result = await Navigator.pushNamed(
            context,
            AppRoutes.petDetail,
            arguments: pet.id,
          );
          // Recargar si hubo cambios (edición o eliminación)
          if (result == true) {
            _loadPets();
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary,
              child: Text(
                pet.inicial,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              pet.nombre,
              style: AppTypography.bodyBold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              pet.descripcionCorta,
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
        onTap: () async {
          // Nielsen H3: Control y libertad - permitir crear desde dashboard
          final result = await Navigator.pushNamed(
            context,
            AppRoutes.petNew,
          );
          if (result == true) {
            _loadPets(); // Recargar después de crear
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 48, color: AppColors.primary),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Agregar',
              style: AppTypography.label.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Construir sección de próximo recordatorio con datos reales
  Widget _buildNextReminderSection(Reminder? reminder) {
    if (reminder == null) {
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

    // Buscar el nombre de la mascota real
    final pet = _pets.firstWhere(
      (p) => p.id == reminder.petId,
      orElse: () => Pet(
        id: 'unknown',
        nombre: 'Mascota',
        especie: PetSpecies.otro,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(reminder.type.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${reminder.title} - ${pet.nombre}',
                    style: AppTypography.bodyBold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${_formatDate(reminder.date)}, ${reminder.time}',
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
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoy';
    } else if (dateOnly == tomorrow) {
      return 'Mañana';
    } else {
      return DateFormat('EEEE d MMM', 'es').format(date);
    }
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
              // TODO: PROC-005 - Navegar a productos
            },
          ),
          _buildQuickActionChip(
            label: 'Perfil y Ayuda',
            icon: Icons.person_outline,
            onTap: () {
              // TODO: Navegar a perfil (pendiente implementación)
            },
          ),
          _buildQuickActionChip(
            label: 'Buscar veterinarias',
            icon: Icons.local_hospital_outlined,
            onTap: () {
              // TODO: PROC-004 - Cambiar a tab Veterinarias
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
