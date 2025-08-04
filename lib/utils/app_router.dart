import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../screens/search_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/add_item_screen.dart';
import '../screens/item_detail_screen.dart';
import '../screens/onboarding_screen.dart';
import '../models/reading_item.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding Screen
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main Shell Route with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // Home Screen
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Library Screen
          GoRoute(
            path: '/library',
            name: 'library',
            builder: (context, state) {
              final type = state.uri.queryParameters['type'];
              return LibraryScreen(initialType: type);
            },
          ),

          // Search Screen
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) {
              final query = state.uri.queryParameters['q'];
              return SearchScreen(initialQuery: query);
            },
          ),

          // Statistics Screen
          GoRoute(
            path: '/statistics',
            name: 'statistics',
            builder: (context, state) => const StatisticsScreen(),
          ),

          // Settings Screen
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // Add Item Screen (Full Screen)
      GoRoute(
        path: '/add-item',
        name: 'add-item',
        builder: (context, state) {
          final item = state.extra as ReadingItem?;
          return AddItemScreen(item: item);
        },
      ),

      // Item Detail Screen
      GoRoute(
        path: '/item/:id',
        name: 'item-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final item = state.extra as ReadingItem?;
          return ItemDetailScreen(itemId: id, item: item);
        },
      ),
    ],
  );
}

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-item'),
        child: const Icon(Icons.add),
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/':
        return 0;
      case '/library':
        return 1;
      case '/search':
        return 2;
      case '/statistics':
        return 3;
      case '/settings':
        return 4;
      default:
        return 0;
    }
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/library');
        break;
      case 2:
        context.go('/search');
        break;
      case 3:
        context.go('/statistics');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }
}

