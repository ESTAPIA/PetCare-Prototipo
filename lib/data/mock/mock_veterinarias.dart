import '../models/veterinaria.dart';
import '../models/review.dart';

/// Datos mock de veterinarias para PROC-004
/// Simula 6 veterinarias en Quito con datos realistas
class MockVeterinarias {
  // Coordenadas simuladas del usuario (Centro Histórico de Quito)
  static const double userLat = -0.2201641;
  static const double userLng = -78.5123274;

  /// Obtiene la lista completa de veterinarias mock
  static List<Veterinaria> getVeterinarias() {
    return [
      // Veterinaria 1: Cerca, alta calificación, emergencias 24h
      Veterinaria(
        id: 'vet-001',
        nombre: 'Veterinaria San Marcos',
        direccion: 'Av. América N39-115 y Naciones Unidas',
        ciudad: 'Quito',
        telefono: '02-2456789',
        latitude: -0.1807,
        longitude: -78.4889,
        rating: 4.8,
        reviewsCount: 124,
        emergencias24h: true,
        servicios: [
          'Emergencias 24h',
          'Cirugía',
          'Hospitalización',
          'Laboratorio',
          'Rayos X',
          'Vacunación',
        ],
        especialidades: ['Perros', 'Gatos', 'Aves'],
        horarios: {
          'Lunes': '24 horas',
          'Martes': '24 horas',
          'Miércoles': '24 horas',
          'Jueves': '24 horas',
          'Viernes': '24 horas',
          'Sábado': '24 horas',
          'Domingo': '24 horas',
        },
        fotos: ['assets/images/vet1.jpg'],
      ),

      // Veterinaria 2: Más cerca, especializada en peluquería
      Veterinaria(
        id: 'vet-002',
        nombre: 'Clínica Veterinaria Patitas',
        direccion: 'Av. 10 de Agosto N35-98 y Villalengua',
        ciudad: 'Quito',
        telefono: '02-2334455',
        latitude: -0.1950,
        longitude: -78.4950,
        rating: 4.5,
        reviewsCount: 87,
        emergencias24h: false,
        servicios: [
          'Consulta general',
          'Peluquería',
          'Vacunación',
          'Desparasitación',
          'Baño y corte',
        ],
        especialidades: ['Perros', 'Gatos'],
        horarios: {
          'Lunes': '9:00-19:00',
          'Martes': '9:00-19:00',
          'Miércoles': '9:00-19:00',
          'Jueves': '9:00-19:00',
          'Viernes': '9:00-19:00',
          'Sábado': '9:00-14:00',
          'Domingo': 'Cerrado',
        },
        fotos: ['assets/images/vet2.jpg'],
      ),

      // Veterinaria 3: Lejos, emergencias 24h
      Veterinaria(
        id: 'vet-003',
        nombre: 'VetCenter 24H',
        direccion: 'Av. 6 de Diciembre N34-451 y Checoslovaquia',
        ciudad: 'Quito',
        telefono: '02-2987654',
        latitude: -0.1650,
        longitude: -78.4800,
        rating: 4.3,
        reviewsCount: 203,
        emergencias24h: true,
        servicios: [
          'Emergencias 24h',
          'UCI Veterinaria',
          'Cirugía especializada',
          'Traumatología',
          'Hospitalización',
          'Ambulancia veterinaria',
        ],
        especialidades: ['Perros', 'Gatos', 'Animales exóticos'],
        horarios: {
          'Lunes': '24 horas',
          'Martes': '24 horas',
          'Miércoles': '24 horas',
          'Jueves': '24 horas',
          'Viernes': '24 horas',
          'Sábado': '24 horas',
          'Domingo': '24 horas',
        },
        fotos: ['assets/images/vet3.jpg'],
      ),

      // Veterinaria 4: Media distancia, especialistas exóticos
      Veterinaria(
        id: 'vet-004',
        nombre: 'Hospital Veterinario PetCare',
        direccion: 'Av. Eloy Alfaro N45-120 y Av. De los Granados',
        ciudad: 'Quito',
        telefono: '02-2445566',
        latitude: -0.1500,
        longitude: -78.4700,
        rating: 4.9,
        reviewsCount: 156,
        emergencias24h: false,
        servicios: [
          'Consulta especializada',
          'Cirugía',
          'Endocrinología',
          'Cardiología',
          'Dermatología',
          'Oftalmología',
        ],
        especialidades: ['Perros', 'Gatos', 'Aves', 'Reptiles', 'Conejos'],
        horarios: {
          'Lunes': '8:00-20:00',
          'Martes': '8:00-20:00',
          'Miércoles': '8:00-20:00',
          'Jueves': '8:00-20:00',
          'Viernes': '8:00-20:00',
          'Sábado': '9:00-15:00',
          'Domingo': 'Cerrado',
        },
        fotos: ['assets/images/vet4.jpg'],
      ),

      // Veterinaria 5: Cerca del usuario, económica
      Veterinaria(
        id: 'vet-005',
        nombre: 'Veterinaria Amigos Peludos',
        direccion: 'García Moreno N8-49 y Sucre',
        ciudad: 'Quito',
        telefono: '02-2558899',
        latitude: -0.2180,
        longitude: -78.5100,
        rating: 4.2,
        reviewsCount: 45,
        emergencias24h: false,
        servicios: [
          'Consulta general',
          'Vacunación',
          'Desparasitación',
          'Esterilización',
          'Peluquería básica',
        ],
        especialidades: ['Perros', 'Gatos'],
        horarios: {
          'Lunes': '10:00-18:00',
          'Martes': '10:00-18:00',
          'Miércoles': '10:00-18:00',
          'Jueves': '10:00-18:00',
          'Viernes': '10:00-18:00',
          'Sábado': '10:00-13:00',
          'Domingo': 'Cerrado',
        },
        fotos: ['assets/images/vet5.jpg'],
      ),

      // Veterinaria 6: Muy lejos, especializada en cirugía
      Veterinaria(
        id: 'vet-006',
        nombre: 'Centro Quirúrgico Veterinario',
        direccion: 'Av. Occidental N88-12 y Av. Mariana de Jesús',
        ciudad: 'Quito',
        telefono: '02-2776655',
        latitude: -0.1200,
        longitude: -78.5200,
        rating: 4.7,
        reviewsCount: 98,
        emergencias24h: false,
        servicios: [
          'Cirugía avanzada',
          'Ortopedia',
          'Neurocirugía',
          'Oncología',
          'Anestesiología',
          'Rehabilitación post-quirúrgica',
        ],
        especialidades: ['Perros', 'Gatos'],
        horarios: {
          'Lunes': '8:00-17:00',
          'Martes': '8:00-17:00',
          'Miércoles': '8:00-17:00',
          'Jueves': '8:00-17:00',
          'Viernes': '8:00-17:00',
          'Sábado': 'Cerrado',
          'Domingo': 'Cerrado',
        },
        fotos: ['assets/images/vet6.jpg'],
      ),
    ];
  }

