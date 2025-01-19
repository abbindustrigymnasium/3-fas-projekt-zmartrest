import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:zmartrest/widgets/select_user.dart';
import 'package:zmartrest/pocketbase.dart';
import 'data_visualization_screen.dart';

class AnalyzeScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onUserSelected;
  final String currentTheme;
  final Map<String, dynamic>? selectedUser;
  final List<Map<String, dynamic>> accelerometerData;
  final List<Map<String, dynamic>> heartRateData;
  final List<Map<String, dynamic>> rmssdData;
  final List<Map<String, dynamic>> rmssdBaselineData;
  final ShadDateTimeRange? selectedDateRange;
  final Function(ShadDateTimeRange) onDateRangeSelected;
  final bool isLoading;
  final bool hasFetchedData;
  
  const AnalyzeScreen({
    super.key, 
    required this.onUserSelected,
    required this.currentTheme,
    required this.selectedUser,
    this.accelerometerData = const [],
    this.heartRateData = const [],
    this.rmssdData = const [],
    this.rmssdBaselineData = const [],
    required this.selectedDateRange,
    required this.onDateRangeSelected,
    required this.isLoading,
    required this.hasFetchedData,
  });

  @override
  _AnalyzeScreenState createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  List<Map<String, dynamic>> users = [];
  final PageStorageBucket _bucket = PageStorageBucket();
  bool isLoading = true; // This is just for users loading state

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final fetchedUsers = await fetchAllUsers(pb);
      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load users: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: _bucket,
      child: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: widget.selectedUser == null
              ? EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.4)
              : const EdgeInsets.only(top: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User Selection Section
              if (widget.selectedUser == null)
                const Text(
                  "Start by selecting a user",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              if (widget.selectedUser != null)
                const Text(
                  "Selected user",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 10),
              SelectUser(
                users: users,
                onUserSelected: widget.onUserSelected, // Just pass through the callback
                selectedUser: widget.selectedUser,
              ),
              const SizedBox(height: 20),
              // Visualization Screen
              if (widget.selectedUser != null)
                DataVisualizationScreen(
                  selectedUser: widget.selectedUser!,
                  currentTheme: widget.currentTheme,
                  accelerometerData: widget.accelerometerData,
                  heartRateData: widget.heartRateData,
                  rmssdData: widget.rmssdData,
                  rmssdBaselineData: widget.rmssdBaselineData,
                  selectedDateRange: widget.selectedDateRange,
                  onDateRangeSelected: widget.onDateRangeSelected,
                  isLoading: widget.isLoading,
                  hasFetchedData: widget.hasFetchedData,
                ),
            ],
          ),
        ),
      ),
    );
  }
}