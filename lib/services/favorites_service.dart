import 'package:shared_preferences/shared_preferences.dart';

/// Servicio singleton para gestionar favoritos de veterinarias
/// PROC-004: Veterinarias Cercanas - PASO E
/// 
/// Proporciona persistencia local usando SharedPreferences
class FavoritesService {
  // Singleton pattern
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  // Key para SharedPreferences
  static const String _key = 'favorite_vets';

  // Estado interno
  Set<String> _favoriteIds = {};
  bool _initialized = false;

  /// Inicializa el servicio cargando favoritos desde SharedPreferences
  /// Solo se ejecuta una vez gracias al flag _initialized
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> stored = prefs.getStringList(_key) ?? [];
      _favoriteIds = Set.from(stored);
      _initialized = true;
    } catch (e) {
      // En caso de error, continuar con Set vacío
      _favoriteIds = {};
      _initialized = true;
    }
  }

  /// Toggle favorito: agrega si no existe, remueve si existe
  /// Retorna el nuevo estado (true = es favorito, false = no es favorito)
  Future<bool> toggleFavorite(String vetId) async {
    await initialize();
    
    if (_favoriteIds.contains(vetId)) {
      _favoriteIds.remove(vetId);
    } else {
      _favoriteIds.add(vetId);
    }
    
    await _save();
    return _favoriteIds.contains(vetId);
  }

  /// Verifica si una veterinaria es favorita
  Future<bool> isFavorite(String vetId) async {
    await initialize();
    return _favoriteIds.contains(vetId);
  }

  /// Obtiene el Set completo de IDs favoritos
  Future<Set<String>> getFavorites() async {
    await initialize();
    return Set.from(_favoriteIds);
  }

  /// Guarda el estado actual en SharedPreferences
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, _favoriteIds.toList());
    } catch (e) {
      // Log error pero no bloquear la UI
      // En producción usar logger adecuado
    }
  }

  /// Limpia todos los favoritos (útil para testing o reset)
  Future<void> clearAll() async {
    await initialize();
    _favoriteIds.clear();
    await _save();
  }

  /// Obtiene la cantidad de favoritos
  Future<int> getCount() async {
    await initialize();
    return _favoriteIds.length;
  }
}
