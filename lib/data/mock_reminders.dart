import '../models/reminder.dart';

/// Repositorio mock de recordatorios
class MockRemindersRepository {
  static final List<Map<String, dynamic>> _remindersJson = [
    {
      "id": "rem-001",
      "petId": "pet-001",
      "title": "Vacuna Rabia",
      "date": "2025-02-15",
      "time": "10:00",
      "repeat": "none",
      "notes": "Llevar carnet de vacunas. Importante no olvidar.",
      "status": "pending",
      "fromPlanId": "plan-tmpl-001",
      "taskId": "task-004",
      "type": "vaccine",
      "completedAt": null,
      "snoozedUntil": null,
      "createdAt": "2025-01-20T14:30:00Z",
    },
    {
      "id": "rem-002",
      "petId": "pet-001",
      "title": "Desparasitación interna",
      "date": "2025-02-10",
      "time": "09:00",
      "repeat": "monthly",
      "notes": "Pastilla según peso. Luna pesa 15.5 kg.",
      "status": "done",
      "fromPlanId": "plan-tmpl-001",
      "taskId": "task-005",
      "type": "medication",
      "completedAt": "2025-02-10T09:15:00Z",
      "snoozedUntil": null,
      "createdAt": "2025-01-15T10:00:00Z",
    },
    {
      "id": "rem-003",
      "petId": "pet-002",
      "title": "Limpieza dental",
      "date": "2025-02-20",
      "time": "11:00",
      "repeat": "none",
      "notes": "Clínica Veterinaria Central. Tel: 02-2345678",
      "status": "pending",
      "fromPlanId": null,
      "taskId": null,
      "type": "grooming",
      "completedAt": null,
      "snoozedUntil": null,
      "createdAt": "2025-02-01T16:45:00Z",
    },
    {
      "id": "rem-004",
      "petId": "pet-001",
      "title": "Control veterinario anual",
      "date": "2025-03-15",
      "time": "10:00",
      "repeat": "none",
      "notes": "Chequeo completo + análisis de sangre.",
      "status": "pending",
      "fromPlanId": "plan-tmpl-003",
      "taskId": "task-008",
      "type": "appointment",
      "completedAt": null,
      "snoozedUntil": null,
      "createdAt": "2025-01-10T11:20:00Z",
    },
  ];

  /// Lista temporal en memoria (simulación de estado)
  static List<Reminder> _cachedReminders = [];

  /// Obtener todos los recordatorios
  static List<Reminder> getAllReminders() {
    if (_cachedReminders.isEmpty) {
      _cachedReminders =
          _remindersJson.map((json) => Reminder.fromJson(json)).toList();
    }
    return List.from(_cachedReminders);
  }

  /// Obtener recordatorios pendientes
  static List<Reminder> getPendingReminders() {
    return getAllReminders()
        .where((r) => r.status == ReminderStatus.pending)
        .toList();
  }

  /// Obtener recordatorios por mascota
  static List<Reminder> getRemindersByPet(String petId) {
    return getAllReminders().where((r) => r.petId == petId).toList();
  }

  /// Obtener recordatorio por ID
  static Reminder? getReminderById(String id) {
    try {
      return getAllReminders().firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener próximo recordatorio
  static Reminder? getNextReminder() {
    final pending = getPendingReminders();
    if (pending.isEmpty) return null;

    pending.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return pending.first;
  }

  /// Crear recordatorio
  static Future<bool> createReminder(Reminder reminder) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Validar que no exista un recordatorio con el mismo ID
    final exists = _cachedReminders.any((r) => r.id == reminder.id);
    if (exists) {
      return false; // ID duplicado
    }

    _cachedReminders.add(reminder);
    return true;
  }

  /// Actualizar recordatorio
  static Future<bool> updateReminder(String id, Reminder updated) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _cachedReminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _cachedReminders[index] = updated;
      return true;
    }
    return false;
  }

  /// Marcar como hecho
  static Future<bool> markAsDone(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _cachedReminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final current = _cachedReminders[index];
      _cachedReminders[index] = Reminder(
        id: current.id,
        petId: current.petId,
        title: current.title,
        date: current.date,
        time: current.time,
        repeat: current.repeat,
        notes: current.notes,
        status: ReminderStatus.done,
        fromPlanId: current.fromPlanId,
        taskId: current.taskId,
        type: current.type,
        completedAt: DateTime.now(),
        snoozedUntil: null,
        createdAt: current.createdAt,
      );
      return true;
    }
    return false;
  }

  /// Posponer recordatorio
  static Future<bool> snoozeReminder(String id, DateTime until) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _cachedReminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final current = _cachedReminders[index];
      _cachedReminders[index] = Reminder(
        id: current.id,
        petId: current.petId,
        title: current.title,
        date: current.date,
        time: current.time,
        repeat: current.repeat,
        notes: current.notes,
        status: ReminderStatus.snoozed,
        fromPlanId: current.fromPlanId,
        taskId: current.taskId,
        type: current.type,
        completedAt: null,
        snoozedUntil: until,
        createdAt: current.createdAt,
      );
      return true;
    }
    return false;
  }

  /// Eliminar recordatorio
  static Future<bool> deleteReminder(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _cachedReminders.removeWhere((r) => r.id == id);
    return true;
  }
}
