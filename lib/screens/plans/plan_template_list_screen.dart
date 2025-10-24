import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/mock_plan_templates.dart';
import '../../models/plan_template.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';
import 'plan_template_detail_screen.dart';

/// SCR-PLAN-TEMPLATE-LIST: Catálogo de plantillas
/// PROC-002: Plan de Cuidado Rápido
class PlanTemplateListScreen extends StatefulWidget {
  const PlanTemplateListScreen({super.key});

  @override
  State<PlanTemplateListScreen> createState() => _PlanTemplateListScreenState();
}

class _PlanTemplateListScreenState extends State<PlanTemplateListScreen> {
  String? _selectedSpecies = 'Perro'; // Mock: mascota activa es perro
  bool _isLoading = true;
  List<PlanTemplate> _templates = [];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);

    // Simular carga de datos
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _templates = MockPlanTemplatesRepository.getTemplates(
        species: _selectedSpecies,
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan de cuidado rápido'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
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

  /// Selector de mascota activa (chip)
  Widget _buildPetSelector() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const Text('Filtrar por: ', style: TextStyle(fontSize: 14)),
          const SizedBox(width: AppSpacing.sm),
          ChoiceChip(
            label: const Text('Luna (Perro)'),
            avatar: const CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.pets, size: 16),
            ),
            selected: _selectedSpecies == 'Perro',
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedSpecies = 'Perro');
                _loadTemplates();
              }
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          ChoiceChip(
            label: const Text('Max (Gato)'),
            avatar: const CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.pets, size: 16),
            ),
            selected: _selectedSpecies == 'Gato',
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedSpecies = 'Gato');
                _loadTemplates();
              }
            },
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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: EmptyState(
        icon: Icons.calendar_today,
        message: 'No hay plantillas disponibles',
        instruction:
            'No se encontraron plantillas para ${_selectedSpecies ?? "esta mascota"}. Prueba con otra mascota o crea recordatorios personalizados.',
      ),
    );
  }
}
