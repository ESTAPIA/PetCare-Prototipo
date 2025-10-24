import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/mock_pets.dart';
import '../../models/pet.dart';
import '../../widgets/common/empty_state.dart';
import 'pet_new_screen.dart';

/// SCR-PET-LIST: Pantalla de lista de mascotas (PROC-001)
/// 
/// Funcionalidades:
/// - Listar todas las mascotas registradas
/// - Navegación a detalle de mascota (tap)
/// - Navegación a crear nueva mascota (FAB)
/// - Estados: loading, empty, populated, error
/// 
/// Tokens de diseño aplicados:
/// - Tipografía: H1 (título), Body-Bold (nombre), Caption (descripción)
/// - Color: Primary (FAB), Text-Primary, Text-Secondary
/// - Espaciado: md (16dp padding), sm (8dp separación)
/// - Componentes: ListTile, Card, EmptyState, FAB
class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  List<Pet> _pets = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  /// Carga las mascotas desde el repositorio
  /// 
  /// Incluye delay de 500ms para simular carga de red
  /// (Heurística 1 de Nielsen: Visibilidad del estado del sistema)
  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Simular delay de red (500ms) - Heurística 1: feedback visual
      await Future.delayed(const Duration(milliseconds: 500));
      
      final pets = await MockPetsRepository.getAllPets();
      
      if (mounted) {
        setState(() {
          _pets = pets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'No se pudieron cargar las mascotas';
          _isLoading = false;
        });
      }
    }
  }

  /// Navega a la pantalla de detalle de mascota
  /// 
  /// PLACEHOLDER: Implementar cuando se complete PASO D
  void _navigateToPetDetail(Pet pet) {
    // TODO PASO D: Reemplazar con navegación real
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Detalle de ${pet.nombre} (Disponible en PASO D)',
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

  /// Navega a la pantalla de crear nueva mascota
  /// 
  /// Abre formulario modal y recarga lista si se creó mascota
  Future<void> _navigateToCreatePet() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const PetNewScreen(),
        fullscreenDialog: true, // Muestra X en lugar de <-
      ),
    );
    
    // Si se creó una mascota, recargar la lista
    if (result == true && mounted) {
      _loadPets();
    }
  }

  /// Construye un ListTile para una mascota
  /// 
  /// Especificaciones:
  /// - Avatar circular con inicial del nombre
  /// - Nombre en Body-Bold (14sp, bold)
  /// - Descripción corta en Caption (12sp, secondary color)
  /// - Chevron derecha (visual de navegación)
  /// - Área táctil >= 72dp altura (ListTile estándar)
  Widget _buildPetTile(Pet pet) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm / 2, // 4dp vertical
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        // Avatar con inicial del nombre
        leading: CircleAvatar(
          radius: 24, // 48dp diámetro
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            pet.inicial,
            style: AppTypography.bodyBold.copyWith(
              color: AppColors.primary,
              fontSize: 18,
            ),
          ),
        ),
        // Nombre de la mascota
        title: Text(
          pet.nombre,
          style: AppTypography.bodyBold,
        ),
        // Descripción corta (ej. "Perra mestiza, 3 años")
        subtitle: Text(
          pet.descripcionCorta,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        // Chevron de navegación
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.primary,
          size: 24,
        ),
        onTap: () => _navigateToPetDetail(pet),
      ),
    );
  }

  /// Construye el estado de carga
  /// 
  /// Centrado con CircularProgressIndicator
  /// (Heurística 1: Visibilidad del estado del sistema)
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.md),
          Text(
            'Cargando mascotas...',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }

  /// Construye el estado vacío
  /// 
  /// Usa EmptyState widget reutilizable
  /// - Ícono de mascota (pets)
  /// - Mensaje claro
  /// - Instrucción opcional
  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.pets,
      message: 'Aún no tienes mascotas registradas',
      instruction: 'Comienza agregando tu primera mascota usando el botón +',
    );
  }

  /// Construye el estado de error
  /// 
  /// Incluye botón de reintentar
  /// (Heurística 9: Ayudar a los usuarios a reconocer, diagnosticar y recuperarse de errores)
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage,
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _loadPets,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 4, // 12dp vertical
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la lista de mascotas
  /// 
  /// ListView con separación entre ítems
  Widget _buildPetList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: _pets.length,
      itemBuilder: (context, index) {
        return _buildPetTile(_pets[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con título H1
      appBar: AppBar(
        title: Text(
          'Mis Mascotas',
          style: AppTypography.h1,
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      
      // Body con estados condicionales
      body: _isLoading
          ? _buildLoadingState()
          : _hasError
              ? _buildErrorState()
              : _pets.isEmpty
                  ? _buildEmptyState()
                  : _buildPetList(),
      
      // FAB siempre visible (recomendación aprobada)
      // Tokens: Primary color, elevación 6dp, radio 16dp
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        tooltip: 'Agregar nueva mascota', // Accesibilidad
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }
}
