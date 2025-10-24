import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../data/mock/mock_consult_history.dart';
import '../../data/models/consulta.dart';
import '../../utils/topic_theme_helper.dart';
import 'chat_active_screen.dart';

/// SCR-CONS-START: Pantalla de inicio de Consulta Express
/// PROC-005: Consulta Express IA
/// 
/// Objetivo: Punto de entrada para iniciar consultas con el asistente virtual
class ChatHomeScreen extends StatelessWidget {
  const ChatHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta Express'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // TODO: Mostrar ayuda sobre cómo usar Consulta Express
            },
            tooltip: 'Ayuda',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          // Hero Section - Bot Avatar y Mensaje de Bienvenida
          _buildHeroSection(context),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Botón Principal: Nueva Consulta
          _buildNewConsultButton(context),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Sección de Historial
          _buildHistorySection(context),
        ],
      ),
    );
  }

  /// Hero section con bot y mensaje de bienvenida
  Widget _buildHeroSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // Avatar del bot
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.pets,
                size: 64,
                color: AppColors.primary,
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Mensaje de bienvenida
          Text(
            '¿En qué puedo ayudarte hoy?',
            style: AppTypography.h1.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Pregúntame sobre el cuidado de tu mascota, síntomas o dudas generales',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Botón principal para nueva consulta
  Widget _buildNewConsultButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: FilledButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatActiveScreen(),
            ),
          );
        },
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Nueva consulta',
              style: AppTypography.bodyBold.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sección de historial de consultas
  Widget _buildHistorySection(BuildContext context) {
    // Cargar historial de consultas desde mock
    final historial = MockConsultHistory.getHistorialConsultas();
    final hasHistory = historial.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Consultas recientes',
                style: AppTypography.h2,
              ),
              if (hasHistory && historial.length > 3)
                TextButton(
                  onPressed: () {
                    // Futuro: Mostrar modal con todas las consultas si hay más de 3
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mostrando ${historial.length} consultas recientes'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Ver todo'),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        if (!hasHistory)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: const EmptyState(
              icon: Icons.chat_bubble_outline,
              message: 'Aún no has hecho consultas',
              instruction: '¡Empieza ahora y recibe respuestas al instante!',
            ),
          )
        else
          // Renderizar historial dinámicamente desde mock
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: historial.length,
            itemBuilder: (context, index) {
              final consulta = historial[index];
              return _buildHistoryCard(
                context: context,
                consulta: consulta,
              );
            },
          ),
      ],
    );
  }

  /// Card de historial de consulta
  Widget _buildHistoryCard({
    required BuildContext context,
    required Consulta consulta,
  }) {
    // Mapear topic a icono y color
    final Map<String, dynamic> topicTheme = TopicThemeHelper.getTheme(consulta.topic);
    
    return AppCard(
      onTap: () {
        // Navegar a chat con consulta existente (readonly)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatActiveScreen(
              consultId: consulta.id,
            ),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono de la pregunta
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: topicTheme['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              topicTheme['icon'],
              color: topicTheme['color'],
              size: 24,
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mascota y fecha
                Row(
                  children: [
                    // Avatar de mascota
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.surfaceVariant,
                      child: Icon(
                        Icons.pets,
                        size: 12,
                        color: AppColors.primary,
                      ),
                    ),
                    
                    const SizedBox(width: 4),
                    
                    Text(
                      consulta.petName,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    Text(
                      consulta.getRelativeDate(),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.xs),
                
                // Pregunta (summary)
                Text(
                  consulta.summary,
                  style: AppTypography.bodyBold,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: AppSpacing.xs),
                
                // Preview de respuesta
                Text(
                  consulta.preview,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Chevron
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.chevron_right,
            color: AppColors.textDisabled,
            size: 20,
          ),
        ],
      ),
    );
  }
}
