import '../models/chat_message.dart';

/// Servicio mock mejorado que genera respuestas del bot basadas en keywords
/// PASO E: Enhanced Bot Logic
/// - Detección de contexto (edad, especie)
/// - Detección de síntomas combinados
/// - Keywords expandidos por categoría
/// - Preguntas de seguimiento
class MockBotService {
  /// Obtener respuesta del bot según el texto del usuario
  static ChatMessage getResponse(String userMessage) {
    final msg = userMessage.toLowerCase();
    
    // 1. Detectar contexto del mensaje
    final context = _detectContext(msg);
    
    // 2. EMERGENCIAS (prioridad máxima)
    if (_isEmergency(msg)) {
      return _getEmergencyResponse();
    }
    
    // 3. SÍNTOMAS COMBINADOS (prioridad alta)
    final symptoms = _detectSymptoms(msg);
    if (symptoms.length >= 2) {
      return _getCombinedSymptomsResponse(symptoms, context);
    }
    
    // 4. CATEGORÍAS ESPECÍFICAS (mejoradas con contexto)
    if (_isAboutVaccines(msg)) {
      return _getVaccineResponse(context);
    }
    
    if (_isAboutNutrition(msg)) {
      return _getNutritionResponse(context);
    }
    
    if (_isAboutBehavior(msg)) {
      return _getBehaviorResponse(context);
    }
    
    if (_isAboutParasites(msg)) {
      return _getParasiteResponse(context);
    }
    
    if (_isAboutHygiene(msg)) {
      return _getHygieneResponse(context);
    }
    
    // Síntoma individual: vómito o diarrea
    if (symptoms.isNotEmpty) {
      return _getSingleSymptomResponse(symptoms.first, context);
    }
    
    // 5. RESPUESTA DEFAULT
    return _getDefaultResponse();
  }

  // ============================================
  // MÉTODOS DE DETECCIÓN DE CONTEXTO
  // ============================================
  
  /// Detectar contexto del mensaje (edad, especie)
  static Map<String, dynamic> _detectContext(String msg) {
    return {
      'isPuppy': msg.contains('cachorro') || 
                 msg.contains('bebé') || 
                 msg.contains('bebe') ||
                 msg.contains('pequeño'),
      'isSenior': msg.contains('viejo') || 
                  msg.contains('anciano') || 
                  msg.contains('senior') ||
                  msg.contains('mayor'),
      'isDog': msg.contains('perro') || msg.contains('🐶'),
      'isCat': msg.contains('gato') || msg.contains('🐱'),
    };
  }
  
  /// Detectar múltiples síntomas en el mensaje
  static Set<String> _detectSymptoms(String msg) {
    final symptoms = <String>{};
    
    if (msg.contains('vomito') || msg.contains('vómito')) {
      symptoms.add('vomito');
    }
    if (msg.contains('diarrea')) {
      symptoms.add('diarrea');
    }
    if (msg.contains('fiebre') || msg.contains('caliente') || msg.contains('temperatura')) {
      symptoms.add('fiebre');
    }
    if (msg.contains('tos') || msg.contains('toser')) {
      symptoms.add('tos');
    }
    if (msg.contains('rascado') || msg.contains('rasca') || msg.contains('picazón')) {
      symptoms.add('picazon');
    }
    if (msg.contains('cojea') || msg.contains('renque') || msg.contains('pata')) {
      symptoms.add('cojera');
    }
    
    return symptoms;
  }

  // ============================================
  // MÉTODOS DE DETECCIÓN POR CATEGORÍA
  // ============================================
  
  static bool _isAboutVaccines(String msg) {
    return msg.contains('vacuna') || 
           msg.contains('vacunación') ||
           msg.contains('vacunar') ||
           msg.contains('inmuniz') ||
           msg.contains('inyecci') ||
           msg.contains('dosis') ||
           msg.contains('refuerzo');
  }
  
  static bool _isAboutNutrition(String msg) {
    return msg.contains('comida') || 
           msg.contains('alimentación') ||
           msg.contains('alimentacion') ||
           msg.contains('dieta') ||
           msg.contains('comer') ||
           msg.contains('peso') ||
           msg.contains('nutrición') ||
           msg.contains('nutricion') ||
           msg.contains('sobrepeso') ||
           msg.contains('delgado') ||
           msg.contains('gordo') ||
           msg.contains('croquetas');
  }
  
  static bool _isAboutBehavior(String msg) {
    return msg.contains('ladra') || 
           msg.contains('agresivo') ||
           msg.contains('estrés') ||
           msg.contains('estres') ||
           msg.contains('ansiedad') ||
           msg.contains('comportamiento') ||
           msg.contains('miedo') ||
           msg.contains('nervioso') ||
           msg.contains('hiperactivo') ||
           msg.contains('destructivo');
  }
  
