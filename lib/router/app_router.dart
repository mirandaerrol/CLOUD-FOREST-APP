import 'package:go_router/go_router.dart';

import '../screens/auth/auth_screens.dart';
import '../screens/client/client_screens.dart';
import '../screens/staff/staff_screens.dart';
import '../services/auth_provider.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          name: 'splash',
          path: '/splash',
          builder: (context, state) => SplashScreen(
            onFinish: () => context.go('/login'),
          ),
        ),
        GoRoute(
          name: 'login',
          path: '/login',
          builder: (context, state) => LoginScreen(
            onRegister: () => context.push('/register'),
          ),
        ),
        GoRoute(
          name: 'register',
          path: '/register',
          builder: (context, state) => RegistrationFlow(
            onBack: () => context.pop(),
            onFinish: () => context.go('/login'),
          ),
        ),
        GoRoute(
          name: 'client',
          path: '/client',
          builder: (context, state) => const ClientShell(),
          routes: [
            GoRoute(
              name: 'client_settings',
              path: 'settings',
              builder: (context, state) => const ClientSettingsPage(),
            ),
          ],
        ),
        GoRoute(
          name: 'staff',
          path: '/staff',
          builder: (context, state) => const StaffShell(),
        ),
      ],
      redirect: (context, state) {
        if (!authProvider.isInitialized) return '/splash';

        final isLoggedIn = authProvider.isLoggedIn;
        final isLoggingIn = state.matchedLocation == '/login' || 
                            state.matchedLocation == '/register' ||
                            state.matchedLocation == '/splash';

        if (!isLoggedIn) {
          return isLoggingIn ? null : '/login';
        }

        // If logged in but on auth screens, redirect to appropriate home
        if (isLoggingIn) {
          return authProvider.isClient ? '/client' : '/staff';
        }

        return null;
      },
    );
  }
}
