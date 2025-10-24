import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Helper para obtener tema visual (ícono + color) según el topic de una consulta
/// Evita duplicación de código entre ChatHomeScreen y ChatSummaryScreen
class TopicThemeHelper {
  // Constructor privado para evitar instanciación
  TopicThemeHelper._();

  /// Obtener tema visual para un topic
  /// Retorna Map con 'icon' (IconData) y 'color' (Color)
  static Map<String, dynamic> getTheme(String topic) {
    final normalizedTopic = topic.toLowerCase().trim();

    switch (normalizedTopic) {
      case 'vacunas':
      case 'vacunación':
        return {
          'icon': Icons.vaccines,
          'color': AppColors.warning,
        };

      case 'emergencia':
        return {
          'icon': Icons.emergency,
          'color': AppColors.error,
        };

      case 'salud':
      case 'síntomas':
        return {
          'icon': Icons.health_and_safety,
          'color': AppColors.error,
        };

      case 'alimentación':
      case 'alimentacion':
        return {
          'icon': Icons.restaurant,
          'color': AppColors.primary,
        };

      case 'comportamiento':
        return {
          'icon': Icons.bedtime,
          'color': AppColors.info,
        };

      case 'desparasitación':
      case 'desparasitacion':
        return {
          'icon': Icons.medication,
          'color': AppColors.warning,
        };

      case 'higiene':
      case 'baño':
        return {
          'icon': Icons.shower,
          'color': AppColors.primary,
        };

      case 'consulta general':
      default:
        return {
          'icon': Icons.chat_bubble_outline,
          'color': AppColors.textSecondary,
        };
    }
  }

  /// Obtener ícono para un topic
  static IconData getIcon(String topic) {
    return getTheme(topic)['icon'] as IconData;
  }

  /// Obtener color para un topic
  static Color getColor(String topic) {
    return getTheme(topic)['color'] as Color;
  }
}
