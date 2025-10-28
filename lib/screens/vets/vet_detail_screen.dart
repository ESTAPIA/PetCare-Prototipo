import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_state.dart';
import '../../data/models/veterinaria.dart';
import '../../data/models/review.dart';
import '../../data/mock/mock_veterinarias.dart';
import '../../services/favorites_service.dart';

/// SCR-VET-DETAIL: Detalle de veterinaria
/// PROC-004: Veterinarias Cercanas - PASO D
/// 
/// Objetivo: Mostrar información completa de una veterinaria con acciones
class VetDetailScreen extends StatefulWidget {
  final String veterinariaId;

  const VetDetailScreen({
    super.key,
    required this.veterinariaId,
  });

  @override
  State<VetDetailScreen> createState() => _VetDetailScreenState();
}

class _VetDetailScreenState extends State<VetDetailScreen> {
  Veterinaria? _veterinaria;
  List<Review> _reviews = [];
  bool _isFavorite = false;
  bool _isLoading = true;
  bool _mostrarTodosHorarios = false;
  bool _mostrarTodasReviews = false;
  final _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Carga los datos de la veterinaria y sus reviews
  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    setState(() {
      _veterinaria = MockVeterinarias.getVeterinariaById(widget.veterinariaId);
      if (_veterinaria != null) {
        _reviews = MockVeterinarias.getReviewsForVet(widget.veterinariaId);
      }
      _isLoading = false;
    });
    
