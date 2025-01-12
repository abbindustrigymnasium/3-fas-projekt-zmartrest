import 'package:flutter/material.dart';

import 'package:zmartrest/screens/device_screen.dart';
import 'package:zmartrest/screens/analyze_screen.dart';
import 'package:zmartrest/screens/settings_screen.dart';
import 'package:zmartrest/screens/data_visualization_screen.dart';
import 'package:zmartrest/widgets/bottom_nav.dart';

class MainScaffold extends StatefulWidget {
  final Function(String) onThemeChanged; // Add the onThemeChanged callback
  final String currentTheme;

  const MainScaffold({super.key, required this.onThemeChanged, required this.currentTheme});

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _selectedUser;

  Widget _getAnalyzeScreen() {
    if (_selectedUser == null) {
      return AnalyzeScreen(
        onUserSelected: (user) {
          setState(() {
            _selectedUser = user;
          });
        },
      );
    } else {
      return DataVisualizationScreen(selectedUser: _selectedUser!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> baseScreens = [
      SettingsScreen(
        onThemeChanged: widget.onThemeChanged, // Pass the callback to SettingsScreen
        currentTheme: widget.currentTheme,
      ),
      _getAnalyzeScreen(),
      const DeviceScreen(),
    ];

    return Scaffold(
      body: baseScreens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
