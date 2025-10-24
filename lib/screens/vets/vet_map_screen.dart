import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../data/models/veterinaria.dart';
import '../../data/mock/mock_veterinarias.dart';
import '../../services/favorites_service.dart';
import 'vet_detail_screen.dart';

/// SCR-VET-MAP: Mapa y lista de veterinarias
/// PROC-004: Veterinarias Cercanas
/// 
/// Objetivo: Mostrar veterinarias cercanas en mapa y lista con filtros
class VetMapScreen extends StatefulWidget {
  /// Contexto desde donde se abrió la pantalla
  /// null = desde tab Veterinarias
  /// 'chat' = desde consulta (ChatActiveScreen)
  final String? sourceContext;

  const VetMapScreen({super.key, this.sourceContext});

  @override
  State<VetMapScreen> createState() => _VetMapScreenState();
}

class _VetMapScreenState extends State<VetMapScreen> {
  bool _showMap = true; // true: mapa, false: lista
  List<Veterinaria> _veterinarias = [];
  
  // PASO E: Favoritos
  Set<String> _favoriteIds = {};
  final _favoritesService = FavoritesService();
  
  // Filtros activos
  bool _filtroFavoritos = false;
  bool _filtro24h = false;
  bool _filtroPerros = false;
  bool _filtroGatos = false;

  @override
  void initState() {
    super.initState();
    _loadVeterinarias();
    _loadFavorites();
  }
  
  /// Carga los IDs de favoritos desde el servicio
  Future<void> _loadFavorites() async {
    await _favoritesService.initialize();
    final favorites = await _favoritesService.getFavorites();
    setState(() {
      _favoriteIds = favorites;
    });
  }

  /// Carga las veterinarias ordenadas por distancia
  void _loadVeterinarias() {
    setState(() {
      _veterinarias = MockVeterinarias.getVeterinariasPorDistancia();
    });
  }

  /// Aplica los filtros activos sobre las veterinarias
  void _aplicarFiltros() {
    List<Veterinaria> resultado = MockVeterinarias.getVeterinariasPorDistancia();
    
    // Filtro Favoritos
    if (_filtroFavoritos) {
      resultado = resultado.where((vet) => _favoriteIds.contains(vet.id)).toList();
    }
    
    // Filtro 24 horas
    if (_filtro24h) {
      resultado = resultado.where((vet) => vet.emergencias24h).toList();
    }
    
    // Filtro Perros
    if (_filtroPerros) {
      resultado = resultado.where((vet) => vet.atiende('Perros')).toList();
    }
    
    // Filtro Gatos
    if (_filtroGatos) {
      resultado = resultado.where((vet) => vet.atiende('Gatos')).toList();
    }
    
    setState(() {
      _veterinarias = resultado;
    });
  }

  /// Limpia todos los filtros activos
  void _limpiarFiltros() {
    setState(() {
      _filtroFavoritos = false;
      _filtro24h = false;
      _filtroPerros = false;
      _filtroGatos = false;
    });
    _loadVeterinarias();
  }

  /// Cuenta la cantidad de filtros activos
  int _contarFiltrosActivos() {
    int count = 0;
    if (_filtroFavoritos) count++;
    if (_filtro24h) count++;
    if (_filtroPerros) count++;
    if (_filtroGatos) count++;
    return count;
  }
  
