import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:zmartrest/widgets/select_user_search.dart';
import 'package:zmartrest/pocketbase.dart';
import 'data_visualization_screen.dart';

class AnalyzeScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onUserSelected;
  final String currentTheme;
  
  const AnalyzeScreen({
    super.key, 
    required this.onUserSelected,
    required this.currentTheme,
  });

  @override
  _AnalyzeScreenState createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  // List to store users
  List<Map<String, dynamic>> users = [];

  Map<String, dynamic>? _selectedUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch users when the page initializes
    _loadUsers();
  }

  // Method to fetch users
  Future<void> _loadUsers() async {
    try {
      final fetchedUsers = await fetchAllUsers(pb);
      setState(() {
        users = fetchedUsers;
        _isLoading = false;
      });
    } catch (e) {
      // Handle any errors (show a snackbar, etc.)
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        padding: _selectedUser == null ? EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.4) : EdgeInsets.only(top: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: _selectedUser == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  if (_selectedUser == null) const Text("Start by selecting a user", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)) else const Text("Selected user", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (_isLoading) const CircularProgressIndicator(),
                  if (_isLoading == false) 
                    SelectUserWithSearch(
                      users: users,
                      onUserSelected: (user) {
                        setState(() {
                          _selectedUser = user;
                        });
                        widget.onUserSelected(user); // Call the callback instead of navigating
                      },
                    ),
                ],
              ),
            ),
            if (_selectedUser != null) ...[
              DataVisualizationScreen(selectedUser: _selectedUser!, currentTheme: widget.currentTheme),
            ]
          ]
        )
      ),
    );
  }
}