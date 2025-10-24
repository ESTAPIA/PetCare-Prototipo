/// Modelo de reseña/review para veterinarias
/// Representa la opinión de un usuario sobre un servicio veterinario
class Review {
  final String id;
  final String veterinariaId; // ID de la veterinaria asociada
  final String userName;
  final double rating; // 1.0-5.0
  final String comment;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.veterinariaId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  /// Obtiene las iniciales del usuario para avatar placeholder
  String get userInitials {
    final parts = userName.trim().split(' ');
    if (parts.isEmpty) return '?';
    
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  /// Fecha relativa para mostrar (ej: "Hace 2 días")
  String get fechaRelativa {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(timestamp);

    if (diferencia.inDays > 365) {
      final years = (diferencia.inDays / 365).floor();
      return years == 1 ? 'Hace 1 año' : 'Hace $years años';
    } else if (diferencia.inDays > 30) {
      final months = (diferencia.inDays / 30).floor();
      return months == 1 ? 'Hace 1 mes' : 'Hace $months meses';
    } else if (diferencia.inDays > 0) {
      return diferencia.inDays == 1 ? 'Hace 1 día' : 'Hace ${diferencia.inDays} días';
    } else if (diferencia.inHours > 0) {
      return diferencia.inHours == 1 ? 'Hace 1 hora' : 'Hace ${diferencia.inHours} horas';
    } else {
      return 'Hace unos minutos';
    }
  }

  /// Color para avatar basado en iniciales (para variedad visual)
  int get avatarColorSeed {
    return userName.hashCode;
  }
}
