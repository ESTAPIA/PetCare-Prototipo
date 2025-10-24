import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/common/app_card.dart';
import '../../data/mock_reminders.dart';
import '../../models/reminder.dart';
import '../../data/mock_pets.dart';
import '../../models/pet.dart';
import '../pets/pet_detail_screen.dart';
import '../pets/pet_new_screen.dart';

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
    // Cargar inmediatamente sin esperar
    _loadPets();
  }

  /// Cargar mascotas desde el repositorio
  Future<void> _loadPets() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Nielsen H1: Visibilidad del estado con delay mínimo
      await Future.delayed(const Duration(milliseconds: 300));
      
      final pets = await MockPetsRepository.getAllPets();
      
      if (!mounted) return;
      
      setState(() {
        _pets = pets;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      // Mostrar error si falla
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar mascotas: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener próximo recordatorio
    final nextReminder = MockRemindersRepository.getNextReminder();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Ver todas las notificaciones
            },
            tooltip: 'Notificaciones',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPets,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SALUDO USUARIO
              _buildWelcomeBanner(),

              const SizedBox(height: AppSpacing.lg),

              // SECCIÓN 1: MIS MASCOTAS
              _buildSectionHeader('Mis Mascotas', icon: Icons.pets),
              const SizedBox(height: AppSpacing.sm),
              _buildPetsSection(),

              const SizedBox(height: AppSpacing.xl),

              // SECCIÓN 2: PRÓXIMO RECORDATORIO
              _buildSectionHeader('Próximo recordatorio', icon: Icons.alarm),
              const SizedBox(height: AppSpacing.sm),
              _buildNextReminderSection(nextReminder),

              const SizedBox(height: AppSpacing.xl),

              // SECCIÓN 3: ACCESOS RÁPIDOS
              _buildSectionHeader('Acceso rápido', icon: Icons.dashboard),
              const SizedBox(height: AppSpacing.sm),
              _buildQuickAccessSection(),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  /// Banner de bienvenida
  Widget _buildWelcomeBanner() {
    final hour = DateTime.now().hour;
    String greeting = 'Buenos días';
    IconData greetingIcon = Icons.wb_sunny;
    
    if (hour >= 12 && hour < 19) {
      greeting = 'Buenas tardes';
      greetingIcon = Icons.wb_twilight;
    } else if (hour >= 19 || hour < 6) {
      greeting = 'Buenas noches';
      greetingIcon = Icons.nightlight_round;
    }

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(greetingIcon, color: Colors.white, size: 32),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppTypography.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '¿Cómo están tus mascotas hoy?',
                  style: AppTypography.body.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construir encabezado de sección
  Widget _buildSectionHeader(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(title, style: AppTypography.h2),
        ],
      ),
    );
  }

  /// Construir sección de mascotas (horizontal scroll)
  Widget _buildPetsSection() {
    // Loading state
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: SizedBox(
          height: 140,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Cargando mascotas...',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Empty state
    if (_pets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: AppCard(
          child: Column(
            children: [
              Icon(Icons.pets, size: 48, color: AppColors.primary),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Aún no tienes mascotas',
                style: AppTypography.bodyBold,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '¡Agrega tu primera compañera para comenzar!',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PetNewScreen(),
                      fullscreenDialog: true,
                    ),
                  );
                  if (result == true) {
                    _loadPets();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar mascota'),
              ),
            ],
          ),
        ),
      );
    }

    // Lista de mascotas
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _pets.length + 1, // +1 para el botón de agregar
        itemBuilder: (context, index) {
          if (index == _pets.length) {
            return _buildAddPetCard();
          }
          return _buildPetCard(_pets[index]);
        },
      ),
    );
  }

  /// Card de mascota individual
  Widget _buildPetCard(Pet pet) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: () async {
          // Importar la pantalla de detalle
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetDetailScreen(petId: pet.id),
            ),
          );
          if (result == true) {
            _loadPets();
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary,
              child: Text(
                pet.inicial,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              pet.nombre,
              style: AppTypography.bodyBold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              pet.especie.displayName,
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
      width: 120,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PetNewScreen(),
              fullscreenDialog: true,
            ),
          );
          if (result == true) {
            _loadPets();
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Agregar',
              style: AppTypography.bodyBold.copyWith(
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Nueva',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
              ),
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

  /// Sección de acceso rápido
  Widget _buildQuickAccessSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  title: 'Ver todas',
                  subtitle: 'mis mascotas',
                  icon: Icons.pets,
                  color: AppColors.primary,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Función próximamente'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildQuickAccessCard(
                  title: 'Recordatorios',
                  subtitle: 'programados',
                  icon: Icons.calendar_today,
                  color: AppColors.info,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Usa el menú inferior'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  title: 'Veterinarias',
                  subtitle: 'cercanas',
                  icon: Icons.local_hospital,
                  color: AppColors.error,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Usa el menú inferior'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildQuickAccessCard(
                  title: 'Consulta',
                  subtitle: 'veterinaria',
                  icon: Icons.chat_bubble_outline,
                  color: AppColors.success,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Usa el menú inferior'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card de acceso rápido
  Widget _buildQuickAccessCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.bodyBold,
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
