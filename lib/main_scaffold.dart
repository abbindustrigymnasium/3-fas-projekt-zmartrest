import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'pocketbase.dart';

//import 'package:zmartrest/screens/device_screen.dart';
import 'package:zmartrest/screens/analyze_screen.dart';
import 'package:zmartrest/screens/settings_screen.dart';
import 'package:zmartrest/widgets/bottom_nav.dart';
import 'package:zmartrest/screens/connect_device_screen.dart';

class MainScaffold extends StatefulWidget {
  final Function(String) onThemeChanged; // Add the onThemeChanged callback
  final String currentTheme;

  const MainScaffold({
    super.key,
    required this.onThemeChanged,
    required this.currentTheme
  });

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _selectedUser;
  List<Map<String, dynamic>> _accelerometerData = [];
  List<Map<String, dynamic>> _heartRateData = [];
  ShadDateTimeRange? _selectedDateRange;
  bool _isLoading = false;
  bool _hasFetchedData = false;

  Future<void> _handleDateRangeSelected(ShadDateTimeRange range) async {
    if (_selectedUser == null) return;
    
    setState(() {
      _isLoading = true;
      _selectedDateRange = range;
    });

    try {
      final allData = await fetchAllDataFromTo(
        pb,
        _selectedUser!['id'],
        range.start!.millisecondsSinceEpoch ~/ 1000,
        range.end!.millisecondsSinceEpoch ~/ 1000,
      );

      setState(() {
        _accelerometerData = allData['accelerometer'] ?? [];
        _heartRateData = allData['heartrate'] ?? [];
        _isLoading = false;
        _hasFetchedData = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching data: $e')),
        );
      }
    }
  }

  /*
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
  */

  @override
  Widget build(BuildContext context) {
    final List<Widget> baseScreens = [
      SettingsScreen(
        onThemeChanged: widget.onThemeChanged, // Pass the callback to SettingsScreen
        currentTheme: widget.currentTheme,
      ),
      //_getAnalyzeScreen(),
      AnalyzeScreen(
        onUserSelected: (user) {
          setState(() {
            _selectedUser = user;
            _hasFetchedData = false;
          });
        },
        currentTheme: widget.currentTheme,
        selectedUser: _selectedUser,
        accelerometerData: _accelerometerData,
        heartRateData: _heartRateData,
        selectedDateRange: _selectedDateRange,
        onDateRangeSelected: _handleDateRangeSelected,
        isLoading: _isLoading,
        hasFetchedData: _hasFetchedData,
      ),
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
