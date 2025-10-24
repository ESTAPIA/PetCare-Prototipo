/// Modelo de recordatorio
class Reminder {
  final String id;
  final String petId;
  final String title;
  final String date; // ISO format YYYY-MM-DD
  final String time; // HH:mm format
  final RepeatFrequency repeat;
  final String? notes;
  final ReminderStatus status;
  final String? fromPlanId;
  final String? taskId;
  final ReminderType type;
  final DateTime? completedAt;
  final DateTime? snoozedUntil;
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.petId,
    required this.title,
    required this.date,
    required this.time,
    required this.repeat,
    this.notes,
    required this.status,
    this.fromPlanId,
    this.taskId,
    required this.type,
    this.completedAt,
    this.snoozedUntil,
    DateTime? createdAt, // <-- HACER OPCIONAL
  }) : createdAt =
           createdAt ?? DateTime.now(); // <-- ASIGNAR FECHA ACTUAL POR DEFECTO

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      petId: json['petId'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      repeat: RepeatFrequency.fromString(json['repeat'] as String),
      notes: json['notes'] as String?,
      status: ReminderStatus.fromString(json['status'] as String),
      fromPlanId: json['fromPlanId'] as String?,
      taskId: json['taskId'] as String?,
      type: ReminderType.fromString(json['type'] as String),
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'] as String)
              : null,
      snoozedUntil:
          json['snoozedUntil'] != null
              ? DateTime.parse(json['snoozedUntil'] as String)
              : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'title': title,
      'date': date,
      'time': time,
      'repeat': repeat.value,
      'notes': notes,
      'status': status.value,
      'fromPlanId': fromPlanId,
      'taskId': taskId,
      'type': type.value,
      'completedAt': completedAt?.toIso8601String(),
      'snoozedUntil': snoozedUntil?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Obtener DateTime combinando date y time
  DateTime get dateTime {
    final dateParts = date.split('-');
    final timeParts = time.split(':');
    return DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  /// Verificar si está vencido
  bool get isOverdue {
    return status == ReminderStatus.pending &&
        dateTime.isBefore(DateTime.now());
  }

  /// Verificar si está próximo a vencer (≤1 hora)
  bool get isDueSoon {
    final now = DateTime.now();
    final diff = dateTime.difference(now);
    return status == ReminderStatus.pending &&
        diff.isNegative == false &&
        diff.inHours <= 1;
  }

  Reminder copyWith({
    String? id,
    String? petId,
    String? title,
    String? date,
    String? time,
    RepeatFrequency? repeat,
    String? notes,
    ReminderStatus? status,
    String? fromPlanId,
    String? taskId,
    ReminderType? type,
    DateTime? completedAt,
    DateTime? snoozedUntil,
    bool clearCompletedAt = false,
    bool clearSnoozedUntil = false,
  }) {
    return Reminder(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      repeat: repeat ?? this.repeat,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      fromPlanId: fromPlanId ?? this.fromPlanId,
      taskId: taskId ?? this.taskId,
      type: type ?? this.type,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      snoozedUntil:
          clearSnoozedUntil ? null : (snoozedUntil ?? this.snoozedUntil),
      createdAt: createdAt,
    );
  }
}

/// Frecuencia de repetición (reutilizar del modelo Task)
enum RepeatFrequency {
  none('none', 'Ninguna'),
  daily('daily', 'Diaria'),
  weekly('weekly', 'Semanal'),
  monthly('monthly', 'Mensual');

  final String value;
  final String displayName;

  const RepeatFrequency(this.value, this.displayName);

  static RepeatFrequency fromString(String value) {
    return RepeatFrequency.values.firstWhere((e) => e.value == value);
  }
}

/// Estado del recordatorio
enum ReminderStatus {
  pending('pending', 'Pendiente'),
  done('done', 'Completado'),
  snoozed('snoozed', 'Pospuesto');

  final String value;
  final String displayName;

  const ReminderStatus(this.value, this.displayName);

  static ReminderStatus fromString(String value) {
    return ReminderStatus.values.firstWhere((e) => e.value == value);
  }
}

/// Tipo de recordatorio
enum ReminderType {
  vaccine('vaccine', 'Vacuna', '💉'),
  medication('medication', 'Medicación', '💊'),
  appointment('appointment', 'Cita', '📅'),
  grooming('grooming', 'Aseo', '✂️'),
  other('other', 'Otro', '📌');

  final String value;
  final String displayName;
  final String emoji;

  const ReminderType(this.value, this.displayName, this.emoji);

  static ReminderType fromString(String value) {
    return ReminderType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReminderType.other,
    );
  }
}
