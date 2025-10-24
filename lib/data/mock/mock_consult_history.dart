import '../models/chat_message.dart';
import '../models/consulta.dart';

/// Datos mock de consultas anteriores para el historial
class MockConsultHistory {
  static List<Consulta> getHistorialConsultas() {
    return [
      // Consulta 1: Sobre vacunas
      Consulta(
        id: 'cons-001',
        petName: 'Luna',
        topic: 'Vacunas',
        startTime: DateTime.now().subtract(const Duration(days: 2)),
        endTime: DateTime.now().subtract(const Duration(days: 2, hours: -1)),
        messages: [
          ChatMessage(
            id: 'msg-001',
            text: '¿Cuándo debo vacunar a mi cachorro?',
            isUser: true,
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ChatMessage(
            id: 'msg-002',
            text: 'El esquema de vacunación varía según la edad:\n\n'
                '🐶 Cachorros:\n'
                '• 6-8 semanas: Primera dosis\n'
                '• 10-12 semanas: Segunda dosis\n'
                '• 14-16 semanas: Tercera dosis\n'
                '• Rabia: 16 semanas',
            isUser: false,
            timestamp: DateTime.now().subtract(const Duration(days: 2, minutes: -1)),
            actions: [
              MessageAction(
                label: 'Ver plan de vacunación',
                type: ActionType.viewPlan,
                route: '/plan',
              ),
            ],
          ),
        ],
        recommendedActions: [
          'Crear recordatorio de vacunación',
          'Ver plan de cuidado',
        ],
      ),

      // Consulta 2: Sobre comportamiento
      Consulta(
        id: 'cons-002',
        petName: 'Max',
        topic: 'Comportamiento',
        startTime: DateTime.now().subtract(const Duration(days: 7)),
        endTime: DateTime.now().subtract(const Duration(days: 7, hours: -1)),
        messages: [
          ChatMessage(
            id: 'msg-003',
            text: '¿Es normal que mi gato duerma tanto?',
            isUser: true,
            timestamp: DateTime.now().subtract(const Duration(days: 7)),
          ),
          ChatMessage(
            id: 'msg-004',
            text: 'Sí, es completamente normal. Los gatos adultos suelen dormir entre 12 y 16 horas al día. '
                'Esto se debe a su naturaleza de cazadores nocturnos.\n\n'
                'Solo preocúpate si:\n'
                '• Duerme más de 20 horas\n'
                '• Muestra debilidad extrema\n'
                '• No come ni bebe agua',
            isUser: false,
            timestamp: DateTime.now().subtract(const Duration(days: 7, minutes: -2)),
          ),
        ],
        recommendedActions: [
          'Observar comportamiento',
        ],
      ),

      // Consulta 3: Sobre alimentación
      Consulta(
        id: 'cons-003',
        petName: 'Coco',
        topic: 'Alimentación',
        startTime: DateTime.now().subtract(const Duration(days: 14)),
        endTime: DateTime.now().subtract(const Duration(days: 14, hours: -1)),
        messages: [
          ChatMessage(
            id: 'msg-005',
            text: 'Recomendaciones para el baño de mi perro',
            isUser: true,
            timestamp: DateTime.now().subtract(const Duration(days: 14)),
          ),
          ChatMessage(
            id: 'msg-006',
            text: 'El baño de los perros se recomienda cada 3-4 semanas, aunque depende de:\n\n'
                '• Tipo de pelo\n'
                '• Actividades (si se ensucia mucho)\n'
                '• Alergias de piel\n\n'
                'Consejos:\n'
                '✓ Usa shampoo específico para perros\n'
                '✓ Agua tibia (no caliente)\n'
                '✓ Seca bien para evitar hongos\n'
                '✓ Evita que entre agua en oídos',
            isUser: false,
            timestamp: DateTime.now().subtract(const Duration(days: 14, minutes: -1)),
            actions: [
              MessageAction(
                label: 'Crear recordatorio de baño',
                type: ActionType.createReminder,
                route: '/reminders/new',
              ),
            ],
          ),
        ],
        recommendedActions: [
          'Crear recordatorio de baño mensual',
        ],
      ),
    ];
  }

  /// Obtener una consulta por ID
  static Consulta? getConsultaById(String id) {
    try {
      return getHistorialConsultas().firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Simular guardar consulta (en memoria, no persiste)
  static void saveConsulta(Consulta consulta) {
    // TODO: En producción, guardar en SharedPreferences o base de datos local
    // Por ahora solo simula el guardado sin hacer nada
    print('Consulta guardada: ${consulta.id} - ${consulta.topic}');
  }

  /// Simular eliminar consulta
  static void deleteConsulta(String id) {
    // TODO: En producción, eliminar de SharedPreferences
    print('Consulta eliminada: $id');
  }
}
