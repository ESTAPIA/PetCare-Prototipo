import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_spacing.dart';
import 'app_routes.dart';

// Importar pantallas base
import '../screens/home/home_screen.dart';
import '../screens/reminders/reminder_list_screen.dart';
import '../screens/vets/vet_map_screen.dart';
import '../screens/chat/chat_home_screen.dart';

// Importar pantallas de Plan
import '../screens/plans/plan_template_list_screen.dart';
// import '../screens/plans/plan_template_detail_screen.dart'; // TODO: Implementar routing
// import '../screens/plans/plan_customize_screen.dart'; // TODO: Implementar routing
// import '../screens/plans/plan_review_screen.dart'; // TODO: Implementar routing
// import '../screens/plans/plan_success_screen.dart'; // TODO: Implementar routing

/// Bottom Navigation Bar de 5 tabs para PetCare
/// Basado en documentación: 01-mapa-navegacion.md
///
/// Los 5 tabs son:
/// 1. Inicio - Dashboard y Mascotas (PROC-001)
/// 2. Plan - Plan de Cuidado Rápido (PROC-002)
/// 3. Recordatorios - Agenda y Notificaciones (PROC-003)
/// 4. Veterinarias - Búsqueda en Mapa (PROC-004)
/// 5. Consulta - Chat Express (PROC-005)
class PetCareBottomNavBar extends StatelessWidget {
  /// Índice del tab actualmente seleccionado (0-4)
  final int currentIndex;

  /// Callback cuando se selecciona un tab diferente
  final ValueChanged<int> onTabSelected;

  const PetCareBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabSelected,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: AppTypography.label,
      unselectedLabelStyle: AppTypography.caption,
      elevation: 8,
      items: const [
        // TAB 1: INICIO (Dashboard + Mascotas)
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Inicio',
          tooltip: 'Inicio y Mis Mascotas',
        ),

        // TAB 2: PLAN DE CUIDADO
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Plan',
          tooltip: 'Plan de Cuidado Rápido',
        ),

        // TAB 3: RECORDATORIOS
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          activeIcon: Icon(Icons.notifications),
          label: 'Recordatorios',
          tooltip: 'Agenda de Recordatorios',
        ),

        // TAB 4: VETERINARIAS
        BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital_outlined),
          activeIcon: Icon(Icons.local_hospital),
          label: 'Veterinarias',
          tooltip: 'Buscar Veterinarias Cercanas',
        ),

        // TAB 5: CONSULTA EXPRESS
        // H6: Reconocimiento - portapapeles médico identifica consulta profesional veterinaria
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_information_outlined),
          activeIcon: Icon(Icons.medical_information),
          label: 'Consulta',
          tooltip: 'Consulta Express',
        ),
      ],
    );
  }
}

/// Widget principal que maneja la navegación entre tabs
/// Mantiene el estado de cada tab preservado
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => MainNavigatorState();
}

class MainNavigatorState extends State<MainNavigator> {
  /// Índice del tab actualmente activo
  int _currentTabIndex = AppRoutes.tabHome;

