import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import './screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      theme: ShadThemeData(
        colorScheme: const ShadNeutralColorScheme.light(), 
        brightness: Brightness.light, 
        textTheme: ShadTextTheme(family: 'RedHatDisplay')
      ),
      darkTheme: ShadThemeData(
        colorScheme: const ShadNeutralColorScheme.dark(), 
        brightness: Brightness.dark, 
        textTheme: ShadTextTheme(family: 'RedHatDisplay')
      ),
      home: const LoginScreen(),
    );
  }
}