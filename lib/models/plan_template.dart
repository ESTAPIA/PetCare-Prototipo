/// Modelo de plantilla de plan de cuidado
class PlanTemplate {
  final String id;
  final String name;
  final String description;
  final List<String> species;
  final int durationDays;
  final List<Task> tasks;

  PlanTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.species,
    required this.durationDays,
    required this.tasks,
  });

  factory PlanTemplate.fromJson(Map<String, dynamic> json) {
    return PlanTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      species: List<String>.from(json['species'] as List),
      durationDays: json['durationDays'] as int,
      tasks:
          (json['tasks'] as List)
              .map((t) => Task.fromJson(t as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'species': species,
      'durationDays': durationDays,
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
  }
}

/// Tarea individual dentro de una plantilla
class Task {
  final String taskId;
  final String label;
  final String? description;
  final TaskType type;
  final int offsetDays;
  final String defaultTime;
  final RepeatFrequency repeat;
  final String channel;
  bool isActive;
  DateTime? scheduledDate;
  String? scheduledTime;

  Task({
    required this.taskId,
    required this.label,
    this.description,
    required this.type,
    required this.offsetDays,
    required this.defaultTime,
    required this.repeat,
    required this.channel,
    this.isActive = true,
    this.scheduledDate,
    this.scheduledTime,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['taskId'] as String,
      label: json['label'] as String,
      description: json['description'] as String?,
      type: TaskType.fromString(json['type'] as String),
      offsetDays: json['offsetDays'] as int,
      defaultTime: json['defaultTime'] as String,
      repeat: RepeatFrequency.fromString(json['repeat'] as String),
      channel: json['channel'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'label': label,
      'description': description,
      'type': type.value,
      'offsetDays': offsetDays,
      'defaultTime': defaultTime,
      'repeat': repeat.value,
      'channel': channel,
      'isActive': isActive,
    };
  }

  Task copyWith({
    bool? isActive,
    DateTime? scheduledDate,
    String? scheduledTime,
  }) {
    return Task(
      taskId: taskId,
      label: label,
      description: description,
      type: type,
      offsetDays: offsetDays,
      defaultTime: defaultTime,
      repeat: repeat,
      channel: channel,
      isActive: isActive ?? this.isActive,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
    );
  }
}

/// Tipo de tarea
enum TaskType {
  vaccine('vaccine', 'Vacuna', '💉'),
  medication('medication', 'Medicación', '💊'),
  appointment('appointment', 'Cita', '📅'),
  grooming('grooming', 'Aseo', '✂️');

  final String value;
  final String displayName;
  final String emoji;

  const TaskType(this.value, this.displayName, this.emoji);

  static TaskType fromString(String value) {
    return TaskType.values.firstWhere((e) => e.value == value);
  }
}

/// Frecuencia de repetición
enum RepeatFrequency {
  none('none', 'Una vez'),
  daily('daily', 'Diario'),
  weekly('weekly', 'Semanal'),
  monthly('monthly', 'Mensual');

  final String value;
  final String displayName;

  const RepeatFrequency(this.value, this.displayName);

  static RepeatFrequency fromString(String value) {
    return RepeatFrequency.values.firstWhere((e) => e.value == value);
  }
}
