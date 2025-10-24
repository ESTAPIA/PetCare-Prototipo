import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'navigation/main_navigator.dart';

/// Aplicación principal PetCare
/// Encapsula la configuración de MaterialApp con:
/// - Tema personalizado
/// - Localización español
/// - Navegación principal
class PetCareApp extends StatelessWidget {
  const PetCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ========================================
      // CONFIGURACIÓN GENERAL
      // ========================================
      title: 'PetCare',
      debugShowCheckedModeBanner: false,

      // ========================================
      // TEMA
      // ========================================
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,

      // ========================================
      // LOCALIZACIÓN
      // ========================================
      // Español como idioma principal
      locale: const Locale('es', 'ES'),
      supportedLocales: const [
        Locale('es', 'ES'), // Español
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ========================================
      // NAVEGACIÓN
      // ========================================
      home: const MainNavigator(),
    );
  }
}
