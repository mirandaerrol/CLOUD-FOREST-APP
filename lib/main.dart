import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/auth_provider.dart';
import 'screens/auth/auth_screens.dart';
import 'screens/client/client_screens.dart';
import 'screens/staff/staff_screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const CloudForestApp());
}

class CloudForestApp extends StatelessWidget {
  const CloudForestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => MockApiService()),
        ChangeNotifierProxyProvider<ApiService, AuthProvider>(
          create: (ctx) => AuthProvider(ctx.read<ApiService>()),
          update: (ctx, api, prev) => prev ?? AuthProvider(api),
        ),
      ],
      child: MaterialApp(
        title: 'CloudForest IT Solutions',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const AppRoot(),
        routes: {
          '/client/settings': (ctx) => const ClientSettingsPage(),
        },
      ),
    );
  }
}

// ============================================================
// APP ROOT - handles splash → auth → home routing
// ============================================================

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  _AppView _currentView = _AppView.splash;

  void _navigate(_AppView view) {
    setState(() => _currentView = view);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Auto-navigate based on auth state
    if (auth.isLoggedIn) {
      return auth.isClient ? const ClientShell() : const StaffShell();
    }

    return Scaffold(
      body: _buildView(),
    );
  }

  Widget _buildView() {
    switch (_currentView) {
      case _AppView.splash:
        return SplashScreen(
          onFinish: () => _navigate(_AppView.login),
        );
      case _AppView.login:
        return LoginScreen(
          onRegister: () => _navigate(_AppView.register),
        );
      case _AppView.register:
        return RegistrationFlow(
          onBack: () => _navigate(_AppView.login),
          onFinish: () => _navigate(_AppView.login),
        );
    }
  }
}

enum _AppView { splash, login, register }
