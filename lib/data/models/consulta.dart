import 'chat_message.dart';

/// Modelo de consulta completa guardada en historial
/// Representa una conversación completa con el chatbot
class Consulta {
  final String id;
  final String petName; // Nombre de la mascota (contexto)
  final String topic; // Tema detectado (vacunas, alimentación, etc.)
  final List<ChatMessage> messages; // Conversación completa
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> recommendedActions; // Acciones sugeridas

  Consulta({
    required this.id,
    required this.petName,
    required this.topic,
    required this.messages,
    required this.startTime,
    this.endTime,
    this.recommendedActions = const [],
  });

  /// Duración de la consulta
  Duration? get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }

  /// Resumen corto para mostrar en historial
  String get summary {
    if (messages.isEmpty) return 'Sin mensajes';
    
    // Tomar la primera pregunta del usuario
    final userMessage = messages.firstWhere(
      (msg) => msg.isUser,
      orElse: () => messages.first,
    );
    
    return userMessage.text.length > 60
        ? '${userMessage.text.substring(0, 60)}...'
        : userMessage.text;
  }

  /// Vista previa de la respuesta del bot
  String get preview {
    if (messages.length < 2) return '';
    
    // Tomar la primera respuesta del bot
    final botMessage = messages.firstWhere(
      (msg) => !msg.isUser,
      orElse: () => messages.last,
    );
    
    return botMessage.text.length > 80
        ? '${botMessage.text.substring(0, 80)}...'
        : botMessage.text;
  }

  /// Fecha relativa para mostrar (ej. "Hace 2 días")
  String getRelativeDate() {
    final now = DateTime.now();
    final difference = now.difference(startTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes} minutos';
      }
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    } else {
      return 'Hace ${(difference.inDays / 30).floor()} meses';
    }
  }
}