  /// Obtiene una veterinaria específica por ID
  static Veterinaria? getVeterinariaById(String id) {
    try {
      return getVeterinarias().firstWhere((vet) => vet.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene veterinarias ordenadas por distancia
  static List<Veterinaria> getVeterinariasPorDistancia() {
    final vets = getVeterinarias();
    vets.sort((a, b) {
      final distA = a.calcularDistancia(userLat, userLng);
      final distB = b.calcularDistancia(userLat, userLng);
      return distA.compareTo(distB);
    });
    return vets;
  }

  /// Filtra veterinarias por emergencias 24h
  static List<Veterinaria> getVeterinarias24h() {
    return getVeterinarias().where((vet) => vet.emergencias24h).toList();
  }

  /// Filtra veterinarias por servicio específico
  static List<Veterinaria> getVeterinariasPorServicio(String servicio) {
    return getVeterinarias()
        .where((vet) => vet.tieneServicio(servicio))
        .toList();
  }

  /// Filtra veterinarias por especialidad
  static List<Veterinaria> getVeterinariasPorEspecialidad(String especialidad) {
    return getVeterinarias()
        .where((vet) => vet.atiende(especialidad))
        .toList();
  }

  /// Obtiene reviews para una veterinaria específica
  static List<Review> getReviewsForVet(String veterinariaId) {
    // Mock de reviews específicas por veterinaria
    final Map<String, List<Review>> reviewsMap = {
      'vet-001': [
        Review(
          id: 'rev-001',
          veterinariaId: 'vet-001',
          userName: 'María González',
          rating: 5.0,
          comment: 'Excelente atención de emergencia. Salvaron a mi perro después de un accidente. El personal es muy profesional y empático.',
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Review(
          id: 'rev-002',
          veterinariaId: 'vet-001',
          userName: 'Carlos Ramírez',
          rating: 4.5,
          comment: 'Muy buena clínica, disponible 24/7. Los precios son un poco elevados pero vale la pena por la calidad.',
          timestamp: DateTime.now().subtract(const Duration(days: 15)),
        ),
        Review(
          id: 'rev-003',
          veterinariaId: 'vet-001',
          userName: 'Ana Morales',
          rating: 5.0,
          comment: 'La Dra. Sánchez es increíble. Muy cariñosa con las mascotas y explica todo claramente. Recomendado 100%.',
          timestamp: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ],
      'vet-002': [
        Review(
          id: 'rev-004',
          veterinariaId: 'vet-002',
          userName: 'Luis Torres',
          rating: 4.0,
          comment: 'Buen servicio de peluquería. Mi golden quedó hermoso. La atención es rápida y los precios accesibles.',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Review(
          id: 'rev-005',
          veterinariaId: 'vet-002',
          userName: 'Patricia Díaz',
          rating: 5.0,
          comment: 'Llevé a mi gato para vacunación y quedé muy satisfecha. El trato es excelente y muy limpios.',
          timestamp: DateTime.now().subtract(const Duration(days: 12)),
        ),
        Review(
          id: 'rev-006',
          veterinariaId: 'vet-002',
          userName: 'Roberto Silva',
          rating: 4.5,
          comment: 'Buena relación calidad-precio. El grooming es profesional. Solo mejoraría los tiempos de espera.',
          timestamp: DateTime.now().subtract(const Duration(days: 20)),
        ),
      ],
      'vet-003': [
        Review(
          id: 'rev-007',
          veterinariaId: 'vet-003',
          userName: 'Gabriela Ortiz',
          rating: 4.0,
          comment: 'UCI veterinaria excelente. Atendieron a mi gato en estado crítico. Instalaciones modernas.',
          timestamp: DateTime.now().subtract(const Duration(days: 8)),
        ),
        Review(
          id: 'rev-008',
          veterinariaId: 'vet-003',
          userName: 'Fernando León',
          rating: 4.5,
          comment: 'Personal capacitado y equipos de última generación. Un poco caro pero garantizan buenos resultados.',
          timestamp: DateTime.now().subtract(const Duration(days: 25)),
        ),
        Review(
          id: 'rev-009',
          veterinariaId: 'vet-003',
          userName: 'Sofía Campos',
          rating: 4.5,
          comment: 'La ambulancia veterinaria es un servicio increíble. Llegaron rápido y salvaron a mi perro.',
          timestamp: DateTime.now().subtract(const Duration(days: 40)),
        ),
      ],
      'vet-004': [
        Review(
          id: 'rev-010',
          veterinariaId: 'vet-004',
          userName: 'Diego Vega',
          rating: 5.0,
          comment: 'Los mejores especialistas en animales exóticos. Atendieron a mi iguana con mucho profesionalismo.',
          timestamp: DateTime.now().subtract(const Duration(days: 7)),
        ),
        Review(
          id: 'rev-011',
          veterinariaId: 'vet-004',
          userName: 'Valeria Ruiz',
          rating: 5.0,
          comment: 'La cardióloga es excepcional. Salvó a mi gato con problemas cardíacos. Eternamente agradecida.',
          timestamp: DateTime.now().subtract(const Duration(days: 18)),
        ),
        Review(
          id: 'rev-012',
          veterinariaId: 'vet-004',
          userName: 'Andrés Castro',
          rating: 4.5,
          comment: 'Hospital muy completo. Tienen todas las especialidades. Precios acordes a la calidad del servicio.',
          timestamp: DateTime.now().subtract(const Duration(days: 35)),
        ),
      ],
      'vet-005': [
        Review(
          id: 'rev-013',
          veterinariaId: 'vet-005',
          userName: 'Carmen López',
          rating: 4.0,
          comment: 'Veterinaria de barrio confiable. Buenos precios y trato cercano. Ideal para consultas básicas.',
          timestamp: DateTime.now().subtract(const Duration(days: 10)),
        ),
        Review(
          id: 'rev-014',
          veterinariaId: 'vet-005',
          userName: 'Miguel Herrera',
          rating: 4.5,
          comment: 'Muy contentos con la esterilización de nuestra perrita. Precio justo y buen seguimiento post-operatorio.',
          timestamp: DateTime.now().subtract(const Duration(days: 22)),
        ),
        Review(
          id: 'rev-015',
          veterinariaId: 'vet-005',
          userName: 'Lucía Paredes',
          rating: 4.0,
          comment: 'Cerca de casa y accesible. El veterinario es amable aunque a veces hay que esperar un poco.',
          timestamp: DateTime.now().subtract(const Duration(days: 45)),
        ),
      ],
      'vet-006': [
        Review(
          id: 'rev-016',
          veterinariaId: 'vet-006',
          userName: 'Ricardo Mendoza',
          rating: 5.0,
          comment: 'Cirujanos expertos. Operaron a mi perro de la cadera y la recuperación fue excelente.',
          timestamp: DateTime.now().subtract(const Duration(days: 14)),
        ),
        Review(
          id: 'rev-017',
          veterinariaId: 'vet-006',
          userName: 'Isabel Flores',
          rating: 4.5,
          comment: 'Centro especializado en cirugía. El ortopedista es muy bueno. Instalaciones impecables.',
          timestamp: DateTime.now().subtract(const Duration(days: 28)),
        ),
        Review(
          id: 'rev-018',
          veterinariaId: 'vet-006',
          userName: 'Javier Rojas',
          rating: 4.5,
          comment: 'Atención pre y post operatoria excelente. El seguimiento es muy completo. Altamente recomendado.',
          timestamp: DateTime.now().subtract(const Duration(days: 50)),
        ),
      ],
    };

    return reviewsMap[veterinariaId] ?? [];
  }

  /// Obtiene todas las reviews (para testing)
  static List<Review> getAllReviews() {
    final List<Review> allReviews = [];
    for (final vet in getVeterinarias()) {
      allReviews.addAll(getReviewsForVet(vet.id));
    }
    return allReviews;
  }
}
