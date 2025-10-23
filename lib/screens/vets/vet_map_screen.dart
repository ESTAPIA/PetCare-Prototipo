import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';

/// SCR-VET-MAP: Mapa y lista de veterinarias
/// PROC-004: Veterinarias Cercanas
/// 
/// Objetivo: Mostrar veterinarias cercanas en mapa y lista con filtros
class VetMapScreen extends StatefulWidget {
  const VetMapScreen({super.key});

  @override
  State<VetMapScreen> createState() => _VetMapScreenState();
}

class _VetMapScreenState extends State<VetMapScreen> {
  bool _showMap = true; // true: mapa, false: lista

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veterinarias'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _showMap = !_showMap;
              });
            },
            tooltip: _showMap ? 'Ver lista' : 'Ver mapa',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Mostrar bottom sheet con filtros
            },
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros rápidos
          _buildQuickFilters(),
          
          // Vista de mapa o lista
          Expanded(
            child: _showMap ? _buildMapView() : _buildListView(),
          ),
        ],
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
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('Favoritos'),
              selected: false,
              avatar: const Icon(Icons.star, size: 18),
              onSelected: (selected) {},
            ),
            const SizedBox(width: AppSpacing.sm),
            FilterChip(
              label: const Text('24 horas'),
              selected: false,
              onSelected: (selected) {},
            ),
            const SizedBox(width: AppSpacing.sm),
            FilterChip(
              label: const Text('Perros'),
              selected: false,
              onSelected: (selected) {},
            ),
            const SizedBox(width: AppSpacing.sm),
            FilterChip(
              label: const Text('Gatos'),
              selected: false,
              onSelected: (selected) {},
            ),
          ],
        ),
      ),
    );
  }

  /// Vista de mapa (placeholder)
  Widget _buildMapView() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Stack(
        children: [
          // Placeholder del mapa
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 80,
                  color: AppColors.textDisabled,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Vista de mapa',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Google Maps se integrará aquí',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
          
          // Lista compacta abajo (sliding panel)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusLg),
                  topRight: Radius.circular(AppSpacing.radiusLg),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle para arrastrar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Lista horizontal de veterinarias
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      children: [
                        _buildVetMiniCard(
                          name: 'Veterinaria San Marcos',
                          distance: '0.8 km',
                          rating: 4.5,
                        ),
                        _buildVetMiniCard(
                          name: 'Clínica Veterinaria Patitas',
                          distance: '1.2 km',
                          rating: 4.8,
                        ),
                        _buildVetMiniCard(
                          name: 'VetCenter 24H',
                          distance: '2.1 km',
                          rating: 4.3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Vista de lista
  Widget _buildListView() {
    // TODO: Conectar con datos mock
    final hasVets = true;
    
    if (!hasVets) {
      return const EmptyState(
        icon: Icons.local_hospital_outlined,
        message: 'No hay veterinarias cercanas',
        instruction: 'Intenta ajustar los filtros o activar tu ubicación',
      );
    }
    
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: [
        _buildVetCard(
          name: 'Veterinaria San Marcos',
          address: 'Av. Universitaria 123, San Miguel',
          distance: '0.8 km',
          rating: 4.5,
          reviews: 120,
          isOpen: true,
          isFavorite: false,
        ),
        _buildVetCard(
          name: 'Clínica Veterinaria Patitas',
          address: 'Jr. Los Pinos 456, Pueblo Libre',
          distance: '1.2 km',
          rating: 4.8,
          reviews: 85,
          isOpen: true,
          isFavorite: true,
        ),
        _buildVetCard(
          name: 'VetCenter 24H',
          address: 'Av. La Marina 789, San Miguel',
          distance: '2.1 km',
          rating: 4.3,
          reviews: 200,
          isOpen: true,
          isFavorite: false,
        ),
        _buildVetCard(
          name: 'Hospital Veterinario PetCare',
          address: 'Av. Brasil 321, Magdalena',
          distance: '3.5 km',
          rating: 4.6,
          reviews: 150,
          isOpen: false,
          isFavorite: false,
        ),
      ],
    );
  }

  /// Mini card de veterinaria (para vista mapa)
  Widget _buildVetMiniCard({
    required String name,
    required String distance,
    required double rating,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        onTap: () {
          // TODO: Navegar a detalle
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: AppTypography.bodyBold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 2),
                Text(
                  distance,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.star, size: 14, color: AppColors.warning),
                const SizedBox(width: 2),
                Text(
                  rating.toStringAsFixed(1),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Card de veterinaria (para vista lista)
  Widget _buildVetCard({
    required String name,
    required String address,
    required String distance,
    required double rating,
    required int reviews,
    required bool isOpen,
    required bool isFavorite,
  }) {
    return AppCard(
      onTap: () {
        // TODO: Navegar a detalle de veterinaria
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Ícono
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  Icons.local_hospital,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              
              const SizedBox(width: AppSpacing.md),
              
              // Nombre y estado
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTypography.bodyBold),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isOpen ? AppColors.success : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOpen ? 'Abierto' : 'Cerrado',
                          style: AppTypography.caption.copyWith(
                            color: isOpen ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Favorito
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_outline,
                  color: isFavorite ? AppColors.warning : AppColors.textSecondary,
                ),
                onPressed: () {
                  // TODO: Toggle favorito
                },
                tooltip: 'Favorito',
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Dirección
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  address,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xs),
          
          // Rating, distancia y reviews
          Row(
            children: [
              Icon(Icons.star, size: 16, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                ' ($reviews)',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(Icons.directions_walk, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                distance,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
