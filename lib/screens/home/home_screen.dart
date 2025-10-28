import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Pet> _pets = [];
  bool _isLoading = true;
  static const String _kOnboardingCompletedKey = 'onboarding_completed';
  
  // Estado de recordatorios
  Reminder? _nextReminder;
  bool _isLoadingReminder = true;
  
  // Estado de estadísticas
  List<Reminder> _allReminders = [];
  
  // ScrollController para resetear scroll al presionar tab Inicio
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Cargar mascotas, recordatorios y verificar onboarding
    _initializeScreen();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Método público: Resetear scroll y recargar datos
  /// 
  /// Observación del profesor: Al presionar tab Inicio desde otra pantalla,
  /// debe scrollear al top y actualizar datos
  void resetToTop() {
    // Animar scroll al inicio
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    
    // Recargar datos
    _initializeScreen();
  }

  /// Inicializar pantalla: cargar datos y verificar primera vez
  /// 
  /// Heurística 8: Ayuda y documentación - onboarding para nuevos usuarios
  Future<void> _initializeScreen() async {
    // Cargar mascotas, recordatorios y estadísticas en paralelo
    await Future.wait([
      _loadPets(),
      _loadNextReminder(),
      _loadStatistics(),
    ]);
    
    // Verificar si es primera vez (después de cargar para saber si hay mascotas)
    if (!mounted) return;
    await _checkAndShowOnboarding();
  }

  /// Verificar si es la primera vez y mostrar onboarding
  /// 
  /// Solo se muestra una vez, se guarda flag en SharedPreferences
  Future<void> _checkAndShowOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool(_kOnboardingCompletedKey) ?? false;
      
      // Si ya vio el onboarding, no mostrar
      if (hasSeenOnboarding) return;
      
      // Si no hay mascotas, mostrar onboarding
      if (_pets.isEmpty && mounted) {
        // Esperar un momento para que la pantalla esté lista
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (!mounted) return;
        
        await _showOnboardingDialog();
        
        // Marcar como completado
        await prefs.setBool(_kOnboardingCompletedKey, true);
      }
    } catch (e) {
      // Si falla, no mostrar onboarding (no es crítico)
      debugPrint('Error checking onboarding: $e');
    }
  }

  /// Cargar próximo recordatorio pendiente
  /// 
  /// Heurística 1: Visibilidad del estado - mostrar loading, error o recordatorio
  Future<void> _loadNextReminder() async {
    if (!mounted) return;
    
    setState(() => _isLoadingReminder = true);
    
    try {
      // Delay mínimo para visibilidad del loading
      await Future.delayed(const Duration(milliseconds: 300));
      
      final reminder = MockRemindersRepository.getNextPendingReminder();
      
      if (!mounted) return;
      
      setState(() {
        _nextReminder = reminder;
        _isLoadingReminder = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoadingReminder = false;
      });
      
      // Mostrar error si falla
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar recordatorios: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Marcar recordatorio como completado
  /// 
  /// Heurística 3: Control del usuario - permitir marcar como hecho
  /// Heurística 1: Feedback claro - confirmación visual
  Future<void> _markReminderAsCompleted(Reminder reminder) async {
    try {
      // Marcar como completado en el repositorio
      final success = await MockRemindersRepository.markAsDone(reminder.id);
      
      if (!success) {
        throw Exception('No se pudo marcar como completado');
      }
      
      if (!mounted) return;
      
      // Mostrar feedback de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('✓ ${reminder.title} marcado como completado'),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Recargar siguiente recordatorio
      await _loadNextReminder();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al completar recordatorio: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Posponer recordatorio a una nueva fecha
  /// 
  /// Heurística 3: Control y libertad - usuario elige nueva fecha
  /// Heurística 5: Prevención de errores - solo fechas futuras válidas
  Future<void> _postponeReminder(Reminder reminder) async {
    // Abrir DatePicker para seleccionar nueva fecha
    final newDate = await showDatePicker(
      context: context,
      initialDate: reminder.dateTime.add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Posponer hasta',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      locale: const Locale('es'),
    );
    
    if (newDate == null) return; // Usuario canceló
    
    try {
      // Actualizar fecha en el repositorio
      final success = await MockRemindersRepository.snoozeReminder(
        reminder.id,
        newDate,
      );
      
      if (!success) {
        throw Exception('No se pudo posponer el recordatorio');
      }
      
      if (!mounted) return;
      
      // Mostrar feedback con nueva fecha
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.schedule, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '📅 ${reminder.title} pospuesto al ${DateFormat('d MMM', 'es').format(newDate)}',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Recargar siguiente recordatorio
      await _loadNextReminder();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al posponer recordatorio: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Cargar estadísticas de recordatorios
  /// 
  /// Obtiene todos los recordatorios para calcular métricas
  Future<void> _loadStatistics() async {
    try {
      final reminders = MockRemindersRepository.getAllReminders();
      
      if (!mounted) return;
      
      setState(() {
        _allReminders = reminders;
      });
    } catch (e) {
      // Si falla, continuar sin estadísticas (no crítico)
      debugPrint('Error al cargar estadísticas: $e');
    }
  }

  /// Contar recordatorios completados este mes
  /// 
  /// Filtra por status=done y fecha en mes actual
  int get _completedThisMonth {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);

    return _allReminders.where((r) {
      return r.status == ReminderStatus.done &&
             r.completedAt != null &&
             r.completedAt!.isAfter(thisMonth) &&
             r.completedAt!.isBefore(nextMonth);
    }).length;
  }

  /// Contar recordatorios pendientes
  /// 
  /// Filtra por status=pending
  int get _pendingReminders {
    return _allReminders.where((r) {
      return r.status == ReminderStatus.pending;
    }).length;
  }

  /// Mostrar diálogo con lista de recordatorios pendientes
  /// 
  /// Heurística 1: Visibilidad - todos los pendientes de un vistazo
  /// Heurística 3: Control - acción rápida "Marcar como hecho"
  /// Heurística 3: Control y libertad - diálogo se mantiene abierto para marcar múltiples
  void _showNotificationsDialog() {
    // Filtrar solo pendientes
    final pending = _allReminders
        .where((r) => r.status == ReminderStatus.pending)
        .toList();
    
    // Ordenar por fecha (más cercanos primero)
    pending.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.notifications_active, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Recordatorios pendientes',
                  style: AppTypography.h2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${pending.length}',
                  style: AppTypography.bodyBold.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          content: pending.isEmpty
              ? _buildNoNotificationsContent()
              : _buildNotificationsList(
                  pending,
                  onMarkCompleted: (reminder) async {
                    // Marcar en repositorio
                    final success = await MockRemindersRepository.markAsDone(
                      reminder.id,
                    );
                    
                    if (!success) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Error al marcar como completado',
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                      return;
                    }
                    
                    // Actualizar lista dentro del diálogo
                    setDialogState(() {
                      pending.removeWhere((r) => r.id == reminder.id);
                    });
                    
                    // Recargar datos globales (fuera del diálogo)
                    _loadNextReminder();
                    _loadStatistics();
                    
                    // Mostrar feedback
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  '✓ ${reminder.title} marcado como completado',
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Contenido cuando no hay notificaciones
  /// 
  /// Heurística 8: Diseño minimalista - mensaje claro y positivo
  Widget _buildNoNotificationsContent() {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '¡Todo al día!',
            style: AppTypography.h2,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'No tienes recordatorios pendientes',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Lista de recordatorios pendientes con acciones
  /// 
  /// Heurística 3: Control del usuario - acción rápida desde notificación
  Widget _buildNotificationsList(
    List<Reminder> pending, {
    required void Function(Reminder) onMarkCompleted,
  }) {
    return SizedBox(
      width: double.maxFinite,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: pending.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final reminder = pending[index];
          
          // Buscar mascota asociada
          final pet = _pets.firstWhere(
            (p) => p.id == reminder.petId,
            orElse: () => Pet(
              id: 'unknown',
              nombre: 'Mascota',
              especie: PetSpecies.otro,
            ),
          );
          
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  reminder.type.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            title: Text(
              '${reminder.title} - ${pet.nombre}',
              style: AppTypography.bodyBold.copyWith(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${_formatDate(reminder.date)}, ${reminder.time}',
              style: AppTypography.caption,
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 24,
              ),
              onPressed: () => onMarkCompleted(reminder),
              tooltip: 'Marcar como hecho',
            ),
          );
        },
      ),
    );
  }

  /// Mostrar diálogo de bienvenida primera vez
  /// 
  /// Heurística 8: Ayuda y documentación
  /// Heurística 1: Visibilidad - explica claramente el propósito
  Future<void> _showOnboardingDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false, // No cerrar tocando fuera
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pets,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                '¡Bienvenido a PetCare!',
                style: AppTypography.h1.copyWith(fontSize: 22),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tu compañero para el cuidado de tus mascotas',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Características principales
              _buildOnboardingFeature(
                icon: Icons.pets,
                title: 'Gestiona tus mascotas',
                description: 'Registra información completa de cada una',
              ),
              const SizedBox(height: AppSpacing.md),
              
              _buildOnboardingFeature(
                icon: Icons.calendar_month,
                title: 'Planes de cuidado',
                description: 'Plantillas automáticas según tipo de mascota',
              ),
              const SizedBox(height: AppSpacing.md),
              
              _buildOnboardingFeature(
                icon: Icons.notifications_active,
                title: 'Recordatorios',
                description: 'No olvides vacunas, medicamentos o citas',
              ),
              const SizedBox(height: AppSpacing.md),
              
              _buildOnboardingFeature(
                icon: Icons.location_on,
                title: 'Veterinarias cercanas',
                description: 'Encuentra clínicas en tu zona',
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Mensaje de inicio
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Comienza registrando tu primera mascota',
                        style: AppTypography.bodyBold.copyWith(
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Cerrar diálogo
              
              // Abrir pantalla de crear mascota
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const PetNewScreen(),
                  fullscreenDialog: true,
                ),
              );
              
              // Si creó mascota, recargar lista
              if (result == true && mounted) {
                _loadPets();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_circle_outline, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Agregar mi primera mascota',
                  style: AppTypography.button,
                ),
              ],
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.md,
        ),
      ),
    );
  }

  /// Widget de característica en onboarding
  Widget _buildOnboardingFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyBold.copyWith(fontSize: 14),
              ),
              Text(
                description,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Badge.count(
              count: _pendingReminders,
              isLabelVisible: _pendingReminders > 0,
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: _showNotificationsDialog,
                tooltip: 'Notificaciones',
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _loadPets(),
            _loadNextReminder(),
            _loadStatistics(),
          ]);
        },
        child: SingleChildScrollView(
          controller: _scrollController,
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
              _buildNextReminderSection(),

              const SizedBox(height: AppSpacing.xl),

              // SECCIÓN 3: RESUMEN ESTADÍSTICO
              _buildSectionHeader('Resumen', icon: Icons.analytics_outlined),
              const SizedBox(height: AppSpacing.sm),
              _buildStatisticsSection(),

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
      width: 140,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
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
              backgroundImage: pet.imagePath != null
                  ? AssetImage(pet.imagePath!)
                  : null,
              child: pet.imagePath == null
                  ? Text(
                      pet.inicial,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : null,
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
      width: 140,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
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

  /// Construir sección de próximo recordatorio con estados funcionales
  /// 
  /// Heurística 1: Visibilidad del estado (loading, sin recordatorios, con recordatorio)
  /// Heurística 3: Control del usuario (botones "Hecho" y "Posponer" funcionales)
  Widget _buildNextReminderSection() {
    // Estado 1: Cargando
    if (_isLoadingReminder) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: AppCard(
          child: Center(
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Cargando recordatorios...',
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

    // Estado 2: Sin recordatorios pendientes
    if (_nextReminder == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: AppCard(
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: AppColors.success,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '¡Todo al día!',
                style: AppTypography.bodyBold.copyWith(fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'No tienes recordatorios pendientes',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Estado 3: Mostrar recordatorio con botones funcionales
    final reminder = _nextReminder!;
    
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
            // Título con emoji del tipo de recordatorio
            Row(
              children: [
                Text(
                  reminder.type.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
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
            
            // Fecha y hora
            Text(
              '${_formatDate(reminder.date)}, ${reminder.time}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Botones de acción funcionales
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _markReminderAsCompleted(reminder),
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
                    onPressed: () => _postponeReminder(reminder),
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

  /// Sección de estadísticas rápidas
  /// 
  /// Muestra métricas clave en cards horizontales (solo lectura)
  /// Heurística 1: Visibilidad del estado del sistema
  /// Heurística 8: Diseño estético y minimalista
  Widget _buildStatisticsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          // 1. Total de mascotas
          _buildStatCard(
            emoji: '🐾',
            value: '${_pets.length}',
            label: 'Mascotas',
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          
          // 2. Completados este mes
          _buildStatCard(
            emoji: '✅',
            value: '$_completedThisMonth',
            label: 'Completados\neste mes',
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.sm),
          
          // 3. Pendientes
          _buildStatCard(
            emoji: '📅',
            value: '$_pendingReminders',
            label: 'Pendientes',
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  /// Tarjeta individual de estadística
  /// 
  /// Heurística 1: Visibilidad del estado - muestra métricas clave
  /// Heurística 8: Diseño estético y minimalista
  Widget _buildStatCard({
    required String emoji,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Emoji + número
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  value,
                  style: AppTypography.h1.copyWith(
                    color: color,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // Label descriptivo
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
