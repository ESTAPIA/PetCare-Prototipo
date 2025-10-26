import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/mock_plan_templates.dart';
import '../../models/plan_template.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';
import 'plan_template_detail_screen.dart';
import '../../data/mock_pets.dart';
import '../../models/pet.dart';

/// SCR-PLAN-TEMPLATE-LIST: Catálogo de plantillas
/// PROC-002: Plan de Cuidado Rápido
class PlanTemplateListScreen extends StatefulWidget {
  final String? sourceContext; // 'chat' si viene desde consulta
  final String? filterCategory; // Categoría para filtrar (ej. 'Vacunas')

  const PlanTemplateListScreen({
    super.key,
    this.sourceContext,
    this.filterCategory,
  });

  @override
  State<PlanTemplateListScreen> createState() => _PlanTemplateListScreenState();
}

class _PlanTemplateListScreenState extends State<PlanTemplateListScreen> {
  List<Pet> _availablePets = [];
  Pet? _selectedPet;
  bool _isLoadingPets = true;
  bool _isLoading = true;
  List<PlanTemplate> _templates = [];

  @override
  void initState() {
    super.initState();
    _loadPetsAndTemplates();
  }

  /// Verificar si hay mascotas y mostrar modal si no existen
  Future<void> _checkAndShowNoPetsModal() async {
    if (_availablePets.isEmpty) {
      final shouldNavigate = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Sin mascotas registradas'),
          content: const Text(
            'Necesitas registrar una mascota primero para crear un plan de cuidado.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Registrar mascota'),
            ),
          ],
        ),
      );

      if (shouldNavigate == true && mounted) {
        Navigator.pushNamed(context, '/pet/new').then((_) {
          // Recargar mascotas después de registrar
          _loadPetsAndTemplates();
        });
      } else if (shouldNavigate == false && mounted) {
        // Si cancela, volver atrás
        Navigator.pop(context);
      }
    }
  }

  /// Cargar mascotas y luego plantillas
  Future<void> _loadPetsAndTemplates() async {
    setState(() => _isLoadingPets = true);

    final pets = await MockPetsRepository.getAllPets();

    setState(() {
      _availablePets = pets;
      _selectedPet = pets.isNotEmpty ? pets.first : null;
      _isLoadingPets = false;
    });

    // Mostrar modal si no hay mascotas
    if (pets.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndShowNoPetsModal();
      });
    } else {
      _loadTemplates();
    }
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);

    // Simular carga de datos
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _templates = MockPlanTemplatesRepository.getTemplates(
        species: _selectedPet?.especie.displayName,
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan de cuidado rápido'),
        automaticallyImplyLeading: widget.sourceContext != null,
      ),
      body: Column(
        children: [
          // Banner contextual si viene desde chat
          if (widget.sourceContext == 'chat') _buildContextBanner(),

          // Chip selector de mascota
          _buildPetSelector(),

          // Lista de plantillas
          Expanded(
            child:
                _isLoading
                    ? _buildLoadingState()
                    : _templates.isEmpty
                    ? _buildEmptyState()
                    : _buildTemplateList(),
          ),
        ],
      ),
    );
  }

  /// Selector de mascota activa (chips dinámicos)
  Widget _buildPetSelector() {
    // Nielsen H1: Mostrar loading mientras carga pets
    if (_isLoadingPets) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Nielsen H10: Mensaje claro si no hay mascotas
    if (_availablePets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Card(
          color: AppColors.info.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Crea una mascota para ver plantillas personalizadas',
                    style: AppTypography.body.copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Nielsen H6: Reconocimiento - mostrar pets reales
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: _availablePets.map((pet) {
          final isSelected = _selectedPet?.id == pet.id;
          return ChoiceChip(
            label: Text('${pet.nombre} (${pet.especie.displayName})'),
            avatar: CircleAvatar(
              backgroundColor: isSelected ? AppColors.primary : Colors.transparent,
              child: Text(
                pet.inicial,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.onPrimary : AppColors.primary,
                ),
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedPet = pet);
                _loadTemplates();
              }
            },
          );
        }).toList(),
      ),
    );
  }

  /// Banner contextual cuando se navega desde chat
  Widget _buildContextBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Buscando desde tu consulta',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Volver al chat'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  /// Lista de plantillas
  Widget _buildTemplateList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _templates.length,
      itemBuilder: (context, index) {
        final template = _templates[index];
        return _buildTemplateCard(template);
      },
    );
  }

  /// Card de plantilla individual
  Widget _buildTemplateCard(PlanTemplate template) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlanTemplateDetailScreen(template: template),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Ícono según tipo
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  _getTemplateIcon(template.id),
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(template.name, style: AppTypography.bodyBold),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${template.tasks.length} tareas',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            template.description,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            children:
                template.species.map((species) {
                  return Chip(
                    label: Text(species, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.surfaceVariant,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getTemplateIcon(String templateId) {
    switch (templateId) {
      case 'plan-tmpl-001':
        return Icons.vaccines;
      case 'plan-tmpl-002':
        return Icons.medication;
      case 'plan-tmpl-003':
        return Icons.favorite;
      case 'plan-tmpl-004':
        return Icons.local_hospital;
      default:
        return Icons.calendar_today;
    }
  }

  /// Estado de carga (skeleton)
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 3,
      itemBuilder: (context, index) {
        return AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 60, color: AppColors.surfaceVariant),
              const SizedBox(height: AppSpacing.sm),
              Container(
                height: 14,
                width: double.infinity,
                color: AppColors.surfaceVariant,
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                height: 14,
                width: 150,
                color: AppColors.surfaceVariant,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Estado vacío
  Widget _buildEmptyState() {
    final petName = _selectedPet?.nombre ?? 'esta mascota';
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: EmptyState(
        icon: Icons.calendar_today,
        message: 'No hay plantillas disponibles',
        instruction:
            'No se encontraron plantillas para $petName. Prueba con otra mascota o crea recordatorios personalizados.',
      ),
    );
  }
}
