import '../models/plan_template.dart';

/// Repositorio mock de plantillas de planes
class MockPlanTemplatesRepository {
  static final List<Map<String, dynamic>> _templatesJson = [
    {
      "id": "plan-tmpl-001",
      "name": "Vacunas cachorro",
      "description":
          "Plan completo de vacunación para cachorros. Incluye vacunas polivalentes, rabia y desparasitación.",
      "species": ["Perro"],
      "durationDays": 112,
      "tasks": [
        {
          "taskId": "task-001",
          "label": "Primera vacuna polivalente",
          "description": "Protege contra parvovirus, moquillo y hepatitis",
          "type": "vaccine",
          "offsetDays": 56,
          "defaultTime": "10:00",
          "repeat": "none",
          "channel": "local",
        },
        {
          "taskId": "task-002",
          "label": "Segunda vacuna polivalente",
          "description": "Refuerzo de primera dosis",
          "type": "vaccine",
          "offsetDays": 77,
          "defaultTime": "10:00",
          "repeat": "none",
          "channel": "local",
        },
        {
          "taskId": "task-003",
          "label": "Tercera vacuna polivalente",
          "description": "Última dosis del ciclo inicial",
          "type": "vaccine",
          "offsetDays": 98,
          "defaultTime": "10:00",
          "repeat": "none",
          "channel": "local",
        },
        {
          "taskId": "task-004",
          "label": "Vacuna rabia",
          "description": "Obligatoria por ley",
          "type": "vaccine",
          "offsetDays": 112,
          "defaultTime": "10:00",
          "repeat": "none",
          "channel": "local",
        },
        {
          "taskId": "task-005",
          "label": "Desparasitación interna",
          "description": "Primera dosis",
          "type": "medication",
          "offsetDays": 49,
          "defaultTime": "09:00",
          "repeat": "none",
          "channel": "local",
        },
      ],
    },
    {
      "id": "plan-tmpl-002",
      "name": "Desparasitación rutinaria",
      "description":
          "Programa semestral de desparasitación interna y externa para perros y gatos adultos.",
      "species": ["Perro", "Gato"],
      "durationDays": 180,
      "tasks": [
        {
          "taskId": "task-006",
          "label": "Desparasitación interna",
          "description": "Pastilla oral según peso",
          "type": "medication",
          "offsetDays": 0,
          "defaultTime": "09:00",
          "repeat": "monthly",
          "channel": "local",
        },
        {
          "taskId": "task-007",
          "label": "Desparasitación externa",
          "description": "Pipeta o collar antiparasitario",
          "type": "medication",
          "offsetDays": 0,
          "defaultTime": "09:00",
          "repeat": "monthly",
          "channel": "local",
        },
      ],
    },
    {
      "id": "plan-tmpl-003",
      "name": "Cuidado básico adulto",
      "description":
          "Rutina anual de chequeos y vacunas para mascotas adultas sanas.",
      "species": ["Perro", "Gato"],
      "durationDays": 365,
      "tasks": [
        {
          "taskId": "task-008",
          "label": "Chequeo veterinario anual",
          "description": "Examen físico completo",
          "type": "appointment",
          "offsetDays": 0,
          "defaultTime": "10:00",
          "repeat": "none",
          "channel": "local",
        },
        {
          "taskId": "task-009",
          "label": "Vacuna polivalente refuerzo",
          "description": "Refuerzo anual de vacunas",
          "type": "vaccine",
          "offsetDays": 0,
          "defaultTime": "10:00",
          "repeat": "none",
          "channel": "local",
        },
        {
          "taskId": "task-010",
          "label": "Limpieza dental",
          "description": "Profilaxis profesional",
          "type": "grooming",
          "offsetDays": 180,
          "defaultTime": "11:00",
          "repeat": "none",
          "channel": "local",
        },
      ],
    },
    {
      "id": "plan-tmpl-004",
      "name": "Post-cirugía",
      "description":
          "Cuidados intensivos después de una intervención quirúrgica.",
      "species": ["Perro", "Gato", "Otro"],
      "durationDays": 14,
      "tasks": [
        {
          "taskId": "task-011",
          "label": "Administrar analgésico",
          "description": "Según prescripción veterinaria",
          "type": "medication",
          "offsetDays": 0,
          "defaultTime": "08:00",
          "repeat": "daily",
          "channel": "local",
        },
        {
          "taskId": "task-012",
          "label": "Limpieza de herida",
          "description": "Desinfectar con suero fisiológico",
          "type": "grooming",
          "offsetDays": 0,
          "defaultTime": "12:00",
          "repeat": "daily",
          "channel": "local",
        },
        {
          "taskId": "task-013",
          "label": "Control post-operatorio",
          "description": "Revisión de puntos y evolución",
          "type": "appointment",
          "offsetDays": 7,
          "defaultTime": "10:00",
          "repeat": "none",
          "channel": "local",
        },
        {
          "taskId": "task-014",
          "label": "Retirar puntos",
          "description": "Cita final",
          "type": "appointment",
          "offsetDays": 14,
          "defaultTime": "10:00",
          "repeat": "none",
          "channel": "local",
        },
      ],
    },
  ];

  /// Obtener todas las plantillas o filtrar por especie
  static List<PlanTemplate> getTemplates({String? species}) {
    final allTemplates =
        _templatesJson.map((json) => PlanTemplate.fromJson(json)).toList();

    if (species != null) {
      return allTemplates.where((t) => t.species.contains(species)).toList();
    }
    return allTemplates;
  }

  /// Obtener plantilla por ID
  static PlanTemplate? getTemplateById(String id) {
    try {
      return getTemplates().firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Simular creación de plan
  static Future<bool> createPlan({
    required String templateId,
    required String petId,
    required List<Task> tasks,
    required DateTime startDate,
  }) async {
    // Simular delay de operación
    await Future.delayed(const Duration(milliseconds: 1500));

    // Mock: simular éxito
    return true;
  }
}
