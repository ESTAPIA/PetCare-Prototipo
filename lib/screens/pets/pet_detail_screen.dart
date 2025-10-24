import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/pet.dart';
import '../../data/mock_pets.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';

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
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadPet();
  }

  /// Cargar mascota desde repositorio
  Future<void> _loadPet() async {
    final pet = await MockPetsRepository.getPetById(widget.petId);
    if (mounted) {
      setState(() {
        _pet = pet;
      });
    }
  }

  /// Navegar a pantalla de edición
  /// 
  /// PLACEHOLDER: Implementar cuando se complete PASO E
  void _navigateToEdit() {
    // TODO PASO E: Implementar navegación real
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => PetEditScreen(pet: _pet!),
    //     fullscreenDialog: true,
    //   ),
    // );
    // if (result == true) _loadPet(); // Recargar después de editar
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Editar ${_pet!.nombre} (Disponible en PASO E)',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Mostrar diálogo de confirmación para eliminar
  /// 
  /// Heurística 9: Prevención de errores - confirmación antes de acción destructiva
  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar a ${_pet!.nombre}?'),
        content: Text(
          'Esta acción no se puede deshacer. Se eliminarán todos los datos de ${_pet!.nombre}.',
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

  /// Eliminar mascota del repositorio
  /// 
  /// Heurística 10: Feedback claro de éxito/error
  Future<void> _deletePet() async {
    setState(() => _isDeleting = true);

    try {
      final success = await MockPetsRepository.deletePet(widget.petId);

      if (!mounted) return;

      if (success) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('${_pet!.nombre} eliminado exitosamente'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );

        // Regresar con true para indicar que se eliminó (recarga lista)
        Navigator.pop(context, true);
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
    // Manejo de mascota no encontrada
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

    // Pantalla de detalle normal
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