  static bool _isAboutParasites(String msg) {
    return msg.contains('desparasit') || 
           msg.contains('parásito') ||
           msg.contains('parasito') ||
           msg.contains('gusanos') ||
           msg.contains('pulgas') ||
           msg.contains('garrapatas') ||
           msg.contains('lombrices') ||
           msg.contains('ácaros');
  }
  
  static bool _isAboutHygiene(String msg) {
    return msg.contains('baño') || 
           msg.contains('bañar') ||
           msg.contains('higiene') ||
           msg.contains('limpieza') ||
           msg.contains('shampoo') ||
           msg.contains('oler') ||
           msg.contains('mal olor');
  }

  // ============================================
  // MÉTODOS DE RESPUESTA POR CATEGORÍA
  // ============================================
  
  static ChatMessage _getEmergencyResponse() {
    return ChatMessage.bot(
      '⚠️ ALERTA: Esto puede ser una EMERGENCIA médica.\n\n'
      'Te recomiendo contactar a un veterinario INMEDIATAMENTE o acudir a una clínica de emergencias 24h.\n\n'
      'Mientras tanto:\n'
      '• Mantén a tu mascota tranquila\n'
      '• No le des comida ni agua\n'
      '• Observa su respiración\n'
      '• Anota cualquier síntoma nuevo',
      actions: [
        MessageAction(
          label: 'Buscar veterinaria de emergencia',
          type: ActionType.searchVet,
          route: '/vets',
        ),
      ],
    );
  }
  
  static ChatMessage _getCombinedSymptomsResponse(Set<String> symptoms, Map<String, dynamic> context) {
    final symptomsList = symptoms.join(', ');
    final isPuppy = context['isPuppy'] as bool;
    
    String severity = '⚠️ IMPORTANTE';
    String recommendation = 'Te recomiendo consultar con un veterinario pronto.';
    
    if (symptoms.contains('vomito') && symptoms.contains('diarrea')) {
      severity = '🚨 URGENTE';
      recommendation = isPuppy 
          ? 'Los cachorros se deshidratan rápido. Consulta a un veterinario HOY.'
          : 'Esto puede causar deshidratación. Consulta a un veterinario en las próximas 12-24 horas.';
    }
    
    return ChatMessage.bot(
      '$severity: Detecto múltiples síntomas ($symptomsList).\n\n'
      '$recommendation\n\n'
      'Mientras tanto:\n'
      '• Mantén agua fresca disponible\n'
      '• No le des comida por 6-8 horas\n'
      '• Observa si hay otros síntomas\n'
      '• Anota desde cuándo comenzó\n\n'
      '¿Los síntomas comenzaron al mismo tiempo o gradualmente?',
      actions: [
        MessageAction(
          label: 'Buscar veterinaria',
          type: ActionType.searchVet,
          route: '/vets',
        ),
        MessageAction(
          label: 'Crear recordatorio de observación',
          type: ActionType.createReminder,
          route: '/reminders/new',
        ),
      ],
    );
  }
  
  static ChatMessage _getSingleSymptomResponse(String symptom, Map<String, dynamic> context) {
    final isPuppy = context['isPuppy'] as bool;
    
    if (symptom == 'vomito' || symptom == 'diarrea') {
      final symptomName = symptom == 'vomito' ? 'vómito' : 'diarrea';
      
      return ChatMessage.bot(
        'El $symptomName ocasional puede ser normal, pero hay que vigilarlo.\n\n'
        '${isPuppy ? "⚠️ Los cachorros son más vulnerables a deshidratación.\n\n" : ""}'
        'Consulta a un veterinario si:\n'
        '• Persiste más de 24 horas\n'
        '• Hay sangre presente\n'
        '• Tu mascota está decaída\n'
        '• No quiere beber agua\n\n'
        'Recomendaciones inmediatas:\n'
        '• Ayuno de 12 horas (solo agua)\n'
        '• Dieta blanda: pollo hervido con arroz\n'
        '• Observa otros síntomas\n\n'
        '¿Hace cuánto tiempo comenzó?',
        actions: [
          MessageAction(
            label: 'Crear recordatorio de control',
            type: ActionType.createReminder,
            route: '/reminders/new',
          ),
          MessageAction(
            label: 'Buscar veterinaria',
            type: ActionType.searchVet,
            route: '/vets',
          ),
        ],
      );
    }
    
    return _getDefaultResponse();
  }
  
