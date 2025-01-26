import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:zmartrest/pocketbase.dart';
import 'package:zmartrest/screens/analyze_screen.dart';
import 'package:zmartrest/screens/settings_screen.dart';
import 'package:zmartrest/widgets/bottom_nav.dart';
import 'package:zmartrest/screens/connect_device_screen.dart';
import 'package:zmartrest/logic.dart';
import 'package:zmartrest/device_handler.dart';
//import 'package:zmartrest/simulated_device_handler.dart';
//if simulated data is needed

class MainScaffold extends StatefulWidget {
  final Function(String) onThemeChanged; // Add the onThemeChanged callback
  final String currentTheme;
  final String userId;

  final MonitorSystem monitorSystem;
  final DeviceHandler deviceHandler;
  
  final Function getUserId;
  final Function initializeDeviceHandler;
  final Function initializeMonitorSystem;

  const MainScaffold({
    super.key,
    required this.onThemeChanged,
    required this.currentTheme,
    required this.monitorSystem,
    required this.deviceHandler,
    required this.userId,
    required this.getUserId,
    required this.initializeDeviceHandler,
    required this.initializeMonitorSystem,
  });

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}
//Manage states
class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _selectedUser;
  List<Map<String, dynamic>> _accelerometerData = [];
  List<Map<String, dynamic>> _heartRateData = [];
  List<Map<String, dynamic>> _rmssdData = [];
  List<Map<String, dynamic>> _rmssdBaselineData = [];
  ShadDateTimeRange? _selectedDateRange;
  bool _isLoading = false;
  bool _hasFetchedData = false;
  String _currentTheme = 'light';

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.currentTheme;  // Set initial theme

    _fetchLatestDate();
    _listenToRealTimeData(widget.monitorSystem);
  }

  Future<void> _fetchLatestDate() async {
    DateTime latestDate = await getLatestDataDate();
    setState(() {
      _selectedDateRange = ShadDateTimeRange(
        start: latestDate.subtract(Duration(days: 1)),
        end: latestDate.add(Duration(days: 1)),
      );
    });
    _handleDateRangeSelected(_selectedDateRange);
  }

  void _updateTheme(String newTheme) {
    setState(() {
      _currentTheme = newTheme;
    });
    widget.onThemeChanged(newTheme);  // Propagate theme change up to the parent
  }

  Future<void> _handleDateRangeSelected(ShadDateTimeRange? range) async {
    debugPrint(range.toString());
    if (range == null || _selectedUser == null) return;
    
    setState(() {
      _isLoading = true;
      _selectedDateRange = range;
      _hasFetchedData = false;
    });

    // Fetch data for selected date range
    try {
      final data = await fetchAllDataFromTo(
        pb,
        _selectedUser!['id'],
        range.start!.millisecondsSinceEpoch ~/ 1000,
        range.end!.millisecondsSinceEpoch ~/ 1000,
      );

      setState(() {
        _accelerometerData = data['accelerometer'] ?? [];
        _heartRateData = data['heartrate'] ?? [];
        _rmssdData = data['rmssd'] ?? [];
        _rmssdBaselineData = data['rmssd_baseline'] ?? [];
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

      debugPrint(e.toString());
    }
  }
//Establish listeners for realtime streams
  void _listenToRealTimeData(MonitorSystem monitorSystem) {
    monitorSystem.heartRateStream.listen((data) {
      setState(() {
        _heartRateData.add(data.toJson());
      });
    });

    monitorSystem.accelerometerStream.listen((data) {
      setState(() {
        _accelerometerData.add(data.toJson());
      });
    });

    monitorSystem.rmssdStream.listen((data) {
      setState(() {
        _rmssdData.add(data.toJson());
      });
    });

    monitorSystem.baselineStream.listen((data) {
      setState(() {
        _rmssdBaselineData.add(data.toJson());
      });
    });
  }
//Build UI for main_scaffold
  @override
  Widget build(BuildContext context) {
    final List<Widget> baseScreens = [
      SettingsScreen(
        onThemeChanged: _updateTheme,
        currentTheme: _currentTheme,
        userId: widget.userId,
        getUserId: widget.getUserId,
        initializeDeviceHandler: widget.initializeDeviceHandler,
        initializeMonitorSystem: widget.initializeMonitorSystem,
      ),
      AnalyzeScreen(
        onUserSelected: (user) {
          setState(() {
            _selectedUser = user;
            _hasFetchedData = false;
          });

          _fetchLatestDate();
        },
        currentTheme: _currentTheme,
        selectedUser: _selectedUser,
        accelerometerData: _accelerometerData,
        heartRateData: _heartRateData,
        rmssdData: _rmssdData,
        rmssdBaselineData: _rmssdBaselineData,
        selectedDateRange: _selectedDateRange,
        onDateRangeSelected: _handleDateRangeSelected,
        isLoading: _isLoading,
        hasFetchedData: _hasFetchedData,
      ),
      DeviceScreen(
        deviceHandler: widget.deviceHandler,
        monitorSystem: widget.monitorSystem,
      ),
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
