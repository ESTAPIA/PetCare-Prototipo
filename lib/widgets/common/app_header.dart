import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

/// Header consistente para pantallas con avatar opcional y acción
/// Usado en Dashboard, listas y pantallas principales
class AppHeader extends StatelessWidget {
  /// Título principal del header
  final String title;
  
  /// Subtítulo opcional (ej. "3 mascotas registradas")
  final String? subtitle;
  
  /// URL de la imagen del avatar (opcional)
  final String? avatarUrl;
  
  /// Ícono del avatar si no hay imagen (opcional)
  final IconData? avatarIcon;
  
  /// Widget de acción a la derecha (ej. IconButton)
  final Widget? action;
  
  /// Callback cuando se toca el avatar (opcional)
  final VoidCallback? onAvatarTap;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    this.avatarIcon,
    this.action,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar opcional (izquierda)
          if (avatarUrl != null || avatarIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: GestureDetector(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null && avatarIcon != null
                      ? Icon(
                          avatarIcon,
                          color: AppColors.onPrimary,
                          size: 24,
                        )
                      : null,
                ),
              ),
            ),

          // Título y subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.h2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Acción opcional (derecha)
          if (action != null)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: action!,
            ),
        ],
      ),
    );
  }
}