  static ChatMessage _getVaccineResponse(Map<String, dynamic> context) {
    final isPuppy = context['isPuppy'] as bool;
    final isDog = context['isDog'] as bool;
    final isCat = context['isCat'] as bool;
    
    if (isPuppy) {
      if (isDog) {
        return ChatMessage.bot(
          'Esquema de vacunación para CACHORROS de perro:\n\n'
          '✓ 6-8 semanas: Primera dosis (Parvovirus, Moquillo, Hepatitis)\n'
          '✓ 10-12 semanas: Segunda dosis + Leptospirosis\n'
          '✓ 14-16 semanas: Tercera dosis + Parainfluenza\n'
          '✓ 16 semanas: Rabia (obligatoria)\n'
          '✓ Refuerzo anual\n\n'
          '💡 Tip: No saques a pasear a tu cachorro hasta completar el esquema.\n\n'
          '¿Ya tiene alguna dosis aplicada?',
          actions: [
            MessageAction(
              label: 'Ver plan de vacunación',
              type: ActionType.viewPlan,
              route: '/plan',
            ),
            MessageAction(
              label: 'Crear recordatorio',
              type: ActionType.createReminder,
              route: '/reminders/new',
            ),
          ],
        );
      } else if (isCat) {
        return ChatMessage.bot(
          'Esquema de vacunación para CACHORROS de gato:\n\n'
          '✓ 8 semanas: Primera dosis (Triple felina)\n'
          '✓ 12 semanas: Segunda dosis + Leucemia\n'
          '✓ 16 semanas: Rabia\n'
          '✓ Refuerzo anual\n\n'
          '💡 Tip: Los gatos de interior también necesitan vacunas.\n\n'
          '¿Tu gato sale al exterior?',
          actions: [
            MessageAction(
              label: 'Ver plan de vacunación',
              type: ActionType.viewPlan,
              route: '/plan',
            ),
            MessageAction(
              label: 'Crear recordatorio',
              type: ActionType.createReminder,
              route: '/reminders/new',
            ),
          ],
        );
      }
    }
    
    // Respuesta general (adultos o sin especie detectada)
    return ChatMessage.bot(
      'El esquema de vacunación varía según la edad:\n\n'
      '🐶 Cachorros de perro:\n'
      '• 6-8 semanas: Primera dosis\n'
      '• 10-12 semanas: Segunda dosis\n'
      '• 14-16 semanas: Tercera dosis\n'
      '• Rabia: 16 semanas\n\n'
      '🐱 Cachorros de gato:\n'
      '• 8 semanas: Primera dosis\n'
      '• 12 semanas: Segunda dosis\n'
      '• Rabia: 16 semanas\n\n'
      '🔄 Adultos: Refuerzos anuales\n\n'
      '¿Tu mascota es cachorro o adulto?',
      actions: [
        MessageAction(
          label: 'Ver plan de vacunación',
          type: ActionType.viewPlan,
          route: '/plan',
        ),
        MessageAction(
          label: 'Crear recordatorio',
          type: ActionType.createReminder,
          route: '/reminders/new',
        ),
      ],
    );
  }
  
  static ChatMessage _getNutritionResponse(Map<String, dynamic> context) {
    final isPuppy = context['isPuppy'] as bool;
    final isSenior = context['isSenior'] as bool;
    
    if (isPuppy) {
      return ChatMessage.bot(
        'Alimentación para CACHORROS:\n\n'
        '🍖 Frecuencia:\n'
        '• Menores de 3 meses: 4 veces al día\n'
        '• 3-6 meses: 3 veces al día\n'
        '• 6-12 meses: 2 veces al día\n\n'
        '✓ Usa alimento específico para cachorros (más proteínas)\n'
        '✓ Cantidad según peso (ver empaque)\n'
        '✓ Agua fresca siempre disponible\n\n'
        '⚠️ NO des: chocolate, cebolla, ajo, uvas, huesos cocidos\n\n'
        '¿Cuántos meses tiene tu cachorro?',
        actions: [
          MessageAction(
            label: 'Crear recordatorio de alimentación',
            type: ActionType.createReminder,
            route: '/reminders/new',
          ),
        ],
      );
    } else if (isSenior) {
      return ChatMessage.bot(
        'Alimentación para mascotas SENIOR (7+ años):\n\n'
        '🥘 Recomendaciones:\n'
        '• Alimento senior (menos calorías, más fibra)\n'
        '• 2 comidas al día\n'
        '• Porciones controladas (evitar sobrepeso)\n'
        '• Considerar suplementos articulares\n\n'
        '💡 Tips:\n'
        '✓ Agua fresca abundante\n'
        '✓ Comida fácil de masticar\n'
        '✓ Control de peso regular\n\n'
        '¿Tu mascota tiene alguna condición médica?',
        actions: [
          MessageAction(
            label: 'Ver plan de cuidado senior',
            type: ActionType.viewPlan,
            route: '/plan',
          ),
          MessageAction(
            label: 'Crear recordatorio',
            type: ActionType.createReminder,
            route: '/reminders/new',
          ),
        ],
      );
    }
    
    // Respuesta general
    return ChatMessage.bot(
      'Alimentación adecuada según edad y tamaño:\n\n'
      '🐶 Perros:\n'
      '• Cachorros: 3-4 veces al día\n'
      '• Adultos: 2 veces al día\n'
      '• Cantidad: según peso (ver empaque)\n\n'
      '🐱 Gatos:\n'
      '• Adultos: 2-3 veces al día\n'
      '• Acceso libre a agua fresca\n\n'
      '⚠️ Evita: chocolate, cebolla, ajo, uvas, huesos cocidos\n\n'
      '¿Notas algún problema con su alimentación actual?',
      actions: [
        MessageAction(
          label: 'Crear recordatorio de alimentación',
          type: ActionType.createReminder,
          route: '/reminders/new',
        ),
      ],
    );
  }
  
