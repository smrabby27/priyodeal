import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PriyoDealApp());
}

class PriyoDealApp extends StatelessWidget {
  const PriyoDealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Priyo Deal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
