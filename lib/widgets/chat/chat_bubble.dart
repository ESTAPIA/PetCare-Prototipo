import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/chat_message.dart';

/// Widget de burbuja de chat para mensajes del usuario y del bot
/// Diseño diferenciado según el emisor (isUser)
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(MessageAction)? onActionTap;

  const ChatBubble({
    super.key,
    required this.message,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar del bot (solo para mensajes del bot)
          if (!message.isUser) ...[
            _buildBotAvatar(),
            const SizedBox(width: AppSpacing.xs),
          ],

          // Burbuja de mensaje
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Contenedor de la burbuja
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width *
                        (message.isUser ? 0.75 : 0.85),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppSpacing.radiusMd),
                      topRight: const Radius.circular(AppSpacing.radiusMd),
                      bottomLeft: Radius.circular(
                        message.isUser ? AppSpacing.radiusMd : AppSpacing.radiusSm,
                      ),
                      bottomRight: Radius.circular(
                        message.isUser ? AppSpacing.radiusSm : AppSpacing.radiusMd,
                      ),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: AppTypography.body.copyWith(
                      color: message.isUser
                          ? AppColors.onPrimary
                          : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),

                // Botones de acción (solo para mensajes del bot)
                if (!message.isUser &&
                    message.actions != null &&
                    message.actions!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _buildActionButtons(context),
                ],

                // Timestamp (opcional, muy pequeño)
                const SizedBox(height: 2),
                Text(
                  _formatTime(message.timestamp),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textDisabled,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Espacio para avatar del usuario (mantener alineación)
          if (message.isUser) ...[
            const SizedBox(width: AppSpacing.xs),
            const SizedBox(width: 32), // Espacio equivalente al avatar
          ],
        ],
      ),
    );
  }

  /// Avatar del bot
  Widget _buildBotAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.pets,
        size: 18,
        color: AppColors.primary,
      ),
    );
  }

  /// Botones de acción para mensajes del bot
  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: message.actions!.map((action) {
        return _buildActionButton(context, action);
      }).toList(),
    );
  }

  /// Botón individual de acción
  Widget _buildActionButton(BuildContext context, MessageAction action) {
    // Determinar estilo según tipo de acción
    final isEmergency = action.type == ActionType.searchVet &&
        message.text.contains('ALERTA');

    if (isEmergency) {
      // Botón de emergencia (rojo, destacado)
      return FilledButton.icon(
        onPressed: () => onActionTap?.call(action),
        icon: const Icon(Icons.emergency, size: 18),
        label: Text(action.label),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          minimumSize: const Size(0, 36),
          textStyle: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      // Botón normal (outlined)
      return OutlinedButton(
        onPressed: () => onActionTap?.call(action),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary, width: 1.5),
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          minimumSize: const Size(0, 36),
          textStyle: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(action.label),
      );
    }
  }

  /// Formatear timestamp a HH:MM
  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