  static ChatMessage _getBehaviorResponse(Map<String, dynamic> context) {
    final isPuppy = context['isPuppy'] as bool;
    
    return ChatMessage.bot(
      'Los problemas de comportamiento pueden tener varias causas:\n\n'
      '${isPuppy ? "🐕 Para cachorros:\n• Socialización temprana es clave\n• Entrenamiento positivo desde pequeños\n\n" : ""}'
      '📋 Causas comunes:\n'
      '• Falta de ejercicio físico\n'
      '• Aburrimiento mental\n'
      '• Ansiedad por separación\n'
      '• Cambios en el entorno\n'
      '• Falta de socialización\n\n'
      'Recomendaciones:\n'
      '✓ Paseos regulares (mín. 30-60 min)\n'
      '✓ Juegos mentales (rompecabezas, entrenamiento)\n'
      '✓ Rutina consistente\n'
      '✓ Refuerzo positivo\n'
      '✓ Considera un etólogo o entrenador profesional\n\n'
      '¿Cuándo comenzó el problema de comportamiento?',
      actions: [
        MessageAction(
          label: 'Buscar veterinaria/etólogo',
          type: ActionType.searchVet,
          route: '/vets',
        ),
      ],
    );
  }
  
  static ChatMessage _getParasiteResponse(Map<String, dynamic> context) {
    final isPuppy = context['isPuppy'] as bool;
    
    return ChatMessage.bot(
      'La desparasitación es fundamental para la salud:\n\n'
      '${isPuppy ? "🐾 CACHORROS:\n• Cada 15 días hasta los 3 meses\n• Mensual de 3-6 meses\n• Luego cada 3 meses\n\n" : ""}'
      '🐶🐱 Adultos:\n'
      '• Interna: cada 3 meses\n'
      '• Externa: mensual (pipetas o collar)\n\n'
      '📋 Tipos de parásitos:\n'
      '• Internos: lombrices, tenias, giardias\n'
      '• Externos: pulgas, garrapatas, ácaros\n\n'
      '💊 Tratamientos:\n'
      '✓ Pastillas (parásitos internos)\n'
      '✓ Pipetas (externos e internos)\n'
      '✓ Collares antiparasitarios\n\n'
      '¿Cuándo fue la última desparasitación?',
      actions: [
        MessageAction(
          label: 'Crear recordatorio',
          type: ActionType.createReminder,
          route: '/reminders/new',
        ),
        MessageAction(
          label: 'Ver plan de cuidado',
          type: ActionType.viewPlan,
          route: '/plan',
        ),
      ],
    );
  }
  
