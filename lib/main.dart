import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/presentation/superadmin_dashboard_screen.dart';

void main() {
  runApp(const ProviderScope(child: ADAdminApp()));
}

class ADAdminApp extends StatelessWidget {
  const ADAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADAdmin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),

        // 👇 AQUÍ EL CAMBIO IMPORTANTE
        '/super/dashboard': (context) => const SuperAdminDashboardWrapper(),

        // Más adelante:
        // '/secretaria/dashboard': (context) => const SecretariaDashboardWrapper(),
        // '/pastor/dashboard': (context) => const PastorDashboardWrapper(),
      },
    );
  }
}
