import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/pet.dart';
import '../../data/mock_pets.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';
import 'pet_edit_screen.dart';

/// SCR-PET-DETAIL: Pantalla de detalle de mascota (PROC-001)
/// 
/// Funcionalidades:
/// - Ver información completa de la mascota
/// - Acciones: Editar (placeholder PASO E), Eliminar (con confirmación)
/// - Manejo de campos opcionales (null-safe)
/// - Navegación de regreso con resultado (para recargar lista)
/// 
/// Heurísticas de Nielsen aplicadas:
/// - H1: Visibilidad del estado (toda la info visible claramente)
/// - H4: Consistencia (patrón similar a vet_detail_screen)
/// - H6: Reconocimiento vs recuerdo (labels claros en cada campo)
/// - H8: Diseño estético y minimalista (info organizada en cards)
/// - H9: Recuperación de errores (confirmación antes de eliminar)
class PetDetailScreen extends StatefulWidget {
  final String petId;

  const PetDetailScreen({
    super.key,
    required this.petId,
  });

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  Pet? _pet;
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadPet();
  }

  /// Cargar mascota desde repositorio
  /// 
  /// Heurística 1: Visibilidad del estado - feedback durante carga
  Future<void> _loadPet() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Simular delay de red para visibilidad (300ms)
      await Future.delayed(const Duration(milliseconds: 300));
      
      final pet = await MockPetsRepository.getPetById(widget.petId);
      
      if (!mounted) return;
      
      setState(() {
        _pet = pet;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Navegar a pantalla de edición
  /// 
  /// Abre formulario de edición y recarga datos si se guardaron cambios
  Future<void> _navigateToEdit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PetEditScreen(pet: _pet!),
        fullscreenDialog: true,
      ),
    );
    
    // Si se guardaron cambios, recargar datos
    if (result == true && mounted) {
      _loadPet();
    }
  }

  /// Mostrar diálogo de confirmación para eliminar
  /// 
  /// Heurística 5: Prevención de errores - confirmación antes de acción destructiva
  /// Heurística 3: Control y libertad - informa que se puede deshacer
  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar a ${_pet!.nombre}?'),
        content: Text(
          'Se eliminará a ${_pet!.nombre} y todos sus datos. Tendrás 4 segundos para deshacer esta acción.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _deletePet();
    }
  }

  /// Eliminar mascota con opción de deshacer
  /// 
  /// Heurística 3: Control y libertad - permite deshacer acción destructiva
  /// Heurística 10: Feedback claro de éxito/error
  Future<void> _deletePet() async {
    setState(() => _isDeleting = true);

    try {
      // 1. Guardar copia de la mascota antes de eliminar
      final petToDelete = _pet!;
      
      // 2. Eliminar del repositorio
      final success = await MockPetsRepository.deletePet(widget.petId);

      if (!mounted) return;

      if (success) {
        // 3. Navegar de regreso inmediatamente
        Navigator.pop(context, true);

        // 4. Mostrar SnackBar con acción "Deshacer"
        // El SnackBar se muestra en el contexto de la pantalla anterior
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('${petToDelete.nombre} eliminado'),
                ),
              ],
            ),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'DESHACER',
              textColor: Colors.white,
              onPressed: () async {
                // 5. Restaurar mascota si usuario toca "Deshacer"
                final restored = await MockPetsRepository.createPet(petToDelete);
                
                if (restored) {
                  // Mostrar confirmación de restauración
                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.undo, color: Colors.white, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text('${petToDelete.nombre} restaurado'),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  // Error al restaurar
                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          const Expanded(
                            child: Text('Error al restaurar mascota'),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
        );
      } else {
        throw Exception('No se pudo eliminar la mascota');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isDeleting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Error al eliminar: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// Construir header con avatar y nombre
  /// 
  /// Heurística 1: Visibilidad - información más importante primero
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar grande con inicial
          CircleAvatar(
            radius: 40, // 80dp diámetro
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              _pet!.inicial,
              style: AppTypography.h1.copyWith(
                color: AppColors.primary,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Nombre
          Text(
            _pet!.nombre,
            style: AppTypography.h1.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Descripción corta
          Text(
            _pet!.descripcionCorta,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Fecha de registro (caption)
          Text(
            'Registrado el ${DateFormat('dd/MM/yyyy', 'es').format(_pet!.fechaCreacion)}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Card de información básica
  /// 
  /// Heurística 6: Reconocimiento vs recuerdo - labels explícitos
  Widget _buildInfoBasicaCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información básica',
            style: AppTypography.h2,
          ),
          const SizedBox(height: AppSpacing.md),

          // Especie
          _buildInfoRow(
            label: 'Especie',
            value: '${_pet!.especie.emoji} ${_pet!.especie.displayName}',
          ),
          const Divider(height: AppSpacing.lg),

          // Raza
          _buildInfoRow(
            label: 'Raza',
            value: _pet!.raza ?? 'No especificada',
            isOptional: _pet!.raza == null,
          ),
          const Divider(height: AppSpacing.lg),

          // Sexo
          _buildInfoRow(
            label: 'Sexo',
            value: _pet!.sexo != null
                ? '${_pet!.sexo!.emoji} ${_pet!.sexo!.displayName}'
                : '⚪ No especifica',
            isOptional: _pet!.sexo == null,
          ),
          const Divider(height: AppSpacing.lg),

          // Edad
          _buildInfoRow(
            label: 'Edad',
            value: _pet!.edad != null
                ? '${_pet!.edad} ${_pet!.edad == 1 ? "año" : "años"}'
                : 'Fecha de nacimiento no registrada',
            isOptional: _pet!.edad == null,
          ),
          const Divider(height: AppSpacing.lg),

          // Peso
          _buildInfoRow(
            label: 'Peso',
            value: _pet!.pesoKg != null
                ? '${_pet!.pesoKg!.toStringAsFixed(1)} kg'
                : 'No registrado',
            isOptional: _pet!.pesoKg == null,
          ),
        ],
      ),
    );
  }

  /// Fila de información (label + value)
  /// 
  /// Heurística 8: Diseño estético y minimalista
  Widget _buildInfoRow({
    required String label,
    required String value,
    bool isOptional = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTypography.bodyBold.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // Value
        Expanded(
          child: Text(
            value,
            style: AppTypography.body.copyWith(
              color: isOptional ? AppColors.textSecondary : AppColors.textPrimary,
              fontStyle: isOptional ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  /// Card de notas (solo si existen)
  /// 
  /// Heurística 8: Minimalismo - solo mostrar si hay contenido
  Widget _buildNotasCard() {
    if (_pet!.notas == null || _pet!.notas!.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notes,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Notas',
                style: AppTypography.h2,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _pet!.notas!,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }

  /// Card de información adicional (fechas)
  /// 
  /// Transparencia y auditoría
  Widget _buildInfoAdicionalCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información adicional',
            style: AppTypography.h2,
          ),
          const SizedBox(height: AppSpacing.md),

          // Fecha de registro
          _buildInfoRow(
            label: 'Registrado',
            value: DateFormat('dd/MM/yyyy HH:mm', 'es').format(_pet!.fechaCreacion),
          ),
          const Divider(height: AppSpacing.lg),

          // Última actualización
          _buildInfoRow(
            label: 'Actualizado',
            value: DateFormat('dd/MM/yyyy HH:mm', 'es').format(_pet!.fechaActualizacion),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Estado 1: Cargando
    // Heurística 1: Visibilidad del estado - feedback visual durante operación
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cargando...'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        backgroundColor: AppColors.background,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Cargando detalles de la mascota...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Estado 2: Mascota no encontrada
    // Heurística 9: Ayudar a reconocer y recuperarse de errores
    if (_pet == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        backgroundColor: AppColors.background,
        body: EmptyState(
          icon: Icons.error_outline,
          message: 'Mascota no encontrada',
          instruction: 'El ID proporcionado no corresponde a ninguna mascota registrada',
          actionLabel: 'Volver',
          onAction: () => Navigator.pop(context),
        ),
      );
    }

    // Estado 3: Pantalla de detalle normal
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pet!.nombre,
          style: AppTypography.h1,
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          // Botón Editar
          // Heurística 4: Consistencia (patrón estándar de acciones)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _isDeleting ? null : _navigateToEdit,
            tooltip: 'Editar',
            color: AppColors.primary,
          ),

          // Botón Eliminar
          // Heurística 9: Prevención de errores (confirmación antes de eliminar)
          IconButton(
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                    ),
                  )
                : const Icon(Icons.delete),
            onPressed: _isDeleting ? null : _showDeleteConfirmation,
            tooltip: 'Eliminar',
            color: AppColors.error,
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header (Avatar + Nombre + Descripción)
            _buildHeader(),

            // Padding para el resto del contenido
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  // 2. Card: Información básica
                  _buildInfoBasicaCard(),

                  const SizedBox(height: AppSpacing.md),

                  // 3. Card: Notas (solo si existen)
                  _buildNotasCard(),

                  const SizedBox(height: AppSpacing.md),

                  // 4. Card: Información adicional
                  _buildInfoAdicionalCard(),

                  // Espaciado final
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
