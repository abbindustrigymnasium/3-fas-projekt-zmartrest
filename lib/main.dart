import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:zmartrest/pocketbase.dart';
import 'package:zmartrest/main_scaffold.dart';
import 'package:zmartrest/screens/login_screen.dart';
import 'package:zmartrest/device_handler.dart';
//import 'package:zmartrest/simulated_device_handler.dart';
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
  MonitorSystem? monitorSystem;
  bool isLoading = true;

  String userId = '';

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode;
    if (widget.isAuthenticated) {
      init();
    } else {
      setState(() {
        isLoading = false; // No need to wait for initialization if not authenticated
      });
    }
  }

  init() async {
    monitorSystem = await _initializeMonitorSystem();
    if (monitorSystem != null) {
      deviceHandler = await _initializeDeviceHandler(monitorSystem!);
    }

    setState(() {
      isLoading = false; // Initialization is complete
    });
  }

  Future _getUserId() async {
    final userInfo = await getUserInfo(); // Fetch user info

    userId = userInfo?['id'];
    if (userId.isEmpty) {
      throw Exception("User ID is empty");
    } else {
      return userId;
    }
  }

  Future _initializeDeviceHandler(MonitorSystem monitorSystem) async {
    try {      
      deviceHandler = DeviceHandler(
        identifier: identifier,
        monitorSystem: monitorSystem,
      );

      _addDeviceHandlerListeners();

      return deviceHandler;
    } catch (e) {
      debugPrint("Error initializing DeviceHandler: $e");
    }
  }

  Future _initializeMonitorSystem() async {
    try {
      final userId = await _getUserId();
      return monitorSystem = MonitorSystem(userId: userId); // Initialize HealthMonitorSystem      
    } catch (e) {
      debugPrint("Error initializing monitor system: $e");
    }
  }

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
    if (widget.isAuthenticated && (monitorSystem == null || deviceHandler == null)) {
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
              monitorSystem: monitorSystem!,
              deviceHandler: deviceHandler!,
              userId: userId,
              getUserId: _getUserId,
              initializeDeviceHandler: _initializeDeviceHandler,
              initializeMonitorSystem: _initializeMonitorSystem,
            )
          : LoginScreen(
              onThemeChanged: _setTheme,
              currentTheme: _themeMode == ThemeMode.dark ? 'dark' : 'light',
              getUserId: _getUserId,
              initializeDeviceHandler: _initializeDeviceHandler,
              initializeMonitorSystem: _initializeMonitorSystem,
            ),
      )
    );
  }
}