import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:zmartrest/main_scaffold.dart';
//import './screens/login_screen.dart';

// Temporary bypass login
import 'pocketbase.dart';

void main() {
  runApp(const MyApp());
  // Temporary bypass login
  authenticateUser("alwin.forslund@hitachigymnasiet.se", "Jagälskarspetsen");
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _setTheme(String theme) {
    setState(() {
      _themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      theme: ShadThemeData(
        colorScheme: const ShadNeutralColorScheme.light(),
        brightness: Brightness.light,
        textTheme: ShadTextTheme(family: 'RedHatDisplay'),
      ),
      darkTheme: ShadThemeData(
        colorScheme: const ShadNeutralColorScheme.dark(
          background: Color.fromARGB(255, 15, 15, 15)
        ),
        brightness: Brightness.dark,
        textTheme: ShadTextTheme(family: 'RedHatDisplay'),
      ),
      themeMode: _themeMode,
      home: MainScaffold(onThemeChanged: _setTheme),
      //home: LoginScreen(onThemeChanged: _setTheme),
    );
  }
}