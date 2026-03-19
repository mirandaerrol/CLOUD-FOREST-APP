import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/auth_provider.dart';
import 'services/document_validator_service.dart';

import 'router/app_router.dart';
import 'repositories/auth_repository.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'services/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(CloudForestApp(prefs: prefs));
}

class CloudForestApp extends StatelessWidget {
  final SharedPreferences prefs;
  const CloudForestApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
        Provider<ApiService>(create: (_) => MockApiService()),
        ProxyProvider<ApiService, AuthRepository>(
          update: (ctx, api, prev) => AuthRepositoryImpl(api),
        ),
        ChangeNotifierProxyProvider<AuthRepository, AuthProvider>(
          create: (ctx) => AuthProvider(ctx.read<AuthRepository>()),
          update: (ctx, repo, prev) => prev ?? AuthProvider(repo),
        ),
        Provider<DocumentValidatorService>(
          create: (_) => DocumentValidatorService(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return Builder(
            builder: (context) {
              final auth = context.watch<AuthProvider>();
              final router = AppRouter.createRouter(auth);

              return MaterialApp.router(
                title: 'CloudForest IT Solutions',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                themeMode: ThemeMode.light,
                routerConfig: router,
              );
            },
          );
        },
      ),
    );
  }
}