  static ChatMessage _getHygieneResponse(Map<String, dynamic> context) {
    final isDog = context['isDog'] as bool;
    final isCat = context['isCat'] as bool;
    
    if (isDog) {
      return ChatMessage.bot(
        'Higiene y baño para PERROS:\n\n'
        '🚿 Frecuencia:\n'
        '• Cada 3-4 semanas (depende del pelo y actividad)\n'
        '• Razas de pelo largo: cada 2-3 semanas\n'
        '• Si se ensucia mucho: según necesidad\n\n'
        '✓ Consejos importantes:\n'
        '• Usa shampoo específico para perros\n'
        '• Agua tibia (no caliente)\n'
        '• Seca bien para evitar hongos\n'
        '• Evita que entre agua en oídos\n'
        '• Cepilla antes y después del baño\n\n'
        '🦷 Otros cuidados:\n'
        '• Limpieza de oídos: semanal\n'
        '• Corte de uñas: mensual\n'
        '• Cepillado dental: diario\n\n'
        '¿Tu perro tiene algún problema de piel?',
        actions: [
          MessageAction(
            label: 'Crear recordatorio de baño',
            type: ActionType.createReminder,
            route: '/reminders/new',
          ),
        ],
      );
    } else if (isCat) {
      return ChatMessage.bot(
        'Higiene para GATOS:\n\n'
        '🐱 Los gatos se asean solos, pero necesitan ayuda:\n\n'
        '✓ Cepillado:\n'
        '• Pelo corto: 1-2 veces por semana\n'
        '• Pelo largo: diario\n\n'
        '🚿 Baño:\n'
        '• Solo si es necesario (muy sucios)\n'
        '• Cada 2-3 meses máximo\n'
        '• Usar shampoo específico para gatos\n\n'
        '🦷 Otros cuidados:\n'
        '• Limpieza de oídos: mensual\n'
        '• Corte de uñas: cada 2-3 semanas\n'
        '• Cepillado dental: regular\n'
        '• Limpieza de arenero: diario\n\n'
        '¿Tu gato tolera bien el cepillado?',
        actions: [
          MessageAction(
            label: 'Crear recordatorio de cuidados',
            type: ActionType.createReminder,
            route: '/reminders/new',
          ),
        ],
      );
    }
    
    // Respuesta general
    return ChatMessage.bot(
      'Cuidados de higiene básicos:\n\n'
      '🐶 Perros:\n'
      '• Baño: cada 3-4 semanas\n'
      '• Cepillado: según tipo de pelo\n\n'
      '🐱 Gatos:\n'
      '• Se asean solos\n'
      '• Cepillado regular importante\n'
      '• Baño solo si es necesario\n\n'
      '✓ Todos necesitan:\n'
      '• Limpieza de oídos\n'
      '• Corte de uñas\n'
      '• Cuidado dental\n\n'
      '¿Qué cuidado específico te interesa?',
      actions: [
        MessageAction(
          label: 'Crear recordatorio',
          type: ActionType.createReminder,
          route: '/reminders/new',
        ),
      ],
    );
  }
  
  static ChatMessage _getDefaultResponse() {
    return ChatMessage.bot(
      'Gracias por tu consulta. Te puedo ayudar con:\n\n'
      '• Vacunas y desparasitación\n'
      '• Alimentación y nutrición\n'
      '• Comportamiento y entrenamiento\n'
      '• Higiene y cuidados\n'
      '• Síntomas y salud\n\n'
      '💡 Tip: Sé específico en tu pregunta, por ejemplo:\n'
      '"Mi cachorro tiene vómito" o "¿Cuándo vacunar a mi gato?"\n\n'
      '¿En qué más puedo ayudarte?',
      actions: [
        MessageAction(
          label: 'Ver plan de cuidado',
          type: ActionType.viewPlan,
          route: '/plan',
        ),
        MessageAction(
          label: 'Buscar veterinaria',
          type: ActionType.searchVet,
          route: '/vets',
        ),
      ],
    );
  }

  // ============================================
  // DETECCIÓN DE EMERGENCIAS (MEJORADA)
  // ============================================
  
  /// Detectar si el mensaje indica una emergencia
  static bool _isEmergency(String msg) {
    final emergencyKeywords = [
      'convulsión',
      'convulsion',
      'convulsiona',
      'sangrado',
      'sangre',
      'hemorragia',
      'atropellado',
      'golpe fuerte',
      'desmayo',
      'desmaya',
      'no respira',
      'respira mal',
      'asfixia',
      'envenenamiento',
      'intoxicación',
      'intoxicacion',
      'veneno',
      'toxico',
      'tóxico',
      'accidente',
      'herida grave',
      'fractura',
      'hueso roto',
      'no se mueve',
      'paralizado',
      'mordida grave',
    ];

    return emergencyKeywords.any((keyword) => msg.contains(keyword));
  }

  // ============================================
  // SUGERENCIAS RÁPIDAS
  // ============================================
  
  /// Obtener sugerencias rápidas para iniciar conversación
  static List<String> getQuickSuggestions() {
    return [
      '¿Cuándo debo vacunar a mi cachorro?',
      '¿Es normal que mi gato duerma tanto?',
      'Recomendaciones de alimentación',
      '¿Cada cuánto desparasitar?',
      'Mi perro tiene diarrea',
    ];
  }
}
