import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';

/// Repository mock para gestión de mascotas con persistencia local
/// PROC-001: Gestión de Mascotas
class MockPetsRepository {
  static const String _kPetsKey = 'pets_data';
  static List<Pet>? _cachedPets;

  /// Obtener todas las mascotas
  static Future<List<Pet>> getAllPets() async {
    // Usar caché si existe
    if (_cachedPets != null) {
      return List.from(_cachedPets!);
    }

    final prefs = await SharedPreferences.getInstance();
    final petsJson = prefs.getString(_kPetsKey);

    if (petsJson == null || petsJson.isEmpty) {
      // Primera vez: cargar datos iniciales
      _cachedPets = _getInitialPets();
      await _savePets(_cachedPets!);
      return List.from(_cachedPets!);
    }

    try {
      final List<dynamic> decoded = json.decode(petsJson);
      _cachedPets = decoded.map((json) => Pet.fromJson(json)).toList();
      return List.from(_cachedPets!);
    } catch (e) {
      // Error al decodificar: usar datos iniciales
      _cachedPets = _getInitialPets();
      await _savePets(_cachedPets!);
      return List.from(_cachedPets!);
    }
  }

  /// Obtener mascota por ID
  static Future<Pet?> getPetById(String id) async {
    final pets = await getAllPets();
    try {
      return pets.firstWhere((pet) => pet.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Crear nueva mascota
  static Future<bool> createPet(Pet pet) async {
    try {
      final pets = await getAllPets();
      
      // Verificar que no exista el ID
      if (pets.any((p) => p.id == pet.id)) {
        return false;
      }

      pets.add(pet);
      await _savePets(pets);
      _cachedPets = pets;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Actualizar mascota existente
  static Future<bool> updatePet(Pet pet) async {
    try {
      final pets = await getAllPets();
      final index = pets.indexWhere((p) => p.id == pet.id);

      if (index == -1) {
        return false;
      }

      pets[index] = pet.copyWith(fechaActualizacion: DateTime.now());
      await _savePets(pets);
      _cachedPets = pets;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Eliminar mascota
  static Future<bool> deletePet(String id) async {
    try {
      final pets = await getAllPets();
      final initialLength = pets.length;

      pets.removeWhere((pet) => pet.id == id);

      if (pets.length == initialLength) {
        return false; // No se encontró
      }

      await _savePets(pets);
      _cachedPets = pets;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Limpiar caché (útil para testing o logout)
  static void clearCache() {
    _cachedPets = null;
  }

  /// Resetear a datos iniciales (útil para desarrollo)
  static Future<void> resetToInitialData() async {
    _cachedPets = _getInitialPets();
    await _savePets(_cachedPets!);
  }

  /// Guardar mascotas en SharedPreferences
  static Future<void> _savePets(List<Pet> pets) async {
    final prefs = await SharedPreferences.getInstance();
    final petsJson = json.encode(pets.map((pet) => pet.toJson()).toList());
    await prefs.setString(_kPetsKey, petsJson);
  }

  /// Datos iniciales (Luna y Max)
  static List<Pet> _getInitialPets() {
    final now = DateTime.now();
    
    return [
      Pet(
        id: 'pet-001',
        nombre: 'Luna',
        especie: PetSpecies.perro,
        raza: 'Mestiza',
        sexo: PetGender.hembra,
        fechaNacimiento: DateTime(now.year - 3, 3, 15),
        pesoKg: 15.5,
        notas: 'Le gusta jugar con pelota roja. Muy sociable con otros perros.',
        fechaCreacion: DateTime(2025, 1, 10, 14, 30),
        fechaActualizacion: DateTime(2025, 1, 15, 9, 15),
      ),
      Pet(
        id: 'pet-002',
        nombre: 'Max',
        especie: PetSpecies.gato,
        raza: 'Persa',
        sexo: PetGender.macho,
        fechaNacimiento: DateTime(now.year - 5, 7, 20),
        pesoKg: 5.2,
        notas: 'Prefiere estar en lugares altos. Le gusta el atún.',
        fechaCreacion: DateTime(2024, 11, 5, 16, 45),
        fechaActualizacion: DateTime(2025, 1, 12, 11, 20),
      ),
    ];
  }
}