    // Cargar estado de favorito
    if (_veterinaria != null) {
      final isFav = await _favoritesService.isFavorite(widget.veterinariaId);
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  /// Toggle favorito: agrega o quita de favoritos
  Future<void> _toggleFavorite() async {
    if (_veterinaria == null) return;
    
    final previousState = _isFavorite;
    final newState = await _favoritesService.toggleFavorite(widget.veterinariaId);
    
    setState(() {
      _isFavorite = newState;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newState ? 'Agregado a favoritos' : 'Quitado de favoritos'),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () async {
              await _favoritesService.toggleFavorite(widget.veterinariaId);
              setState(() {
                _isFavorite = previousState;
              });
            },
          ),
        ),
      );
    }
  }

  /// Muestra diálogo de confirmación antes de llamar
  Future<void> _llamar() async {
    if (_veterinaria == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Llamar a la veterinaria?'),
        content: Text('Se abrirá el marcador para llamar a ${_veterinaria!.telefono}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Llamar'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      _ejecutarLlamada();
    }
  }

  /// Ejecuta la llamada telefónica
  Future<void> _ejecutarLlamada() async {
    if (_veterinaria == null) return;

    final Uri telUri = Uri(
      scheme: 'tel',
      path: _veterinaria!.telefono,
    );

    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        // Error C: Fallback con opción de copiar número
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No se pudo abrir el marcador. Intenta copiar el número'),
              action: SnackBarAction(
                label: 'Copiar',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _veterinaria!.telefono));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Teléfono copiado al portapapeles'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Error C: Fallback con opción de copiar número
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo abrir el marcador. Intenta copiar el número'),
            action: SnackBarAction(
              label: 'Copiar',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _veterinaria!.telefono));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Teléfono copiado al portapapeles'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Maneja la acción de navegar a la veterinaria
  Future<void> _comoLlegar() async {
    if (_veterinaria == null) return;

    final Uri geoUri = Uri(
      scheme: 'geo',
      path: '${_veterinaria!.latitude},${_veterinaria!.longitude}',
    );

    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      } else {
        // Error D: Modal con opción de instalar o copiar dirección
        if (mounted) {
          _mostrarDialogoMapasNoDisponible();
        }
      }
    } catch (e) {
      // Error D: Modal con opción de instalar o copiar dirección
      if (mounted) {
        _mostrarDialogoMapasNoDisponible();
      }
    }
  }

  /// Muestra diálogo cuando Google Maps no está disponible
  Future<void> _mostrarDialogoMapasNoDisponible() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Google Maps no disponible'),
        content: const Text('Para usar navegación necesitas Google Maps instalado'),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _veterinaria!.direccion));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dirección copiada al portapapeles'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text('Copiar dirección'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Capturar messenger antes del await
              final messenger = ScaffoldMessenger.of(context);
              
              // Abrir Play Store (Android) o App Store (iOS)
              final storeUrl = Platform.isAndroid
                  ? Uri.parse('https://play.google.com/store/apps/details?id=com.google.android.apps.maps')
                  : Uri.parse('https://apps.apple.com/app/id585027354');
              
              try {
                await launchUrl(storeUrl, mode: LaunchMode.externalApplication);
              } catch (e) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo abrir la tienda de aplicaciones'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Instalar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading skeleton
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Veterinaria'),
        ),
        body: const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              SkeletonCard(height: 150), // Header
              SizedBox(height: AppSpacing.md),
              SkeletonCard(height: 80),  // Botones
              SizedBox(height: AppSpacing.md),
              SkeletonCard(height: 120), // Info
              SizedBox(height: AppSpacing.md),
              SkeletonCard(height: 200), // Horarios
            ],
          ),
        ),
      );
    }
    
    // Manejo de veterinaria no encontrada
    if (_veterinaria == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: EmptyState(
          icon: Icons.error_outline,
          message: 'Veterinaria no encontrada',
          instruction: 'El ID proporcionado no corresponde a ninguna veterinaria',
          actionLabel: 'Volver',
          onAction: () => Navigator.pop(context),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _veterinaria!.nombre,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Favorito
          // H8: Minimalismo - solo funcionalidad real visible
          IconButton(
            icon: Icon(_isFavorite ? Icons.star : Icons.star_outline),
            onPressed: _toggleFavorite,
            tooltip: 'Favorito',
          ),
          // Botón "Compartir" eliminado (H5: Prevención de errores - no ofrecer opciones no funcionales)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header
            _buildHeader(),
            
            const SizedBox(height: AppSpacing.md),
            
            // 2. Botones de acción
            _buildActionButtons(),
            
            const SizedBox(height: AppSpacing.md),
            
            // 3. Información
            _buildInfoCard(),
            
            const SizedBox(height: AppSpacing.md),
            
            // 4. Horarios
            _buildHorariosCard(),
            
            const SizedBox(height: AppSpacing.md),
            
            // 5. Servicios
            _buildServiciosCard(),
            
            const SizedBox(height: AppSpacing.md),
            
            // 6. Especialidades
            _buildEspecialidadesCard(),
            
            const SizedBox(height: AppSpacing.md),
            
            // 7. Reviews
            _buildReviewsSection(),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  /// Construye el header con rating, distancia y estado
  Widget _buildHeader() {
    final distancia = _veterinaria!.distanciaFormateada(
      MockVeterinarias.userLat,
      MockVeterinarias.userLng,
    );
    final isOpen = _veterinaria!.estaAbierto();
    final horarioHoy = _veterinaria!.getHorarioHoy() ?? 'Cerrado';

    return AppCard(
      child: Column(
        children: [
          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStars(_veterinaria!.rating),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _veterinaria!.rating.toStringAsFixed(1),
                style: AppTypography.h2.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xs),
          
          // Reviews count
          Text(
            '${_veterinaria!.reviewsCount} reseñas',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Distancia y estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Distancia
              Row(
                children: [
                  Icon(
                    Icons.directions_walk,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    distancia,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              // Separador
              Container(
                height: 20,
                width: 1,
                color: AppColors.divider,
              ),
              
              // Estado
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 20,
                    color: isOpen ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOpen ? 'Abierto' : 'Cerrado',
                        style: AppTypography.bodyBold.copyWith(
                          color: isOpen ? AppColors.success : AppColors.error,
                        ),
                      ),
                      Text(
                        horarioHoy,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye los botones de acción (Llamar, Cómo llegar)
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Botón Llamar
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _llamar,
            icon: const Icon(Icons.phone),
            label: const Text('Llamar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
            ),
          ),
        ),
        
        const SizedBox(width: AppSpacing.md),
        
        // Botón Cómo llegar
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _comoLlegar,
            icon: const Icon(Icons.directions),
            label: const Text('Cómo llegar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.surface,
            ),
          ),
        ),
      ],
    );
  }

  /// Construye la card de información (dirección y teléfono)
  Widget _buildInfoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información',
            style: AppTypography.h2,
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Dirección
          _buildCopyableField(
            icon: Icons.location_on,
            label: 'Dirección',
            value: _veterinaria!.direccion,
            subtitle: _veterinaria!.ciudad,
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Teléfono
          _buildCopyableField(
            icon: Icons.phone,
            label: 'Teléfono',
            value: _veterinaria!.telefono,
          ),
        ],
      ),
    );
  }

  /// Widget para campo copiable con hint visual
  Widget _buildCopyableField({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copiado al portapapeles'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.content_copy,
                      size: 12,
                      color: AppColors.textDisabled,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(value, style: AppTypography.body),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Construye la card de horarios
  Widget _buildHorariosCard() {
    final diasSemana = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final hoy = DateTime.now().weekday - 1; // 0 = Lunes

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Horarios',
                style: AppTypography.h2,
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Tabla de horarios - mostrar solo hoy o todos
          ...(_mostrarTodosHorarios 
            ? diasSemana.asMap().entries 
            : diasSemana.asMap().entries.where((e) => e.key == hoy)
          ).map((entry) {
            final index = entry.key;
            final dia = entry.value;
            final horario = _veterinaria!.horarios[dia] ?? 'Cerrado';
            final isToday = index == hoy;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: isToday ? AppColors.primary.withValues(alpha: 0.1) : null,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dia,
                      style: isToday
                          ? AppTypography.bodyBold.copyWith(
                              color: AppColors.primary,
                            )
                          : AppTypography.body,
                    ),
                    Text(
                      horario,
                      style: isToday
                          ? AppTypography.bodyBold.copyWith(
                              color: AppColors.primary,
                            )
                          : AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                    ),
                  ],
                ),
              ),
            );
          }),
          
          // Botón expandir/colapsar
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _mostrarTodosHorarios = !_mostrarTodosHorarios;
                });
              },
              icon: Icon(_mostrarTodosHorarios ? Icons.expand_less : Icons.expand_more),
              label: Text(_mostrarTodosHorarios ? 'Ver menos' : 'Ver todos los días'),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la card de servicios
  Widget _buildServiciosCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_services,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Servicios',
                style: AppTypography.h2,
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Chips de servicios
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _veterinaria!.servicios.map((servicio) {
              return Chip(
                label: Text(servicio),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                labelStyle: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Construye la card de especialidades
  Widget _buildEspecialidadesCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pets,
                size: 20,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Especialidades',
                style: AppTypography.h2,
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Chips de especialidades
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _veterinaria!.especialidades.map((especialidad) {
              return Chip(
                label: Text(especialidad),
                backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                labelStyle: AppTypography.caption.copyWith(
                  color: AppColors.secondary,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Construye la sección de reviews
  Widget _buildReviewsSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rate_review,
                size: 20,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Reseñas',
                style: AppTypography.h2,
              ),
              const Spacer(),
              Text(
                '${_reviews.length}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Lista de reviews - mostrar solo 5 o todas
          if (_reviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'No hay reseñas aún',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else ...[
            ...(_mostrarTodasReviews 
              ? _reviews 
              : _reviews.take(5)
            ).map((review) => _buildReviewItem(review)),
            
            // Botón "Ver todas" si hay más de 5
            if (_reviews.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _mostrarTodasReviews = !_mostrarTodasReviews;
                      });
                    },
                    icon: Icon(_mostrarTodasReviews ? Icons.expand_less : Icons.expand_more),
                    label: Text(
                      _mostrarTodasReviews 
                        ? 'Ver menos' 
                        : 'Ver todas las reseñas (${_reviews.length})',
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// Construye un item de review
  Widget _buildReviewItem(Review review) {
    // Color del avatar basado en el hash del nombre
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.warning,
      Colors.purple,
      Colors.pink,
      Colors.indigo,
    ];
    final avatarColor = colors[review.avatarColorSeed.abs() % colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar con iniciales
              CircleAvatar(
                radius: 20,
                backgroundColor: avatarColor.withValues(alpha: 0.2),
                child: Text(
                  review.userInitials,
                  style: AppTypography.bodyBold.copyWith(
                    color: avatarColor,
                  ),
                ),
              ),
              
              const SizedBox(width: AppSpacing.sm),
              
              // Nombre y fecha
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: AppTypography.bodyBold,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _buildStars(review.rating, size: 14),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          review.fechaRelativa,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Comentario
          Text(
            review.comment,
            style: AppTypography.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Divider
          if (_reviews.last != review) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(),
          ],
        ],
      ),
    );
  }

  /// Helper para construir estrellas de rating
  Widget _buildStars(double rating, {double size = 20}) {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData iconData;
        if (index < fullStars) {
          iconData = Icons.star;
        } else if (index == fullStars && hasHalfStar) {
          iconData = Icons.star_half;
        } else {
          iconData = Icons.star_outline;
        }

        return Icon(
          iconData,
          size: size,
          color: AppColors.warning,
        );
      }),
    );
  }
}
