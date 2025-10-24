import 'dart:math';

/// Modelo de veterinaria para PROC-004
/// Representa un centro veterinario con toda su información
class Veterinaria {
  final String id;
  final String nombre;
  final String direccion;
  final String ciudad;
  final String telefono;
  final double latitude;
  final double longitude;
  final double rating; // 1.0-5.0
  final int reviewsCount;
  final List<String> servicios; // ['Emergencias 24h', 'Cirugía', ...]
  final Map<String, String> horarios; // {'Lunes': '8:00-20:00', ...}
  final List<String> fotos; // URLs o assets (placeholders)
  final List<String> especialidades; // ['Perros', 'Gatos', 'Aves', ...]
  final bool emergencias24h; // Atención 24 horas

  Veterinaria({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.ciudad,
    required this.telefono,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewsCount,
    required this.servicios,
    required this.horarios,
    this.fotos = const [],
    this.especialidades = const [],
    this.emergencias24h = false,
  });

  /// Calcula distancia desde coordenadas del usuario (simulado)
  /// userLat y userLng se pasan desde mock data
  double calcularDistancia(double userLat, double userLng) {
    // Fórmula Haversine simplificada para distancias cortas
    const double radioTierraKm = 6371.0;
    
    final double dLat = _toRadians(latitude - userLat);
    final double dLng = _toRadians(longitude - userLng);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(userLat)) * cos(_toRadians(latitude)) *
        sin(dLng / 2) * sin(dLng / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return radioTierraKm * c;
  }

  /// Convierte grados a radianes
  double _toRadians(double grados) {
    return grados * pi / 180;
  }

  /// Verifica si tiene un servicio específico
  bool tieneServicio(String servicio) {
    return servicios.any((s) => s.toLowerCase().contains(servicio.toLowerCase()));
  }

  /// Verifica si atiende una especialidad específica
  bool atiende(String especialidad) {
    return especialidades.any((e) => e.toLowerCase().contains(especialidad.toLowerCase()));
  }

  /// Obtiene el horario de hoy
  String? getHorarioHoy() {
    final diasSemana = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final hoy = DateTime.now().weekday - 1; // 0 = Lunes
    
    if (hoy >= 0 && hoy < diasSemana.length) {
      return horarios[diasSemana[hoy]];
    }
    
    return null;
  }

  /// Verifica si está abierto ahora (simulado con horarios)
  bool estaAbierto() {
    if (emergencias24h) return true;
    
    final horarioHoy = getHorarioHoy();
    if (horarioHoy == null || horarioHoy == 'Cerrado') return false;
    
    // Simplificación: si tiene horario y no es "Cerrado", está abierto
    // En un caso real, se compararía la hora actual con el rango
    final ahora = DateTime.now();
    final esFinDeSemana = ahora.weekday >= 6; // Sábado o Domingo
    
    // Asumimos que fines de semana algunos cierran
    if (esFinDeSemana && horarioHoy.contains('8:00-14:00')) {
      return ahora.hour >= 8 && ahora.hour < 14;
    }
    
    return true; // Simplificación para prototipo
  }

  /// Distancia formateada para mostrar
  String distanciaFormateada(double userLat, double userLng) {
    final km = calcularDistancia(userLat, userLng);
    if (km < 1) {
      return '${(km * 1000).round()} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }
}
