/// Modelo de Mascota
/// PROC-001: Gestión de Mascotas
class Pet {
  final String id;
  final String nombre;
  final PetSpecies especie;
  final String? raza;
  final PetGender? sexo;
  final DateTime? fechaNacimiento;
  final double? pesoKg;
  final String? fotoPath; // Ruta local de la foto
  final String? notas;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  Pet({
    required this.id,
    required this.nombre,
    required this.especie,
    this.raza,
    this.sexo,
    this.fechaNacimiento,
    this.pesoKg,
    this.fotoPath,
    this.notas,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  })  : fechaCreacion = fechaCreacion ?? DateTime.now(),
        fechaActualizacion = fechaActualizacion ?? DateTime.now();

  /// Calcular edad en años
  int? get edad {
    if (fechaNacimiento == null) return null;
    final now = DateTime.now();
    int years = now.year - fechaNacimiento!.year;
    if (now.month < fechaNacimiento!.month ||
        (now.month == fechaNacimiento!.month &&
            now.day < fechaNacimiento!.day)) {
      years--;
    }
    return years;
  }

  /// Obtener inicial del nombre para avatar
  String get inicial {
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  /// Descripción corta para subtítulos (ej. "Perra mestiza, 3 años")
  String get descripcionCorta {
    final partes = <String>[];
    
    // Especie y sexo
    if (sexo != null) {
      partes.add('${sexo!.displayName} ${especie.displayName.toLowerCase()}');
    } else {
      partes.add(especie.displayName);
    }
    
    // Raza si existe
    if (raza != null && raza!.isNotEmpty) {
      partes.add(raza!);
    }
    
    // Edad si existe
    if (edad != null) {
      partes.add('$edad ${edad == 1 ? "año" : "años"}');
    }
    
    return partes.join(', ');
  }

  /// Validar nombre (1-30 caracteres, no solo espacios)
  static String? validarNombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    if (value.trim().length > 30) {
      return 'El nombre no puede superar 30 caracteres';
    }
    return null;
  }

  /// Validar raza (0-40 caracteres)
  static String? validarRaza(String? value) {
    if (value != null && value.length > 40) {
      return 'La raza no puede superar 40 caracteres';
    }
    return null;
  }

  /// Validar peso (0.1-120.0 kg)
  static String? validarPeso(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final peso = double.tryParse(value);
    if (peso == null) {
      return 'Ingresa un número válido';
    }
    if (peso < 0.1 || peso > 120.0) {
      return 'Ingresa un peso entre 0.1 y 120 kg';
    }
    return null;
  }

  /// Validar fecha de nacimiento (no futura)
  static String? validarFechaNacimiento(DateTime? fecha) {
    if (fecha == null) return null;
    
    if (fecha.isAfter(DateTime.now())) {
      return 'La fecha no puede ser futura';
    }
    return null;
  }

  /// Validar notas (0-200 caracteres)
  static String? validarNotas(String? value) {
    if (value != null && value.length > 200) {
      return 'Las notas no pueden superar 200 caracteres';
    }
    return null;
  }

  /// Copiar con modificaciones
  Pet copyWith({
    String? id,
    String? nombre,
    PetSpecies? especie,
    String? raza,
    PetGender? sexo,
    DateTime? fechaNacimiento,
    double? pesoKg,
    String? fotoPath,
    String? notas,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return Pet(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      especie: especie ?? this.especie,
      raza: raza ?? this.raza,
      sexo: sexo ?? this.sexo,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      pesoKg: pesoKg ?? this.pesoKg,
      fotoPath: fotoPath ?? this.fotoPath,
      notas: notas ?? this.notas,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? DateTime.now(),
    );
  }

  /// Convertir a JSON para persistencia
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'especie': especie.name,
      'raza': raza,
      'sexo': sexo?.name,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'pesoKg': pesoKg,
      'fotoPath': fotoPath,
      'notas': notas,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActualizacion': fechaActualizacion.toIso8601String(),
    };
  }

  /// Crear desde JSON
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      especie: PetSpecies.values.firstWhere(
        (e) => e.name == json['especie'],
        orElse: () => PetSpecies.otro,
      ),
      raza: json['raza'] as String?,
      sexo: json['sexo'] != null
          ? PetGender.values.firstWhere(
              (e) => e.name == json['sexo'],
              orElse: () => PetGender.noEspecifica,
            )
          : null,
      fechaNacimiento: json['fechaNacimiento'] != null
          ? DateTime.parse(json['fechaNacimiento'] as String)
          : null,
      pesoKg: json['pesoKg'] != null ? (json['pesoKg'] as num).toDouble() : null,
      fotoPath: json['fotoPath'] as String?,
      notas: json['notas'] as String?,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      fechaActualizacion: DateTime.parse(json['fechaActualizacion'] as String),
    );
  }

  @override
  String toString() {
    return 'Pet(id: $id, nombre: $nombre, especie: ${especie.displayName})';
  }
}

/// Enum de especies de mascotas
enum PetSpecies {
  perro,
  gato,
  ave,
  conejo,
  otro;

  String get displayName {
    switch (this) {
      case PetSpecies.perro:
        return 'Perro';
      case PetSpecies.gato:
        return 'Gato';
      case PetSpecies.ave:
        return 'Ave';
      case PetSpecies.conejo:
        return 'Conejo';
      case PetSpecies.otro:
        return 'Otro';
    }
  }

  String get emoji {
    switch (this) {
      case PetSpecies.perro:
        return '🐕';
      case PetSpecies.gato:
        return '🐈';
      case PetSpecies.ave:
        return '🦜';
      case PetSpecies.conejo:
        return '🐇';
      case PetSpecies.otro:
        return '🐾';
    }
  }
}

/// Enum de género/sexo
enum PetGender {
  macho,
  hembra,
  noEspecifica;

  String get displayName {
    switch (this) {
      case PetGender.macho:
        return 'Macho';
      case PetGender.hembra:
        return 'Hembra';
      case PetGender.noEspecifica:
        return 'No especifica';
    }
  }

  String get emoji {
    switch (this) {
      case PetGender.macho:
        return '♂️';
      case PetGender.hembra:
        return '♀️';
      case PetGender.noEspecifica:
        return '⚪';
    }
  }
}
