import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';

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
          // TODO: Navegar a SCR-CONS-CHAT (pantalla de chat)
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
    // TODO: Conectar con datos mock
    final hasHistory = true;
    
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
              if (hasHistory)
                TextButton(
                  onPressed: () {
                    // TODO: Navegar a historial completo
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
          Column(
            children: [
              _buildHistoryCard(
                petName: 'Luna',
                petPhoto: null,
                question: '¿Cuándo debo vacunar a mi cachorro?',
                preview: 'Es recomendable iniciar el esquema de vacunación a las 6-8 semanas...',
                date: 'Hace 2 días',
                questionIcon: Icons.vaccines,
                questionColor: AppColors.warning,
              ),
              _buildHistoryCard(
                petName: 'Max',
                petPhoto: null,
                question: '¿Es normal que mi gato duerma tanto?',
                preview: 'Los gatos adultos suelen dormir entre 12 y 16 horas al día...',
                date: 'Hace 1 semana',
                questionIcon: Icons.bedtime,
                questionColor: AppColors.info,
              ),
              _buildHistoryCard(
                petName: 'Coco',
                petPhoto: null,
                question: 'Recomendaciones para el baño de mi perro',
                preview: 'El baño de los perros se recomienda cada 3-4 semanas...',
                date: 'Hace 2 semanas',
                questionIcon: Icons.shower,
                questionColor: AppColors.primary,
              ),
            ],
          ),
      ],
    );
  }

  /// Card de historial de consulta
  Widget _buildHistoryCard({
    required String petName,
    String? petPhoto,
    required String question,
    required String preview,
    required String date,
    required IconData questionIcon,
    required Color questionColor,
  }) {
    return AppCard(
      onTap: () {
        // TODO: Navegar a detalle de la consulta (SCR-CONS-CHAT con historial)
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono de la pregunta
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: questionColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              questionIcon,
              color: questionColor,
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
                    // Avatar de mascota (placeholder)
                    if (petPhoto != null)
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(petPhoto),
                      )
                    else
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
                      petName,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    Text(
                      date,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.xs),
                
                // Pregunta
                Text(
                  question,
                  style: AppTypography.bodyBold,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: AppSpacing.xs),
                
                // Preview de respuesta
                Text(
                  preview,
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
