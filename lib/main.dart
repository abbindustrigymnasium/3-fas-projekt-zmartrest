import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:zmartrest/pocketbase.dart';
import 'package:zmartrest/main_scaffold.dart';
import 'package:zmartrest/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initPrefs();
  final isUserSessionAuthenticated = await isUserAuthenticated();

  final themeMode = await loadThemeFromPrefs();

  runApp(App(isAuthenticated: isUserSessionAuthenticated, themeMode: themeMode));
  
  //runApp(const App());
  //authenticateUser("alwin.forslund@hitachigymnasiet.se", "Jagälskarspetsen");
}

class App extends StatefulWidget {
  final bool isAuthenticated; // To start on login screen or main screen
  final ThemeMode themeMode;

  const App({
    super.key,
    required this.isAuthenticated,
    required this.themeMode
  });

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode;
  }

  void _setTheme(String theme) {
    setState(() {
      _themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    });

    saveThemeToPrefs(theme);
  }

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      theme: ShadThemeData(
        colorScheme: const ShadNeutralColorScheme.light(),
        brightness: Brightness.light,
        //textTheme: ShadTextTheme(family: 'RedHatDisplay'),
        textTheme: ShadTextTheme(family: 'Inter'),
      ),
      darkTheme: ShadThemeData(
        colorScheme: const ShadNeutralColorScheme.dark(
          background: Color.fromARGB(255, 15, 15, 15)
        ),
        brightness: Brightness.dark,
        //textTheme: ShadTextTheme(family: 'RedHatDisplay'),
        textTheme: ShadTextTheme(family: 'Inter'),
      ),
      themeMode: _themeMode,
      home: ScaffoldMessenger(
        child: widget.isAuthenticated
          ? MainScaffold(
              onThemeChanged: _setTheme,
              currentTheme: _themeMode == ThemeMode.dark ? 'dark' : 'light',
            )
          : LoginScreen(
              onThemeChanged: _setTheme,
              currentTheme: _themeMode == ThemeMode.dark ? 'dark' : 'light',
            ),
      )
      
    );
  }
}