  /// Toggle favorito desde la card de la lista
  Future<void> _toggleFavoriteInCard(String vetId) async {
    final wasAdded = await _favoritesService.toggleFavorite(vetId);
    
    // Actualizar estado local
    setState(() {
      if (wasAdded) {
        _favoriteIds.add(vetId);
      } else {
        _favoriteIds.remove(vetId);
      }
    });
    
    // Feedback al usuario
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasAdded 
              ? 'Agregado a favoritos' 
              : 'Eliminado de favoritos',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
    
    // Si el filtro de favoritos está activo, re-aplicar filtros
    if (_filtroFavoritos) {
      _aplicarFiltros();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veterinarias'),
        automaticallyImplyLeading: widget.sourceContext != null, // Mostrar back si viene de otra pantalla
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
            icon: _contarFiltrosActivos() > 0
                ? Badge.count(
                    count: _contarFiltrosActivos(),
                    child: const Icon(Icons.filter_list),
                  )
                : const Icon(Icons.filter_list),
            onPressed: _limpiarFiltros,
            tooltip: _contarFiltrosActivos() > 0 ? 'Limpiar filtros' : 'Filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner contextual si viene desde consulta
          if (widget.sourceContext == 'chat')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Buscando desde tu consulta',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Volver al chat',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
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
              selected: _filtroFavoritos,
              avatar: Icon(
                Icons.star,
                size: 18,
                color: _filtroFavoritos ? AppColors.surface : null,
              ),
              onSelected: (selected) {
                setState(() {
                  _filtroFavoritos = selected;
                });
                _aplicarFiltros();
              },
            ),
            const SizedBox(width: AppSpacing.sm),
            FilterChip(
              label: const Text('24 horas'),
              selected: _filtro24h,
              onSelected: (selected) {
                setState(() {
                  _filtro24h = selected;
                });
                _aplicarFiltros();
              },
            ),
            const SizedBox(width: AppSpacing.sm),
            FilterChip(
              label: const Text('Perros'),
              selected: _filtroPerros,
              onSelected: (selected) {
                setState(() {
                  _filtroPerros = selected;
                });
                _aplicarFiltros();
              },
            ),
            const SizedBox(width: AppSpacing.sm),
            FilterChip(
              label: const Text('Gatos'),
              selected: _filtroGatos,
              onSelected: (selected) {
                setState(() {
                  _filtroGatos = selected;
                });
                _aplicarFiltros();
              },
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
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      itemCount: _veterinarias.length > 5 ? 5 : _veterinarias.length,
                      itemBuilder: (context, index) {
                        final vet = _veterinarias[index];
                        return _buildVetMiniCard(
                          vet: vet,
                          name: vet.nombre,
                          distance: vet.distanciaFormateada(
                            MockVeterinarias.userLat,
                            MockVeterinarias.userLng,
                          ),
                          rating: vet.rating,
                        );
                      },
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
    if (_veterinarias.isEmpty) {
      // Mensaje específico para filtro de favoritos vacío
      if (_filtroFavoritos) {
        return EmptyState(
          icon: Icons.star_outline,
          message: 'Aún no tienes veterinarias favoritas',
          instruction: 'Explora y marca veterinarias como favoritas',
          actionLabel: 'Ver todas',
          onAction: () {
            setState(() {
              _filtroFavoritos = false;
            });
            _loadVeterinarias();
          },
        );
      }
      
      return EmptyState(
        icon: Icons.local_hospital_outlined,
        message: _contarFiltrosActivos() > 0
            ? 'No hay veterinarias con estos filtros'
            : 'No hay veterinarias cercanas',
        instruction: _contarFiltrosActivos() > 0
            ? 'Intenta con menos filtros o límpialo todos'
            : 'Intenta activar tu ubicación',
        actionLabel: _contarFiltrosActivos() > 0 ? 'Limpiar filtros' : null,
        onAction: _contarFiltrosActivos() > 0 ? _limpiarFiltros : null,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: _veterinarias.length,
      itemBuilder: (context, index) {
        final vet = _veterinarias[index];
        return _buildVetCard(
          vet: vet,
          name: vet.nombre,
          address: vet.direccion,
          distance: vet.distanciaFormateada(
            MockVeterinarias.userLat,
            MockVeterinarias.userLng,
          ),
          rating: vet.rating,
          reviews: vet.reviewsCount,
          isOpen: vet.estaAbierto(),
          isFavorite: _favoriteIds.contains(vet.id),
        );
      },
    );
  }

  /// Mini card de veterinaria (para vista mapa)
  Widget _buildVetMiniCard({
    required Veterinaria vet,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VetDetailScreen(veterinariaId: vet.id),
            ),
          );
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
    required Veterinaria vet,
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VetDetailScreen(veterinariaId: vet.id),
          ),
        );
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
                onPressed: () => _toggleFavoriteInCard(vet.id),
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
