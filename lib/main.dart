import 'package:flutter/material.dart';
import 'package:ticker/core/di/injection.dart';
import 'package:ticker/core/router/app_router.dart';

void main() {
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ticker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF0B90B),
          brightness: Brightness.dark,
          surface: const Color(0xFF0B0E11),
        ),
        dividerTheme: const DividerThemeData(color: Color(0xFF1E2329)),
      ),
      routerConfig: appRouter,
    );
  }
}
