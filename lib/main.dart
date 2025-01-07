import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
//import './screens/login_screen.dart';
import 'package:zmartrest/main_scaffold.dart';

// Temporary bypass login
import 'pocketbase.dart'; 

void main() {
  authenticateUser('alwin.forslund@hitachigymnasiet.se', 'Jagälskarspetsen');
  runApp(const MyApp());
  // Temporary bypass login
  authenticateUser("alwin.forslund@hitachigymnasiet.se", "Jagälskarspetsen");
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
      // Temporary bypass login
      //home: const LoginScreen(),
      home: const MainScaffold(),
    );
  }
}