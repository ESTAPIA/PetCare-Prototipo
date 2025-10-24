/// Modelo de mensaje en el chat de Consulta Express
/// Representa un mensaje del usuario o del bot
class ChatMessage {
  final String id;
  final String text;
  final bool isUser; // true = usuario, false = bot
  final DateTime timestamp;
  final List<MessageAction>? actions; // Botones de acción opcionales

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actions,
  });

  /// Crear mensaje del usuario
  factory ChatMessage.user(String text) {
    return ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  /// Crear mensaje del bot con acciones opcionales
  factory ChatMessage.bot(String text, {List<MessageAction>? actions}) {
    return ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      actions: actions,
    );
  }
}

/// Acción/botón que puede tener un mensaje del bot
class MessageAction {
  final String label; // Texto del botón
  final ActionType type; // Tipo de acción
  final String? route; // Ruta de navegación si aplica

  MessageAction({
    required this.label,
    required this.type,
    this.route,
  });
}

/// Tipos de acciones disponibles en mensajes del bot
enum ActionType {
  createReminder, // Crear recordatorio
  viewPlan, // Ver plan de cuidado
  searchVet, // Buscar veterinaria
  navigate, // Navegar a otra pantalla
}