  /// GlobalKeys para preservar el estado de cada Navigator de tab
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // Tab Inicio
    GlobalKey<NavigatorState>(), // Tab Plan
    GlobalKey<NavigatorState>(), // Tab Recordatorios
    GlobalKey<NavigatorState>(), // Tab Veterinarias
    GlobalKey<NavigatorState>(), // Tab Consulta
  ];

  /// GlobalKey para acceder al estado de HomeScreen
  final GlobalKey<HomeScreenState> _homeScreenKey = GlobalKey<HomeScreenState>();

  /// Cambiar al tab seleccionado
  void _selectTab(int index) {
    if (_currentTabIndex == index) {
      // Si se toca el tab Inicio estando ya en Inicio, resetear
      if (index == AppRoutes.tabHome) {
        _resetHomeScreen();
      }
      // Para otros tabs, no hacer nada (comportamiento estándar)
      return;
    } else {
      // Cambiar al nuevo tab
      setState(() {
        _currentTabIndex = index;
      });
    }
  }

  /// Cambiar al tab especificado programáticamente
  /// 
  /// Método público para que pantallas hijas puedan cambiar de tab
  /// Útil para navegación desde pantallas como plan_success_screen
  void navigateToTab(int tabIndex) {
    if (tabIndex >= 0 && tabIndex < 5 && tabIndex != _currentTabIndex) {
      setState(() {
        _currentTabIndex = tabIndex;
      });
    }
  }

  /// Resetear el estado del HomeScreen (scroll al top + recargar datos)
  /// 
  /// Observación del profesor: Cuando el usuario presiona "Inicio"
  /// desde otro tab, debe volver al estado inicial (top de la pantalla)
  void _resetHomeScreen() {
    final homeState = _homeScreenKey.currentState;
    if (homeState != null) {
      // Verificar que no estamos en rutas de creación/edición
      final currentNavigator = _navigatorKeys[AppRoutes.tabHome].currentState;
      final currentRoute = ModalRoute.of(currentNavigator!.context)?.settings.name;
      
      // No resetear si estamos en /pet/new o /pet/edit
      if (currentRoute != null && 
          (currentRoute.contains('/new') || currentRoute.contains('/edit'))) {
        return;
      }
      
      // Scrollear al top y refrescar datos
      homeState.resetToTop();
    }
  }

  /// Manejar el botón "atrás" del sistema
  bool _onWillPop() {
    final currentNavigator = _navigatorKeys[_currentTabIndex].currentState;

    // Si el tab actual tiene pantallas en el stack, hacer pop
    if (currentNavigator != null && currentNavigator.canPop()) {
      currentNavigator.pop();
      return false; // No salir de la app
    }

    // Si estamos en la raíz de cualquier tab que no sea Inicio, ir a Inicio
    if (_currentTabIndex != AppRoutes.tabHome) {
      setState(() {
        _currentTabIndex = AppRoutes.tabHome;
      });
      return false; // No salir de la app
    }

    // Si estamos en la raíz del tab Inicio, permitir salir de la app
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final shouldPop = _onWillPop();
        if (shouldPop) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentTabIndex,
          children: [
            // TAB 1: INICIO
            _buildTabNavigator(
              navigatorKey: _navigatorKeys[AppRoutes.tabHome],
              initialRoute: AppRoutes.home,
            ),

            // TAB 2: PLAN
            _buildTabNavigator(
              navigatorKey: _navigatorKeys[AppRoutes.tabPlan],
              initialRoute: AppRoutes.planTemplates,
            ),

            // TAB 3: RECORDATORIOS
            _buildTabNavigator(
              navigatorKey: _navigatorKeys[AppRoutes.tabReminders],
              initialRoute: AppRoutes.reminders,
            ),

            // TAB 4: VETERINARIAS
            _buildTabNavigator(
              navigatorKey: _navigatorKeys[AppRoutes.tabVets],
              initialRoute: AppRoutes.vets,
            ),

            // TAB 5: CONSULTA
            _buildTabNavigator(
              navigatorKey: _navigatorKeys[AppRoutes.tabConsult],
              initialRoute: AppRoutes.consult,
            ),
          ],
        ),
        bottomNavigationBar: PetCareBottomNavBar(
          currentIndex: _currentTabIndex,
          onTabSelected: _selectTab,
        ),
      ),
    );
  }

  /// Construir Navigator para un tab específico
  Widget _buildTabNavigator({
    required GlobalKey<NavigatorState> navigatorKey,
    required String initialRoute,
  }) {
    return Navigator(
      key: navigatorKey,
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        // Bug fix: Si la ruta es '/', usar el initialRoute del tab
        // Esto ocurre cuando popUntil(route.isFirst) limpia el stack
        final routeName = (settings.name == null || settings.name == '/') 
            ? initialRoute 
            : settings.name!;
        
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => _buildScreen(route: routeName),
        );
      },
    );
  }

  /// Pantalla placeholder temporal (será reemplazada en Sección E - Fase 3)
  Widget _buildPlaceholderScreen({required String route}) {
    // Determinar título según la ruta
    String title = 'PetCare';
    IconData icon = Icons.pets;
    String subtitle = 'Pantalla en construcción';

    if (route.startsWith('/home') || route.startsWith('/pet')) {
      title = 'Inicio';
      subtitle = 'Dashboard y Mascotas';
      icon = Icons.home;
    } else if (route.startsWith('/plan')) {
      title = 'Plan de Cuidado';
      subtitle = 'Plantillas y Calendario';
      icon = Icons.calendar_today;
    } else if (route.startsWith('/reminders')) {
      title = 'Recordatorios';
      subtitle = 'Agenda de Notificaciones';
      icon = Icons.notifications;
    } else if (route.startsWith('/vets')) {
      title = 'Veterinarias';
      subtitle = 'Búsqueda en Mapa';
      icon = Icons.local_hospital;
    } else if (route.startsWith('/consult')) {
      title = 'Consulta Express';
      subtitle = 'Chat con Veterinario';
      icon = Icons.chat;
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppColors.primary),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTypography.h1),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Text(
                'Ruta: $route',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construir la pantalla correspondiente a la ruta
  Widget _buildScreen({required String route}) {
    // Tab Inicio: HomeScreen como pantalla principal
    if (route == AppRoutes.home ||
        route.startsWith('/home') ||
        route.startsWith('/pet')) {
      return HomeScreen(key: _homeScreenKey);
    }

    // Tab Plan: PlanTemplateListScreen como pantalla principal
    if (route == AppRoutes.planTemplates || route.startsWith('/plan')) {
      return const PlanTemplateListScreen();
    }

    // Tab Recordatorios: ReminderListScreen como pantalla principal
    if (route == AppRoutes.reminders || route.startsWith('/reminders')) {
      return const ReminderListScreen();
    }

    // Tab Veterinarias: VetMapScreen como pantalla principal
    if (route == AppRoutes.vets || route.startsWith('/vets')) {
      return const VetMapScreen();
    }

    // Tab Consulta: ChatHomeScreen como pantalla principal
    if (route == AppRoutes.consult || route.startsWith('/consult')) {
      return const ChatHomeScreen();
    }

    // Ruta no encontrada - mostrar _buildPlaceholderScreen
    return _buildPlaceholderScreen(route: route);
  }
}
