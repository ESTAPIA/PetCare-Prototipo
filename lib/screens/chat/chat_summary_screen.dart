import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/consulta.dart';
import '../../widgets/common/app_card.dart';
import '../../utils/topic_theme_helper.dart';
import 'chat_active_screen.dart';

/// SCR-CONS-SUMMARY: Pantalla de resumen de consulta finalizada
/// PROC-005: Consulta Express IA
/// 
/// Objetivo: Mostrar resumen de la consulta y acciones recomendadas
class ChatSummaryScreen extends StatelessWidget {
  final Consulta consulta;

  const ChatSummaryScreen({
    super.key,
    required this.consulta,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de Consulta'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _goToHome(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // Card de resumen
                _buildSummaryCard(context),

                const SizedBox(height: AppSpacing.xl),

                // Sección de acciones recomendadas
                if (consulta.recommendedActions.isNotEmpty) ...[
                  _buildRecommendedActionsSection(context),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Mensaje de confirmación
                _buildSuccessMessage(context),
              ],
            ),
          ),

          // Botones inferiores (sticky)
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  /// Card de resumen de la consulta
  Widget _buildSummaryCard(BuildContext context) {
    final theme = TopicThemeHelper.getTheme(consulta.topic);
    final duration = consulta.duration;

    return AppCard(
      child: Column(
        children: [
          // Ícono del topic
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme['color'].withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              theme['icon'],
              size: 32,
              color: theme['color'],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Topic
          Text(
            consulta.topic,
            style: AppTypography.h1.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.sm),

          // Pet name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                consulta.petName,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Divider
          Divider(color: AppColors.divider),

          const SizedBox(height: AppSpacing.md),

          // Información de duración y fecha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Duración
              Column(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDuration(duration),
                    style: AppTypography.bodyBold.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Duración',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),

              // Separador vertical
              Container(
                width: 1,
                height: 40,
                color: AppColors.divider,
              ),

              // Fecha
              Column(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(consulta.startTime),
                    style: AppTypography.bodyBold.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _formatTime(consulta.startTime),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Sección de acciones recomendadas
  Widget _buildRecommendedActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones recomendadas',
          style: AppTypography.h2,
        ),
        const SizedBox(height: AppSpacing.md),
        ...consulta.recommendedActions.map((action) {
          return _buildActionItem(context, action);
        }),
      ],
    );
  }

  /// Item de acción recomendada
  Widget _buildActionItem(BuildContext context, String action) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: () {
        // Temporal: mostrar SnackBar (navegación real en PASO F)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Acción: $action - Por implementar en PASO F'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Row(
        children: [
          // Ícono check
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 20,
              color: AppColors.success,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Label
          Expanded(
            child: Text(
              action,
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Chevron
          Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.textDisabled,
          ),
        ],
      ),
    );
  }

  /// Mensaje de éxito
  Widget _buildSuccessMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Consulta guardada!',
                  style: AppTypography.bodyBold.copyWith(
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Puedes encontrarla en el historial de Consulta Express',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Botones inferiores
  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _startNewConsultation(context),
            icon: const Icon(Icons.add),
            label: const Text('Nueva consulta'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 48),
            ),
          ),
        ),
      ),
    );
  }

  /// Navegar a home
  void _goToHome(BuildContext context) {
    // Volver a ChatHomeScreen (inicio del tab de Consulta Express)
    // Contar cuántas pantallas hay que cerrar
    int popCount = 0;
    Navigator.of(context).popUntil((route) {
      popCount++;
      // Si estamos en ChatHomeScreen, detenerse
      // Típicamente hay 2 pantallas: ChatActiveScreen + ChatSummaryScreen
      return popCount >= 2 || route.isFirst;
    });
  }

  /// Iniciar nueva consulta
  void _startNewConsultation(BuildContext context) {
    // Volver al ChatHomeScreen y empezar nueva consulta inmediatamente
    int popCount = 0;
    Navigator.of(context).popUntil((route) {
      popCount++;
      return popCount >= 2 || route.isFirst;
    });
    
    // Pequeño delay para que termine la animación, luego abrir nueva consulta
    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        // Abrir nueva consulta
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ChatActiveScreen(),
          ),
        );
      }
    });
  }

  /// Formatear duración
  String _formatDuration(Duration? duration) {
    if (duration == null) return '0 min';

    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return '${hours}h ${minutes}m';
    }

    final minutes = duration.inMinutes;
    if (minutes == 0) {
      return '${duration.inSeconds}s';
    }
    return '$minutes min';
  }

  /// Formatear fecha (día mes)
  String _formatDate(DateTime date) {
    final day = date.day;
    final months = [
      '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '$day ${months[date.month]}';
  }

  /// Formatear hora (HH:MM)
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
