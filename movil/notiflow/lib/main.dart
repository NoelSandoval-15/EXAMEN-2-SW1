import 'package:flutter/material.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'core/storage/token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tokenStorage = TokenStorage();
  final bool isLoggedIn = await tokenStorage.hasSession();

  runApp(NotiflowApp(
    initialRoute: isLoggedIn ? AppRoutes.home : AppRoutes.login,
  ));
}

class NotiflowApp extends StatelessWidget {
  const NotiflowApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Tramites',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
