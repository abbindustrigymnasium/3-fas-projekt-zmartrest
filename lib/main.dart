import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:zmartrest/pocketbase.dart';
import 'package:zmartrest/main_scaffold.dart';
import 'package:zmartrest/screens/login_screen.dart';

//import 'package:zmartrest/device_handler.dart';
import 'package:zmartrest/simulated_device_handler.dart';
import 'package:zmartrest/logic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initPrefs();
  final isUserSessionAuthenticated = await isUserAuthenticated();

  final themeMode = await loadThemeFromPrefs();

  runApp(App(isAuthenticated: isUserSessionAuthenticated, themeMode: themeMode));
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

  //static const identifier = 'C36A972B';
  static const identifier = 'E985E828';

  DeviceHandler? deviceHandler;
  HealthMonitorSystem? healthMonitorSystem;
  bool isLoading = true;

  String userId = '';

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode;
    if (widget.isAuthenticated) {
      _initializeDeviceHandler();
    } else {
      setState(() {
        isLoading = false; // No need to wait for initialization if not authenticated
      });
    }
    _initializeDeviceHandler();
  }

  Future<void> _initializeDeviceHandler() async {
    try {
      final userInfo = await getUserInfo(); // Fetch user info
      if (userInfo == null) {
        throw Exception("User info is null");
      }
      userId = userInfo['id'];
      if (userId.isEmpty) {
        throw Exception("User ID is empty");
      }


      /*
      if (userId == null) {
        throw Exception("User ID is null");
      }
      */

      healthMonitorSystem = HealthMonitorSystem(userId: userId); // Initialize HealthMonitorSystem
      deviceHandler = DeviceHandler(
        identifier: identifier,
        healthMonitorSystem: healthMonitorSystem!,
      );

      //_addDeviceHandlerListeners();
    } catch (e) {
      debugPrint("Error initializing DeviceHandler: $e");
    } finally {
      setState(() {
        isLoading = false; // Initialization is complete
      });
    }
  }

  Future initializeDeviceHandlerFromLoginScreen() async {
    try {
      final userInfo = await getUserInfo(); // Fetch user info
      if (userInfo == null) {
        throw Exception("User info is null");
      }
      userId = userInfo['id'];
      if (userId.isEmpty) {
        throw Exception("User ID is empty");
      }


      /*
      if (userId == null) {
        throw Exception("User ID is null");
      }
      */

      healthMonitorSystem = HealthMonitorSystem(userId: userId); // Initialize HealthMonitorSystem
      deviceHandler = DeviceHandler(
        identifier: identifier,
        healthMonitorSystem: healthMonitorSystem!,
      );

      //_addDeviceHandlerListeners();

      return [healthMonitorSystem, deviceHandler, userId];
    } catch (e) {
      debugPrint("Error initializing DeviceHandler: $e");
    } finally {
      setState(() {
        isLoading = false; // Initialization is complete
      });
    }
  }

  /*
  void _addDeviceHandlerListeners() {
    if (deviceHandler == null) return;

    deviceHandler!.polar.batteryLevel.listen(
      (e) => setState(() => deviceHandler!.log('Battery: ${e.level}')),
      onError: (error) => setState(() => deviceHandler!.log('Battery error: $error')),
    );

    deviceHandler!.polar.deviceConnecting.listen(
      (_) => setState(() => deviceHandler!.log('Device connecting')),
      onError: (error) => setState(() => deviceHandler!.log('Connecting error: $error')),
    );

    deviceHandler!.polar.deviceConnected.listen(
      (_) => setState(() => deviceHandler!.log('Device connected')),
      onError: (error) => setState(() => deviceHandler!.log('Connection error: $error')),
    );

    deviceHandler!.polar.deviceDisconnected.listen(
      (_) => setState(() => deviceHandler!.log('Device disconnected')),
      onError: (error) => setState(() => deviceHandler!.log('Disconnection error: $error')),
    );
  }
  */

  void _setTheme(String theme) {
    setState(() {
      _themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    });

    saveThemeToPrefs(theme);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Only check for initialization failure if authenticated
    if (widget.isAuthenticated && (healthMonitorSystem == null || deviceHandler == null)) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: Text("Initialization failed.")),
        ),
      );
    }

    return ShadApp(
      theme: ShadThemeData(
        colorScheme: const ShadNeutralColorScheme.light(),
        brightness: Brightness.light,
        //textTheme: ShadTextTheme(family: 'RedHatDisplay'),
        textTheme: ShadTextTheme(family: 'Inter'),
        //radius: BorderRadius.all(Radius.circular(32)),
      ),
      darkTheme: ShadThemeData(
        colorScheme: const ShadNeutralColorScheme.dark(
          background: Color.fromARGB(255, 15, 15, 15)
        ),
        brightness: Brightness.dark,
        //textTheme: ShadTextTheme(family: 'RedHatDisplay'),
        textTheme: ShadTextTheme(family: 'Inter'),
        //radius: BorderRadius.all(Radius.circular(32)),
      ),
      themeMode: _themeMode,
      home: ScaffoldMessenger(
        child: widget.isAuthenticated
          ? MainScaffold(
              onThemeChanged: _setTheme,
              currentTheme: _themeMode == ThemeMode.dark ? 'dark' : 'light',
              healthMonitorSystem: healthMonitorSystem!,
              deviceHandler: deviceHandler!,
              userId: userId,
            )
          : LoginScreen(
              onThemeChanged: _setTheme,
              currentTheme: _themeMode == ThemeMode.dark ? 'dark' : 'light',
              initializeDeviceHandlerFromLoginScreen: initializeDeviceHandlerFromLoginScreen,
            ),
      )
    );
  }
}